#import "SPTNestedReporter.h"
#import "XCTestRun+Specta.h"

@interface SPTNestedReporter ()

@property (readwrite, assign, nonatomic) NSInteger nestingLevel;
@property (readwrite, assign, nonatomic) BOOL indentationEnabled;

@end

@implementation SPTNestedReporter

#pragma mark - Printing

- (NSString *)indentation {
  // XCode does not strip whitespace from the beginning of lines that report an error. Indentation should only enabled for non-error text.

  if (self.indentationEnabled) {
    return [@"" stringByPaddingToLength:(self.nestingLevel * 2)
                             withString:@" "
                        startingAtIndex:0];
  } else {
    return @"";
  }
}

- (void)withIndentationEnabled:(void(^)(void))block {
  [self withIndentationEnabled:YES block:block];
}

- (void)withIndentationEnabled:(BOOL)indentationEnabled block:(void(^)(void))block {
  BOOL originalValue = self.indentationEnabled;

  self.indentationEnabled = indentationEnabled;
  @try {
    block();
  } @finally {
    self.indentationEnabled = originalValue;
  }
}

- (void)printIndentation {
  [self printString:self.indentation];
}

- (void)printTestSuiteHeader:(XCTestRun *)testRun {
  [self printIndentation];
  [self printLineWithFormat:@"= %@", testRun.test.name];
}

- (void)printTestSuiteFooter:(XCTestRun *)testRun {
  [self printIndentation];
  [self printLine];

  if (self.nestingLevel == 0) {
    [self printConciseSummaryOfTestRun:testRun];
  }
}

- (void)printConciseSummaryOfTestRun:(XCTestRun *)testRun {
  NSUInteger numberOfTests = testRun.testCaseCount;
  NSUInteger numberOfFailures = testRun.totalFailureCount;
  NSUInteger numberOfExceptions = testRun.unexpectedExceptionCount;
  NSUInteger numberOfSkippedTests = testRun.spt_skippedTestCaseCount;
  NSUInteger numberOfPendingTests = testRun.spt_pendingTestCaseCount;

  NSString * runInfo = [[self class] conciseRunInfoWithNumberOfTests:numberOfTests
                                                numberOfSkippedTests:numberOfSkippedTests
                                                    numberOfFailures:numberOfFailures
                                                  numberOfExceptions:numberOfExceptions
                                                numberOfPendingTests:numberOfPendingTests];

  [self printIndentation];
  [self printLine:runInfo];
}

- (void)printTestCaseHeader:(XCTestRun *)testRun {
  [self printIndentation];
  [self printLineWithFormat:@"%@", testRun.test.name];
}

- (void)printTestCaseFooter:(XCTestRun *)testRun {
  [self printIndentation];
  [self printLine];
}

+ (NSString *)pluralizeString:(NSString *)singularString
                 pluralString:(NSString *)pluralString
                        count:(NSInteger)count {
  return (count == 1 || count == -1) ? singularString : pluralString;
}

+ (NSString *)conciseRunInfoWithNumberOfTests:(NSUInteger)numberOfTests
                         numberOfSkippedTests:(NSUInteger)numberOfSkippedTests
                             numberOfFailures:(NSUInteger)numberOfFailures
                           numberOfExceptions:(NSUInteger)numberOfExceptions
                         numberOfPendingTests:(NSUInteger)numberOfPendingTests {
  NSString * testLabel = [[self class] pluralizeString:@"test"
                                          pluralString:@"tests"
                                                 count:numberOfTests];

  NSString * failureLabel = [[self class] pluralizeString:@"failure"
                                             pluralString:@"failures"
                                                    count:numberOfFailures];

  NSString * exceptionLabel = [[self class] pluralizeString:@"exception"
                                               pluralString:@"exceptions"
                                                      count:numberOfExceptions];

  return [NSString stringWithFormat:@"%lu %@; %lu skipped; %lu %@; %lu %@; %lu pending",
                                    (unsigned long)numberOfTests,
                                    testLabel,
                                    (unsigned long)numberOfSkippedTests,
                                    (unsigned long)numberOfFailures,
                                    failureLabel,
                                    (unsigned long)numberOfExceptions,
                                    exceptionLabel,
                                    (unsigned long)numberOfPendingTests];
}

#pragma mark - XCTestObserver

- (void)startObserving {
  [super startObserving];

  self.nestingLevel = 0;
}

- (void)testSuiteDidStart:(XCTestRun *)testRun {
  [self withIndentationEnabled:^{

    [self printTestSuiteHeader:testRun];
    self.nestingLevel ++;

    [super testSuiteDidStart:testRun];
    [self printLine];

  }];
}

- (void)testSuiteDidStop:(XCTestRun *)testRun {
  [self withIndentationEnabled:^{

    [super testSuiteDidStop:testRun];

    self.nestingLevel --;
    [self printTestSuiteFooter:testRun];

  }];
}

- (void)testCaseDidStart:(XCTestRun *)testRun {
  [self withIndentationEnabled:^{

    [self printTestCaseHeader:testRun];
    self.nestingLevel ++;

    [super testCaseDidStart:testRun];

  }];
}

- (void)testCaseDidStop:(XCTestRun *)testRun {
  [self withIndentationEnabled:^{

    [super testCaseDidStop:testRun];

    self.nestingLevel --;
    [self printTestCaseFooter:testRun];

  }];
}

- (void)testLogWithFormat:(NSString *)format arguments:(va_list)arguments {
  NSString * indentation = self.indentation;

  NSMutableString * indentedFormat = [[NSMutableString alloc] initWithString:format];
  [indentedFormat insertString:indentation atIndex:0];

  NSRange replacementRange = NSMakeRange(0, [indentedFormat length]);
  if ([indentedFormat hasSuffix:@"\n"]) {
    replacementRange.length -= [@"\n" length];
  }

  [indentedFormat replaceOccurrencesOfString:@"\n"
                                  withString:[@"\n" stringByAppendingString:indentation]
                                     options:0
                                       range:replacementRange];

  [super testLogWithFormat:indentedFormat
                 arguments:arguments];
}

@end
