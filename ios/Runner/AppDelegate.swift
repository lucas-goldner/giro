import Flutter
import HealthKit
import CoreLocation
import UIKit

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
        
        healthkitChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method {
            case "requestAuthorization":
                self.requestAuthorization(result: result)
            case "retrieveWorkoutsWithRoutes":
                self.retrieveWorkoutsWithRoutes(result: result, limit: call.arguments as! Int)
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
    
    func retrieveWorkoutsWithRoutes(result: @escaping FlutterResult, limit: Int) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: workoutPredicate,
                                  limit: limit,
                                  sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let self = self else { return }
            guard let workouts = results as? [HKWorkout], !workouts.isEmpty else {
                print("No workouts found: \(error?.localizedDescription ?? "unknown error")")
                result(FlutterError(code: "NO_WORKOUTS_FOUND", message: "No workouts found.", details: error?.localizedDescription))
                return
            }
            
            var workoutsData = [[String: Any]]()
            let dispatchGroup = DispatchGroup()
            
            for workout in workouts {
                dispatchGroup.enter()
                self.retrieveRoutesForWorkout(workout) { locations, error in
                    if let error = error {
                        print("Failed to retrieve routes: \(error.localizedDescription)")
                    }
                    
                    
                    
                    var workoutDict: [String: Any] = [
                        "activityType": workout.workoutActivityType.rawValue,
                        "startDate": workout.startDate.timeIntervalSince1970,
                        "endDate": workout.endDate.timeIntervalSince1970,
                        "duration": workout.duration,
                        "totalEnergyBurned": workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? NSNull(),
                        "totalDistance": workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? NSNull(),
                    ]
                    
                    if let locations = locations {
                        let coordinatesArray = locations.map { location -> [String: Double] in
                            return [
                                "latitude": location.coordinate.latitude,
                                "longitude": location.coordinate.longitude
                            ]
                        }
                        workoutDict["routes"] = coordinatesArray
                    } else {
                        workoutDict["routes"] = []
                    }
                    
                    workoutsData.append(workoutDict)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                result(workoutsData)
            }
        }
        
        self.healthStore.execute(query)
    }
    
    func retrieveRoutesForWorkout(_ workout: HKWorkout, completion: @escaping ([CLLocation]?, Error?) -> Void) {
        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
        
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, anchor, error) in
            guard let self = self else { return }
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let routeSamples = samples as? [HKWorkoutRoute], !routeSamples.isEmpty else {
                completion(nil, NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No route samples found."]))
                return
            }
            
            var allLocations: [CLLocation] = []
            let routeGroup = DispatchGroup()
            
            for route in routeSamples {
                routeGroup.enter()
                let routeLocationQuery = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                    if let error = errorOrNil {
                        completion(nil, error)
                        routeGroup.leave()
                        return
                    }
                    
                    if let locations = locationsOrNil {
                        allLocations.append(contentsOf: locations)
                    }
                    
                    if done {
                        routeGroup.leave()
                    }
                }
                self.healthStore.execute(routeLocationQuery)
            }
            
            routeGroup.notify(queue: .main) {
                completion(allLocations, nil)
            }
        }
        
        self.healthStore.execute(routeQuery)
    }
}

