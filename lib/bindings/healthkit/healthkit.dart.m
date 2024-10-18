#include <stdint.h>
#import <HealthKit/HealthKit.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retain(id);
id objc_retainBlock(id);

typedef void  (^ListenerBlock)(NSDictionary* , struct _NSRange , BOOL * );
ListenerBlock wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary_NSRange_bool(ListenerBlock block) NS_RETURNS_RETAINED {
  return ^void(NSDictionary* arg0, struct _NSRange arg1, BOOL * arg2) {
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^ListenerBlock1)(id , struct _NSRange , BOOL * );
ListenerBlock1 wrapListenerBlock_ObjCBlock_ffiVoid_objcObjCObject_NSRange_bool(ListenerBlock1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^ListenerBlock2)(NSDate* , BOOL , BOOL * );
ListenerBlock2 wrapListenerBlock_ObjCBlock_ffiVoid_NSDate_bool_bool(ListenerBlock2 block) NS_RETURNS_RETAINED {
  return ^void(NSDate* arg0, BOOL arg1, BOOL * arg2) {
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^ListenerBlock3)(NSTimer* );
ListenerBlock3 wrapListenerBlock_ObjCBlock_ffiVoid_NSTimer(ListenerBlock3 block) NS_RETURNS_RETAINED {
  return ^void(NSTimer* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock4)(NSFileHandle* );
ListenerBlock4 wrapListenerBlock_ObjCBlock_ffiVoid_NSFileHandle(ListenerBlock4 block) NS_RETURNS_RETAINED {
  return ^void(NSFileHandle* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock5)(NSError* );
ListenerBlock5 wrapListenerBlock_ObjCBlock_ffiVoid_NSError(ListenerBlock5 block) NS_RETURNS_RETAINED {
  return ^void(NSError* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock6)(NSDictionary* , NSError* );
ListenerBlock6 wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary_NSError(ListenerBlock6 block) NS_RETURNS_RETAINED {
  return ^void(NSDictionary* arg0, NSError* arg1) {
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock7)(NSArray* );
ListenerBlock7 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray(ListenerBlock7 block) NS_RETURNS_RETAINED {
  return ^void(NSArray* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock8)(NSTextCheckingResult* , NSMatchingFlags , BOOL * );
ListenerBlock8 wrapListenerBlock_ObjCBlock_ffiVoid_NSTextCheckingResult_NSMatchingFlags_bool(ListenerBlock8 block) NS_RETURNS_RETAINED {
  return ^void(NSTextCheckingResult* arg0, NSMatchingFlags arg1, BOOL * arg2) {
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^ListenerBlock9)(NSCachedURLResponse* );
ListenerBlock9 wrapListenerBlock_ObjCBlock_ffiVoid_NSCachedURLResponse(ListenerBlock9 block) NS_RETURNS_RETAINED {
  return ^void(NSCachedURLResponse* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock10)(NSURLResponse* , NSData* , NSError* );
ListenerBlock10 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLResponse_NSData_NSError(ListenerBlock10 block) NS_RETURNS_RETAINED {
  return ^void(NSURLResponse* arg0, NSData* arg1, NSError* arg2) {
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock11)(NSDictionary* );
ListenerBlock11 wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary(ListenerBlock11 block) NS_RETURNS_RETAINED {
  return ^void(NSDictionary* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock12)(NSURLCredential* );
ListenerBlock12 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLCredential(ListenerBlock12 block) NS_RETURNS_RETAINED {
  return ^void(NSURLCredential* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock13)(NSArray* , NSArray* , NSArray* );
ListenerBlock13 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray_NSArray_NSArray(ListenerBlock13 block) NS_RETURNS_RETAINED {
  return ^void(NSArray* arg0, NSArray* arg1, NSArray* arg2) {
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock14)(NSArray* );
ListenerBlock14 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray1(ListenerBlock14 block) NS_RETURNS_RETAINED {
  return ^void(NSArray* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock15)(NSData* );
ListenerBlock15 wrapListenerBlock_ObjCBlock_ffiVoid_NSData(ListenerBlock15 block) NS_RETURNS_RETAINED {
  return ^void(NSData* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock16)(NSData* , BOOL , NSError* );
ListenerBlock16 wrapListenerBlock_ObjCBlock_ffiVoid_NSData_bool_NSError(ListenerBlock16 block) NS_RETURNS_RETAINED {
  return ^void(NSData* arg0, BOOL arg1, NSError* arg2) {
    block(objc_retain(arg0), arg1, objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock17)(NSURLSessionWebSocketMessage* , NSError* );
ListenerBlock17 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLSessionWebSocketMessage_NSError(ListenerBlock17 block) NS_RETURNS_RETAINED {
  return ^void(NSURLSessionWebSocketMessage* arg0, NSError* arg1) {
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock18)(NSData* , NSURLResponse* , NSError* );
ListenerBlock18 wrapListenerBlock_ObjCBlock_ffiVoid_NSData_NSURLResponse_NSError(ListenerBlock18 block) NS_RETURNS_RETAINED {
  return ^void(NSData* arg0, NSURLResponse* arg1, NSError* arg2) {
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock19)(NSURL* , NSURLResponse* , NSError* );
ListenerBlock19 wrapListenerBlock_ObjCBlock_ffiVoid_NSURL_NSURLResponse_NSError(ListenerBlock19 block) NS_RETURNS_RETAINED {
  return ^void(NSURL* arg0, NSURLResponse* arg1, NSError* arg2) {
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock20)(NSTask* );
ListenerBlock20 wrapListenerBlock_ObjCBlock_ffiVoid_NSTask(ListenerBlock20 block) NS_RETURNS_RETAINED {
  return ^void(NSTask* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock21)(BOOL , NSError* );
ListenerBlock21 wrapListenerBlock_ObjCBlock_ffiVoid_bool_NSError(ListenerBlock21 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, NSError* arg1) {
    block(arg0, objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock22)(HKAuthorizationRequestStatus , NSError* );
ListenerBlock22 wrapListenerBlock_ObjCBlock_ffiVoid_HKAuthorizationRequestStatus_NSError(ListenerBlock22 block) NS_RETURNS_RETAINED {
  return ^void(HKAuthorizationRequestStatus arg0, NSError* arg1) {
    block(arg0, objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock23)(BOOL , unsigned long , NSError* );
ListenerBlock23 wrapListenerBlock_ObjCBlock_ffiVoid_bool_ffiUnsignedLong_NSError(ListenerBlock23 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, unsigned long arg1, NSError* arg2) {
    block(arg0, arg1, objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock24)(HKQuantity* , HKQuantity* , NSError* );
ListenerBlock24 wrapListenerBlock_ObjCBlock_ffiVoid_HKQuantity_HKQuantity_NSError(ListenerBlock24 block) NS_RETURNS_RETAINED {
  return ^void(HKQuantity* arg0, HKQuantity* arg1, NSError* arg2) {
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^ListenerBlock25)(HKWorkoutSession* );
ListenerBlock25 wrapListenerBlock_ObjCBlock_ffiVoid_HKWorkoutSession(ListenerBlock25 block) NS_RETURNS_RETAINED {
  return ^void(HKWorkoutSession* arg0) {
    block(objc_retain(arg0));
  };
}

typedef void  (^ListenerBlock26)(HKWorkout* , NSError* );
ListenerBlock26 wrapListenerBlock_ObjCBlock_ffiVoid_HKWorkout_NSError(ListenerBlock26 block) NS_RETURNS_RETAINED {
  return ^void(HKWorkout* arg0, NSError* arg1) {
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock27)(HKWorkoutSession* , NSError* );
ListenerBlock27 wrapListenerBlock_ObjCBlock_ffiVoid_HKWorkoutSession_NSError(ListenerBlock27 block) NS_RETURNS_RETAINED {
  return ^void(HKWorkoutSession* arg0, NSError* arg1) {
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^ListenerBlock28)(NSDictionary* , NSError* );
ListenerBlock28 wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary_NSError1(ListenerBlock28 block) NS_RETURNS_RETAINED {
  return ^void(NSDictionary* arg0, NSError* arg1) {
    block(objc_retain(arg0), objc_retain(arg1));
  };
}
