#import <XCTest/XCTest.h>
#import "XCTestCase+Specta.h"

@class
  SPTSpec
, SPTExample
;

@interface SPTXCTestCase : XCTestCase

@property (nonatomic, strong) NSInvocation *spt_invocation;
@property (nonatomic, strong) XCTestCaseRun *spt_run;
@property (nonatomic, assign) BOOL spt_skipped;
@property (nonatomic, assign, readonly, getter = spt_isPending) BOOL spt_pending;

+ (BOOL)spt_isDisabled;
+ (void)spt_setDisabled:(BOOL)disabled;
+ (BOOL)spt_focusedExamplesExist;

+ (SPTSpec *)spt_spec;
- (void)spt_setCurrentSpecWithFileName:(const char *)fileName lineNumber:(NSUInteger)lineNumber;
- (void)spt_defineSpec;
- (void)spt_unsetCurrentSpec;
- (void)spt_runExampleAtIndex:(NSUInteger)index;
- (SPTExample *)spt_getCurrentExample;

@end
