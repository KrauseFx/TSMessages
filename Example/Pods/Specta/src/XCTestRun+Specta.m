#import "XCTestRun+Specta.h"
#import "SPTXCTestCase.h"

@implementation XCTestRun (Specta)

#pragma mark - Pending Test Cases

- (NSUInteger)spt_pendingTestCaseCount {
  NSUInteger pendingTestCaseCount = 0;

  if ([self isKindOfClass:[XCTestSuiteRun class]]) {
    for (XCTestRun * testRun in [(XCTestSuiteRun *)self testRuns]) {
      pendingTestCaseCount += [testRun spt_pendingTestCaseCount];
    }
  } else if ([[self test] isKindOfClass:[SPTXCTestCase class]]) {
    SPTXCTestCase * testCase = (SPTXCTestCase *)[self test];
    if (testCase != nil && [testCase spt_isPending]) {
      pendingTestCaseCount++;
    }
  }

  return pendingTestCaseCount;
}

#pragma mark - Skipped Test Cases

- (NSUInteger)spt_skippedTestCaseCount {
  NSUInteger skippedTestCaseCount = 0;

  if ([self isKindOfClass:[XCTestSuiteRun class]]) {
    for (XCTestRun * testRun in [(XCTestSuiteRun *)self testRuns]) {
      skippedTestCaseCount += [testRun spt_skippedTestCaseCount];
    }
  } else if ([[self test] isKindOfClass:[SPTXCTestCase class]]) {
    SPTXCTestCase * testCase = (SPTXCTestCase *)[self test];
    if (testCase.spt_skipped) {
      skippedTestCaseCount++;
    }
  }

  return skippedTestCaseCount;
}

@end