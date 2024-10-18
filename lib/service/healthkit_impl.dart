import 'dart:async';

import 'package:giro/bindings/healthkit2/healthkit2.dart';
import 'package:objective_c/objective_c.dart';

enum SortIdentifier {
  startDate,
  endDate;

  NSString get asNSString => NSString(name);
}

class HealthKitImpl {
  late HKHealthStore health;
  final workoutType = HKObjectType.workoutType();
  static final hKSampleSortIdentifierEndDate =
      SortIdentifier.endDate.asNSString;
  static final hKSampleSortIdentifierStartDate =
      SortIdentifier.startDate.asNSString;

  void initialize() {
    health = HKHealthStore.new1();
    print("Initialized");
    health.init();
  }

  void requestHealthAccess() {
    print("Authorize Health");

    final typesToShare = NSSet.new1().setByAddingObject_(workoutType);
    final typesToRead =
        typesToShare.setByAddingObject_(HKSeriesType.workoutRouteType());

    final completer = Completer<bool?>();
    final handler =
        ObjCBlock_ffiVoid_bool_NSError.listener((bool? result, NSError? error) {
      if (result != null) {
        print("Auth result: $result");
        completer.complete(result);
      } else {
        print("Authorization failed:: ${error?.localizedDescription}");
        completer.completeError(error ?? Exception("Unknown error"));
      }
    });

    health.requestAuthorizationToShareTypes_readTypes_completion_(
      typesToShare,
      typesToRead,
      handler,
    );
  }

  void retrieveLastWalkingWorkout() {
    final workoutPredicate =
        HKQuery.predicateForWorkoutsWithWorkoutActivityType_(
            HKWorkoutActivityType.HKWorkoutActivityTypeWalking);
    final sortDescriptor = NSSortDescriptor.sortDescriptorWithKey_ascending_(
      hKSampleSortIdentifierEndDate,
      false,
    );
    final sortDescriptors = NSArray.arrayWithObject_(sortDescriptor);

    final handler = ObjCBlock_ffiVoid_HKSampleQuery_NSArray_NSError.listener(
      (HKSampleQuery query, NSArray? results, NSError? error) {
        if (results != null) {
          final workout = results.firstObject as HKWorkout;
          print("Workout found: $workout");
          // retrieveRouteForWorkout(workout);
        } else {
          print("No workout found: ${error?.localizedDescription}");
        }
      },
    );

    final query = HKSampleQuery.new1()
        .initWithSampleType_predicate_limit_sortDescriptors_resultsHandler_(
      HKObjectType.workoutType(),
      workoutPredicate,
      1,
      sortDescriptors,
      handler,
    );

    health.executeQuery_(query);
  }
}
