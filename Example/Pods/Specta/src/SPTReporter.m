#import "SPTReporter.h"
#import "SPTNestedReporter.h"
#import "XCTestLog+Specta.h"

@interface SPTReporter ()

@property (nonatomic, strong, readwrite) NSArray *runStack;
@property (nonatomic, assign, readwrite) NSInteger numberOfCompletedTestCases;

@end

@implementation SPTReporter

+ (instancetype)sharedReporter {
  static SPTReporter * sharedReporter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedReporter = [self loadSharedReporter];
  });

  return sharedReporter;
}

+ (SPTReporter *)loadSharedReporter {
  NSString * customReporterClassName = [[NSProcessInfo processInfo] environment][@"SPECTA_REPORTER_CLASS"];
  if (customReporterClassName != nil) {
    Class customReporterClass = NSClassFromString(customReporterClassName);
    if (customReporterClass != nil) {
      return [[customReporterClass alloc] init];
    }
  }

  return [[SPTNestedReporter alloc] init];
}

#pragma mark - Run Stack

- (NSUInteger)runStackCount {
  return self.runStack.count;
}

- (void)pushRunStack:(XCTestRun *)run {
  [(NSMutableArray *)self.runStack addObject:run];
}

- (void)popRunStack:(XCTestRun *)run {
  NSAssert(run != nil, @"Attempt to pop nil test run");

  NSAssert([self.runStack lastObject] == run,
           @"Attempt to pop test run (%@) out of order: %@",
           run,
           self.runStack);

  [(NSMutableArray *)self.runStack removeLastObject];
}

- (NSInteger)numberOfTestCases {
  XCTestRun * rootRun = self.runStack.firstObject;
  if (rootRun) {
    return rootRun.testCaseCount;
  } else {
    return 0;
  }
}

#pragma mark - Printing

- (void)printString:(NSString *)string {
  [[self logFileHandle] writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)printStringWithFormat:(NSString *)formatString, ... {
  va_list args;
  va_start(args, formatString);
  NSString * formattedString = [[NSString alloc] initWithFormat:formatString arguments:args];
  va_end(args);

  [self printString:formattedString];
}

- (void)printLine {
  [self printString:@"\n"];
}

- (void)printLine:(NSString *)line {
  [self printStringWithFormat:@"%@\n", line];
}

- (void)printLineWithFormat:(NSString *)formatString, ... {
  va_list args;
  va_start(args, formatString);
  NSString * formattedString = [[NSString alloc] initWithFormat:formatString arguments:args];
  va_end(args);

  [self printLine:formattedString];
}

#pragma mark - XCTestObserver

- (void)startObserving {
  [super startObserving];

  self.runStack = [[NSMutableArray alloc] init];
}

- (void)stopObserving {
  [super stopObserving];

  self.runStack = nil;
}

- (void)testSuiteDidStart:(XCTestRun *)testRun {
  [super testSuiteDidStart:testRun];
  [self pushRunStack:testRun];
}

- (void)testSuiteDidStop:(XCTestRun *)testRun {
  [super testSuiteDidStop:testRun];
  [self popRunStack:testRun];
}

- (void)testCaseDidStart:(XCTestRun *)testRun {
  [super testCaseDidStart:testRun];
  [self pushRunStack:testRun];
}

- (void)testCaseDidStop:(XCTestRun *)testRun {
  [super testCaseDidStop:testRun];
  [self popRunStack:testRun];

  self.numberOfCompletedTestCases++;
}

@end