package com.lucasgoldner.giro

import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.ExerciseRouteResult
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * The Android counterpart of the iOS HealthKit bridge (AppDelegate.swift):
 * the same method channel, the same methods, the same payload, backed by
 * Health Connect. Walking and hiking sessions with their exercise routes
 * become Giro walks.
 */
class HealthConnectBridge(private val activity: ComponentActivity) {
    companion object {
        const val CHANNEL = "com.lucas-goldner.giro/healthkit"

        // HealthKit's HKWorkoutActivityType raw values, which the Dart side
        // already understands.
        private const val HK_WALKING = 52
        private const val HK_HIKING = 24
        private const val HK_RUNNING = 37

        private const val READ_EXERCISE_ROUTES = "android.permission.health.READ_EXERCISE_ROUTES"

        private val WALK_TYPES = setOf(
            ExerciseSessionRecord.EXERCISE_TYPE_WALKING,
            ExerciseSessionRecord.EXERCISE_TYPE_HIKING,
        )
    }

    private val permissions = setOf(
        HealthPermission.getReadPermission(ExerciseSessionRecord::class),
        HealthPermission.getReadPermission(DistanceRecord::class),
        HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class),
        READ_EXERCISE_ROUTES,
    )

    /** Reading sessions is enough to list walks; routes and totals are extras. */
    private val required = setOf(HealthPermission.getReadPermission(ExerciseSessionRecord::class))

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var channel: MethodChannel? = null
    private var pendingAuthorization: MethodChannel.Result? = null

    private val permissionLauncher: ActivityResultLauncher<Set<String>> =
        activity.registerForActivityResult(
            PermissionController.createRequestPermissionResultContract(),
        ) { granted ->
            pendingAuthorization?.success(granted.containsAll(required))
            pendingAuthorization = null
        }

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL).also { ch ->
            ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestAuthorization" -> requestAuthorization(result)
                    "retrieveWorkoutsWithRoutes" -> {
                        var limit = 10
                        var before: Instant? = null
                        when (val args = call.arguments) {
                            is Int -> limit = args
                            is Map<*, *> -> {
                                (args["limit"] as? Number)?.let { limit = it.toInt() }
                                (args["before"] as? Number)?.let {
                                    before = Instant.ofEpochMilli((it.toDouble() * 1000).toLong())
                                }
                            }
                        }
                        retrieveWorkouts(result, limit, before)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
        scope.cancel()
    }

    private fun client(): HealthConnectClient? =
        if (HealthConnectClient.getSdkStatus(activity) == HealthConnectClient.SDK_AVAILABLE) {
            HealthConnectClient.getOrCreate(activity)
        } else {
            null
        }

    private fun requestAuthorization(result: MethodChannel.Result) {
        val client = client()
        if (client == null) {
            // Health Connect is not installed or this Android is too old.
            result.success(false)
            return
        }
        scope.launch {
            try {
                val granted = client.permissionController.getGrantedPermissions()
                if (granted.containsAll(required)) {
                    result.success(true)
                } else {
                    pendingAuthorization?.success(false)
                    pendingAuthorization = result
                    permissionLauncher.launch(permissions)
                }
            } catch (error: Exception) {
                result.success(false)
            }
        }
    }

    private fun retrieveWorkouts(result: MethodChannel.Result, limit: Int, before: Instant?) {
        val client = client()
        if (client == null) {
            result.success(emptyList<Map<String, Any?>>())
            return
        }
        scope.launch {
            try {
                val workouts = withContext(Dispatchers.IO) { readWalks(client, limit, before) }
                result.success(workouts)
            } catch (error: Exception) {
                result.error("health_connect", error.message, null)
            }
        }
    }

    private suspend fun readWalks(
        client: HealthConnectClient,
        limit: Int,
        before: Instant?,
    ): List<Map<String, Any?>> {
        val filter = if (before != null) {
            TimeRangeFilter.before(before)
        } else {
            TimeRangeFilter.after(Instant.EPOCH)
        }
        val out = mutableListOf<Map<String, Any?>>()
        var token: String? = null
        do {
            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = ExerciseSessionRecord::class,
                    timeRangeFilter = filter,
                    ascendingOrder = false,
                    pageSize = if (limit <= 0) 1000 else minOf(limit * 3, 1000),
                    pageToken = token,
                ),
            )
            for (session in response.records) {
                if (session.exerciseType !in WALK_TYPES) continue
                if (before != null && !session.endTime.isBefore(before)) continue
                out += toWorkout(client, session)
                if (limit > 0 && out.size >= limit) return out
            }
            token = response.pageToken
        } while (token != null)
        return out
    }

    private suspend fun toWorkout(
        client: HealthConnectClient,
        session: ExerciseSessionRecord,
    ): Map<String, Any?> {
        val range = TimeRangeFilter.between(session.startTime, session.endTime)
        var distance: Double? = null
        var energy: Double? = null
        try {
            val totals = client.aggregate(
                AggregateRequest(
                    metrics = setOf(DistanceRecord.DISTANCE_TOTAL, TotalCaloriesBurnedRecord.ENERGY_TOTAL),
                    timeRangeFilter = range,
                ),
            )
            distance = totals[DistanceRecord.DISTANCE_TOTAL]?.inMeters
            energy = totals[TotalCaloriesBurnedRecord.ENERGY_TOTAL]?.inKilocalories
        } catch (_: Exception) {
            // Distance and calories are optional, like on iOS.
        }
        val route = (session.exerciseRouteResult as? ExerciseRouteResult.Data)
            ?.exerciseRoute?.route
            ?.sortedBy { it.time }
            ?.map { mapOf("latitude" to it.latitude, "longitude" to it.longitude) }
            ?: emptyList()
        val activity = when (session.exerciseType) {
            ExerciseSessionRecord.EXERCISE_TYPE_HIKING -> HK_HIKING
            ExerciseSessionRecord.EXERCISE_TYPE_RUNNING -> HK_RUNNING
            else -> HK_WALKING
        }
        return mapOf(
            "activityType" to activity,
            "startDate" to session.startTime.toEpochMilli() / 1000.0,
            "endDate" to session.endTime.toEpochMilli() / 1000.0,
            "duration" to (session.endTime.toEpochMilli() - session.startTime.toEpochMilli()) / 1000.0,
            "totalEnergyBurned" to energy,
            "totalDistance" to distance,
            "routes" to route,
        )
    }
}
