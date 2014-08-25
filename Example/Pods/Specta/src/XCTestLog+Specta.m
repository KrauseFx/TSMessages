#import "XCTestLog+Specta.h"
#import "SPTReporter.h"
#import <objc/runtime.h>

static void spt_swizzleInstanceMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

  method_exchangeImplementations(originalMethod, swizzledMethod);
}

@implementation XCTestLog (Specta)

+ (void)load {
  spt_swizzleInstanceMethod(self, @selector(startObserving), @selector(XCTestLog_startObserving));
  spt_swizzleInstanceMethod(self, @selector(stopObserving), @selector(XCTestLog_stopObserving));
}

- (BOOL)spt_shouldProxyToSPTReporter {
  // Instances of XCTestLog (but not subclasses) simply forward to -[SPTReporter sharedReporter]
  return [self isMemberOfClass:[XCTestLog class]];
}

- (void)spt_pauseObservationInBlock:(void (^)(void))block {
  [self XCTestLog_stopObserving];
  block();
  [self XCTestLog_startObserving];
}

#pragma mark - XCTestObserver

- (void)XCTestLog_startObserving {
  if ([self spt_shouldProxyToSPTReporter]) {
    [[SPTReporter sharedReporter] startObserving];
  } else {
    [self XCTestLog_startObserving];
  }
}

- (void)XCTestLog_stopObserving {
  if ([self spt_shouldProxyToSPTReporter]) {
    [[SPTReporter sharedReporter] stopObserving];
  } else {
    [self XCTestLog_stopObserving];
    usleep(100000);
  }
}

@end
