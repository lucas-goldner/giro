// ignore_for_file: avoid_print

import 'dart:async';

import 'package:giro/healthkit/bindings/healthkit/healthkit.dart';
import 'package:giro/healthkit/repository/healthkit_repo.dart';
import 'package:objective_c/objective_c.dart';

enum SortIdentifier {
  startDate,
  endDate;

  NSString get asNSString => NSString(name);
}

class HealthKitRepoFFIImpl implements HealthkitRepo {
  late HKHealthStore health;
  final workoutType = HKObjectType.workoutType();
  static final hKSampleSortIdentifierEndDate =
      SortIdentifier.endDate.asNSString;
  static final hKSampleSortIdentifierStartDate =
      SortIdentifier.startDate.asNSString;

  void initialize() {
    health = HKHealthStore.new1();
    print('Initialized');
    health.init();
  }

  @override
  Future<bool> requestAuthorization() {
    print('Authorize Health');
    final typesToShare = NSSet.new1().setByAddingObject_(workoutType);
    final typesToRead =
        typesToShare.setByAddingObject_(HKSeriesType.workoutRouteType());

    final completer = Completer<bool>();
    final handler = ObjCBlock_ffiVoid_bool_NSError.listener((result, error) {
      print('Auth result: $result');
      completer.complete(result);
    });

    health.requestAuthorizationToShareTypes_readTypes_completion_(
      typesToShare,
      typesToRead,
      handler,
    );

    return completer.future;
  }

  @override
  Future<void> retrieveLastWalkingWorkout({int limit = 10}) async {
    final workoutPredicate =
        HKQuery.predicateForWorkoutsWithWorkoutActivityType_(
      HKWorkoutActivityType.HKWorkoutActivityTypeWalking,
    );
    final sortDescriptor = NSSortDescriptor.sortDescriptorWithKey_ascending_(
      hKSampleSortIdentifierEndDate,
      false,
    );
    final sortDescriptors = NSArray.arrayWithObject_(sortDescriptor);

    final handler = ObjCBlock_ffiVoid_HKSampleQuery_NSArray_NSError.listener(
      (query, results, error) {
        if (results != null) {
          final workout = results.firstObject! as HKWorkout;
          print('Workout found: $workout');
          // retrieveRouteForWorkout(workout);
        } else {
          print('No workout found: ${error?.localizedDescription}');
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
