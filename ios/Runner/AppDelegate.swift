import Flutter
import HealthKit
import CoreLocation
import UIKit

struct WalkingWorkout: Codable {
    let activityType: UInt
    let startDate: TimeInterval
    let endDate: TimeInterval
    let duration: TimeInterval
    let totalEnergyBurned: Double?
    let totalDistance: Double?
    
    init(workout: HKWorkout) {
        self.activityType = workout.workoutActivityType.rawValue
        self.startDate = workout.startDate.timeIntervalSince1970
        self.endDate = workout.endDate.timeIntervalSince1970
        self.duration = workout.duration
        self.totalEnergyBurned = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie())
        self.totalDistance = workout.totalDistance?.doubleValue(for: HKUnit.meter())
    }
    
    func toJSONString() -> String? {
           let encoder = JSONEncoder()
           do {
               let jsonData = try encoder.encode(self)
               return String(data: jsonData, encoding: .utf8)
           } catch {
               print("Error encoding WalkingWorkout to JSON: \(error)")
               return nil
           }
    }
    
    func toHKWorkout(healthStore: HKHealthStore, completion: @escaping (HKWorkout?, Error?) -> Void) {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = HKWorkoutActivityType(rawValue: self.activityType) ?? .other
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: workoutConfiguration, device: nil)
        
        let start = Date(timeIntervalSince1970: self.startDate)
        let end = Date(timeIntervalSince1970: self.endDate)
        
        builder.beginCollection(withStart: start) { _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var samples: [HKSample] = []
            if let energyValue = self.totalEnergyBurned {
                let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: energyValue)
                let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                let energySample = HKQuantitySample(type: energyType, quantity: energyQuantity, start: start, end: end)
                samples.append(energySample)
            }
            
            if let distanceValue = self.totalDistance {
                let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distanceValue)
                let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
                let distanceSample = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: start, end: end)
                samples.append(distanceSample)
            }
            
            builder.add(samples) { _, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                builder.endCollection(withEnd: end) { _, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    builder.finishWorkout { workout, error in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            completion(workout, nil)
                        }
                    }
                }
            }
        }
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    let healthStore: HKHealthStore
    let workoutType = HKObjectType.workoutType()
    
    override init() {
        self.healthStore = HKHealthStore()
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let healthkitChannel = FlutterMethodChannel(name: "com.lucas-goldner.giro/healthkit",
                                                    binaryMessenger: controller.binaryMessenger)
        let workoutRoutesChannel = FlutterMethodChannel(name: "com.lucas-goldner.giro/workout_routes",
                                                        binaryMessenger: controller.binaryMessenger)
        
        healthkitChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method {
            case "requestAuthorization":
                self.requestAuthorization(result: result)
            case "retrieveLastWalkingWorkouts":
                self.retrieveLastWalkingWorkouts(result: result, limit: call.arguments as! Int)
            default: result(FlutterMethodNotImplemented)
            }
        }
        
        workoutRoutesChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method {
            case "retrieveRouteForWorkout":
                self.retrieveRouteForWorkout(result: result, workoutData: call.arguments as! String)
            default: result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func requestAuthorization(result: @escaping FlutterResult) {
        let typesToRead: Set = [workoutType, HKSeriesType.workoutRoute()]
        self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                result(true)
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "unknown error")")
                result(false)
            }
        }
    }
    
    func retrieveLastWalkingWorkouts(result: @escaping FlutterResult, limit: Int) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: workoutPredicate,
                                  limit: limit,
                                  sortDescriptors: [sortDescriptor])
        { _, results, error in
            guard let workout = results?.first as? HKWorkout else {
                print("No workout found: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let workoutResults = (results as? [HKWorkout]) ?? []
            let workoutJSONStrings = workoutResults
                .filter { $0.workoutActivityType == HKWorkoutActivityType.walking }
                .map { WalkingWorkout(workout: $0).toJSONString() }
            
            result(workoutJSONStrings)
        }
        
        self.healthStore.execute(query)
    }
    
    func retrieveRouteForWorkout(result: @escaping FlutterResult, workoutData: String) {
        guard let workoutData = workoutData.data(using: .utf8) else {
            print("Invalid workout data string.")
            result(FlutterError(code: "INVALID_INPUT", message: "Invalid workout data string.", details: nil))
            return
        }
        
        do {
            let decodedWorkout = try JSONDecoder().decode(WalkingWorkout.self, from: workoutData)
            
            decodedWorkout.toHKWorkout(healthStore: healthStore) { hkWorkout, error in
                if let error = error {
                    print("Error converting workout: \(error.localizedDescription)")
                    result(FlutterError(code: "WORKOUT_CONVERSION_ERROR", message: "Failed to convert workout.", details: error.localizedDescription))
                    return
                }
                
                guard let hkWorkout = hkWorkout else {
                    print("Unknown error in converting workout.")
                    result(FlutterError(code: "UNKNOWN_ERROR", message: "Unknown error in converting workout.", details: nil))
                    return
                }
                
                let workoutPredicate = HKQuery.predicateForObjects(from: hkWorkout)
                let routeType = HKSeriesType.workoutRoute()
                
                let routeQuery = HKAnchoredObjectQuery(type: routeType, predicate: workoutPredicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
                    
                    if let error = error {
                        print("The initial query failed: \(error.localizedDescription)")
                        result(FlutterError(code: "QUERY_FAILED", message: error.localizedDescription, details: nil))
                        return
                    }
                    
                    guard let routeSamples = samples as? [HKWorkoutRoute], !routeSamples.isEmpty else {
                        print("No route samples found.")
                        result(FlutterError(code: "NO_ROUTE_SAMPLES", message: "No route samples found for workout.", details: nil))
                        return
                    }
                    
                    let route = routeSamples.first!
                    
                    var allLocations: [CLLocation] = []
                    
                    let routeLocationQuery = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                        if let error = errorOrNil {
                            print("Error retrieving locations: \(error.localizedDescription)")
                            result(FlutterError(code: "LOCATIONS_ERROR", message: error.localizedDescription, details: nil))
                            return
                        }
                        
                        if let locations = locationsOrNil {
                            allLocations.append(contentsOf: locations)
                        }
                        
                        if done {
                            if allLocations.isEmpty {
                                print("No locations found in route.")
                                result(FlutterError(code: "NO_LOCATIONS", message: "No locations found for route.", details: nil))
                                return
                            }
                            
                            // Convert locations to coordinates array
                            let coordinatesArray = allLocations.map { location -> [String: Double] in
                                return [
                                    "latitude": location.coordinate.latitude,
                                    "longitude": location.coordinate.longitude
                                ]
                            }
                            
                            let startDate = route.startDate.timeIntervalSince1970
                            let endDate = route.endDate.timeIntervalSince1970
                            
                            let routeDict: [String: Any] = [
                                "coordinates": coordinatesArray,
                                "startDate": startDate,
                                "endDate": endDate
                            ]
                                                        
                            result(routeDict)
                        }
                    }
                    
                    self.healthStore.execute(routeLocationQuery)
                }
                
                self.healthStore.execute(routeQuery)
            }
        } catch {
            print("Failed to decode workout: \(error.localizedDescription)")
            result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode workout.", details: error.localizedDescription))
        }
    }
}
