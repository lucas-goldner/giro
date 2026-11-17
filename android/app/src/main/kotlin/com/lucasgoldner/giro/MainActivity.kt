package com.lucasgoldner.giro

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/// A FragmentActivity so Health Connect's permission contract can be
/// registered (the plain FlutterActivity is not a ComponentActivity).
class MainActivity : FlutterFragmentActivity() {
    private lateinit var health: HealthConnectBridge

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        health = HealthConnectBridge(this)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        health.attach(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        health.detach()
        super.onDestroy()
    }
}
