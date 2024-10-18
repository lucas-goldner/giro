import 'package:giro/bindings/healthkit/healthkit.dart';
import 'package:objective_c/objective_c.dart';

class HealthKitImpl {
  late HKHealthStore health;
  final workoutType = HKObjectType.workoutType();

  void initialize() {
    health = HKHealthStore.new1();
    print("Initialized");
    health.init();
  }

  void requestHealthAccess() {
    print("Authorize Health");

    NSSet typesToShare = NSSet.new1().setByAddingObject_(workoutType);
    NSSet typesToRead =
        typesToShare.setByAddingObject_(HKSeriesType.workoutRouteType());

    health.requestAuthorizationToShareTypes_readTypes_completion_(
      typesToShare, typesToRead,
      // ObjCBlock<Void Function(Bool, NSError?)>
      ObjCBlock_ffiVoid_bool_NSError.fromFunction(
          (bool? result, NSError? error) {
        if (result != null) {
          print("Auth result: $result");
        } else {
          print("Authorization failed:: ${error?.localizedDescription}");
        }
      }),
    );
  }

  void retrieveLastWalkingWorkout() {
    final workoutPredicate =
        HKQuery.predicateForWorkoutActivitiesWithWorkoutActivityType_(
            HKWorkoutActivityType.HKWorkoutActivityTypeWalking);
  }

//   func retrieveLastWalkingWorkout() {
//     let workoutPredicate = HKQuery.predicateForWorkouts(with: .walking)
//     let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

//     let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
//                               predicate: workoutPredicate,
//                               limit: 1,
//                               sortDescriptors: [sortDescriptor]) { query, results, error in
//         guard let workout = results?.first as? HKWorkout else {
//             print("No workout found: \(error?.localizedDescription ?? "unknown error")")
//             return
//         }

//         // Proceed to retrieve the route for the workout
//         self.retrieveRouteForWorkout(workout)
//     }

//     healthStore.execute(query)
// }

// // Function to retrieve route data for a workout
// func retrieveRouteForWorkout(_ workout: HKWorkout) {
//     let routeQuery = HKWorkoutRouteQuery(route: workout) { (query, locationsOrNil, done, errorOrNil) in
//         guard let locations = locationsOrNil else {
//             print("No locations found: \(errorOrNil?.localizedDescription ?? "unknown error")")
//             return
//         }

//         // Process the locations data
//         for location in locations {
//             print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//         }

//         if done {
//             print("All route data retrieved")
//         }
//     }

//     healthStore.execute(routeQuery)
// }
}
