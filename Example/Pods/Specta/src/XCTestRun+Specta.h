#import <XCTest/XCTest.h>

@interface XCTestRun (Specta)

- (NSUInteger)spt_pendingTestCaseCount;
- (NSUInteger)spt_skippedTestCaseCount;

@end
