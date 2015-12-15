#import <XCTest/XCTest.h>

@interface SPTReporter : XCTestLog

/*
 * Returns a singleton reporter used to generate Specta's test output.
 * The type of reporter can be customized by subclassing and setting the
 * SPECTA_REPORTER_CLASS environment variable.
 *
 * Subclasses may override methods from XCTestObserver to change test output.
 * Initialization shuld be performed in the -startObserving / -stopObserving methods,
 * and MUST invoke the super class implementation.
 */
+ (instancetype)sharedReporter;

#pragma mark - Run Stack

@property (nonatomic, strong, readonly) NSArray *runStack;
@property (nonatomic, assign, readonly) NSUInteger runStackCount;

@property (nonatomic, assign, readonly) NSInteger numberOfTestCases;
@property (nonatomic, assign, readonly) NSInteger numberOfCompletedTestCases;

#pragma mark - Printing

- (void)printString:(NSString *)string;
- (void)printStringWithFormat:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2);

- (void)printLine;
- (void)printLine:(NSString *)line;
- (void)printLineWithFormat:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2);

@end
