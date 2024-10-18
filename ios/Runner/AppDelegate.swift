import Flutter
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    let healthStore: HKHealthStore
    let workoutType = HKObjectType.workoutType()
    
    override init() {
        healthStore = HKHealthStore()
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
            case "retrieveLastWalkingWorkouts":
                self.retrieveLastWalkingWorkouts(result: result, limit: call.arguments as! Int)
            default: result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func requestAuthorization(result: @escaping FlutterResult) {
        let typesToRead: Set = [workoutType, HKSeriesType.workoutRoute()]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
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
            let workoutJSONStrings = workoutResults.map { workout  -> String in
                let dict: [String: Any?] = [
                    "activityType": workout.workoutActivityType.rawValue,
                    "startDate": workout.startDate.timeIntervalSince1970,
                    "endDate": workout.endDate.timeIntervalSince1970,
                    "duration": workout.duration,
                    "totalEnergyBurned": workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()),
                    "totalDistance": workout.totalDistance?.doubleValue(for: HKUnit.meter())                    
                ]

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                    return String(data: jsonData, encoding: .utf8) ?? ""
                } catch {
                    print("Error serializing workout to JSON: \(error)")
                    return ""
                }
            }
            
            result(workoutJSONStrings)
        }
        
        healthStore.execute(query)
    }
}
