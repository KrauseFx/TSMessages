#import <XCTest/XCTest.h>

@interface XCTestLog (Specta)

- (void)spt_pauseObservationInBlock:(void (^)(void))block;

@end
