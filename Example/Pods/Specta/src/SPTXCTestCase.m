#import "SPTXCTestCase.h"
#import "SPTSpec.h"
#import "SPTExample.h"
#import "SPTSharedExampleGroups.h"
#import "SpectaUtility.h"
#import <objc/runtime.h>

@implementation SPTXCTestCase

+ (void)initialize {
  [SPTSharedExampleGroups initialize];
  SPTSpec *spec = [[SPTSpec alloc] init];
  SPTXCTestCase *testCase = [[[self class] alloc] init];
  objc_setAssociatedObject(self, "spt_spec", spec, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [testCase spt_defineSpec];
  [spec compile];
  [super initialize];
}

+ (SPTSpec *)spt_spec {
  return objc_getAssociatedObject(self, "spt_spec");
}

+ (BOOL)spt_isDisabled {
  return [self spt_spec].disabled;
}

+ (void)spt_setDisabled:(BOOL)disabled {
  [self spt_spec].disabled = disabled;
}

- (BOOL)spt_isPending {
  SPTExample *example = [self spt_getCurrentExample];
  return example == nil || example.pending;
}

+ (NSArray *)spt_allSpecClasses {
  static NSArray *allSpecClasses = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    NSMutableArray *specClasses = [[NSMutableArray alloc] init];

    int numberOfClasses = objc_getClassList(NULL, 0);
    if (numberOfClasses > 0) {
      Class *classes = (Class *)malloc(sizeof(Class) * numberOfClasses);
      numberOfClasses = objc_getClassList(classes, numberOfClasses);

      for (int classIndex = 0; classIndex < numberOfClasses; classIndex++) {
        Class aClass = classes[classIndex];
        if (SPTIsSpecClass(aClass)) {
          [specClasses addObject:aClass];
        }
      }

      free(classes);
    }

    allSpecClasses = [specClasses copy];
  });

  return allSpecClasses;
}

+ (BOOL)spt_focusedExamplesExist {
  for (Class specClass in [self spt_allSpecClasses]) {
    SPTSpec *spec = [specClass spt_spec];
    if (spec.disabled == NO && [spec hasFocusedExamples]) {
      return YES;
    }
  }

  return NO;
}

- (void)spt_setCurrentSpecWithFileName:(const char *)fileName lineNumber:(NSUInteger)lineNumber {
  SPTSpec *spec = [[self class] spt_spec];
  spec.fileName = @(fileName);
  spec.lineNumber = lineNumber;
  [[NSThread currentThread] threadDictionary][SPTCurrentSpecKey] = spec;
}

- (void)spt_defineSpec {}

- (void)spt_unsetCurrentSpec {
  [[[NSThread currentThread] threadDictionary] removeObjectForKey:SPTCurrentSpecKey];
}

- (void)spt_runExampleAtIndex:(NSUInteger)index {
  [[NSThread currentThread] threadDictionary][SPTCurrentTestCaseKey] = self;
  SPTExample *compiledExample = ([[self class] spt_spec].compiledExamples)[index];
  if (!compiledExample.pending) {
    if ([[self class] spt_isDisabled] == NO &&
        (compiledExample.focused || [[self class] spt_focusedExamplesExist] == NO)) {
      ((SPTVoidBlock)compiledExample.block)();
    } else {
      self.spt_skipped = YES;
    }
  }

  [[[NSThread currentThread] threadDictionary] removeObjectForKey:SPTCurrentTestCaseKey];
}

- (SPTExample *)spt_getCurrentExample {
  if (!self.spt_invocation) {
    return nil;
  }
  NSUInteger i;
  [self.spt_invocation getArgument:&i atIndex:2];
  return ([[self class] spt_spec].compiledExamples)[i];
}

#pragma mark - XCTestCase overrides

+ (NSArray *)testInvocations {
  NSMutableArray *invocations = [NSMutableArray array];
  for(NSUInteger i = 0; i < [[self spt_spec].compiledExamples count]; i ++) {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:@selector(spt_runExampleAtIndex:)]];
    NSUInteger j = i;
    [invocation setSelector:@selector(spt_runExampleAtIndex:)];
    [invocation setArgument:&j atIndex:2];
    [invocations addObject:invocation];
  }
  return invocations;
}

- (void)setInvocation:(NSInvocation *)invocation {
  self.spt_invocation = invocation;
  [super setInvocation:invocation];
}

- (NSString *)name {
  NSString *specName = NSStringFromClass([self class]);
  SPTExample *compiledExample = [self spt_getCurrentExample];
  NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"];
  NSString *exampleName = [[compiledExample.name componentsSeparatedByCharactersInSet:[charSet invertedSet]] componentsJoinedByString:@"_"];
  return [NSString stringWithFormat:@"-[%@ %@]", specName, exampleName];
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected {
  SPTXCTestCase *currentTestCase = SPTCurrentTestCase;
  [currentTestCase.spt_run recordFailureInTest:currentTestCase withDescription:description inFile:filename atLine:lineNumber expected:expected];
}

- (void)performTest:(XCTestRun *)run {
  self.spt_run = (XCTestCaseRun *)run;
  [super performTest:run];
  self.spt_run = nil;
}

@end
