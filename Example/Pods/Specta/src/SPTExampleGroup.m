#import "SPTExampleGroup.h"
#import "SPTExample.h"
#import "SPTXCTestCase.h"
#import "SPTSpec.h"
#import "SpectaUtility.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static NSArray *ClassesWithClassMethod(SEL classMethodSelector) {
  NSMutableArray *classesWithClassMethod = [[NSMutableArray alloc] init];

  int numberOfClasses = objc_getClassList(NULL, 0);
  if (numberOfClasses > 0) {
    Class *classes = (Class *)malloc(sizeof(Class) *numberOfClasses);
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    for(int classIndex = 0; classIndex < numberOfClasses; classIndex++) {
      Class aClass = classes[classIndex];

      if (strcmp("UIAccessibilitySafeCategory__NSObject", class_getName(aClass))) {
        Method globalMethod = class_getClassMethod(aClass, classMethodSelector);
        if (globalMethod) {
          [classesWithClassMethod addObject:aClass];
        }
      }
    }

    free(classes);
  }

  return classesWithClassMethod;
}

@interface NSObject (SpectaGlobalBeforeAfterEach)

+ (void)beforeEach;
+ (void)afterEach;

@end

static NSTimeInterval asyncSpecTimeout = 10.0;
static const char *asyncBlockSignature = NULL;

static void runExampleBlock(id block, NSString *name) {
  if (!SPTIsBlock(block)) {
    return;
  }

  const char *blockSignature = SPTGetBlockSignature(block);

  BOOL isAsyncBlock = strcmp(blockSignature, asyncBlockSignature) == 0;

  if (isAsyncBlock) {
    __block uint32_t complete = 0;
    ((SPTAsyncBlock)block)(^{
      OSAtomicOr32Barrier(1, &complete);
    });
    NSTimeInterval timeout = asyncSpecTimeout;
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!complete && [timeoutDate timeIntervalSinceNow] > 0) {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    if (!complete) {
      NSString *message = [NSString stringWithFormat:@"\"%@\" failed to invoke done() callback before timeout (%f seconds)", name, timeout];
      SPTXCTestCase *currentTestCase = SPTCurrentTestCase;
      SPTSpec *spec = [[currentTestCase class] spt_spec];
      [currentTestCase recordFailureWithDescription:message inFile:spec.fileName atLine:spec.lineNumber expected:YES];
    }
  } else {
    ((SPTVoidBlock)block)();
  }
}

@interface SPTExampleGroup ()

- (void)incrementExampleCount;
- (void)resetRanExampleCountIfNeeded;
- (void)incrementRanExampleCount;
- (void)runBeforeHooks:(NSString *)compiledName;
- (void)runAfterHooks:(NSString *)compiledName;

@end

@implementation SPTExampleGroup

+ (void)initialize {
  if (asyncBlockSignature == NULL) {
    asyncBlockSignature = SPTGetBlockSignature(^(void (^done)(void)) {});
  }
}

- (id)init {
  self = [super init];
  if (self) {
    self.name = nil;
    self.root = nil;
    self.parent = nil;
    self.children = [NSMutableArray array];
    self.beforeAllArray = [NSMutableArray array];
    self.afterAllArray = [NSMutableArray array];
    self.beforeEachArray = [NSMutableArray array];
    self.afterEachArray = [NSMutableArray array];
    self.sharedExamples = [NSMutableDictionary dictionary];
    self.exampleCount = 0;
    self.ranExampleCount = 0;
  }
  return self;
}

+ (void)setAsyncSpecTimeout:(NSTimeInterval)timeout {
  asyncSpecTimeout = timeout;
}

- (id)initWithName:(NSString *)name parent:(SPTExampleGroup *)parent root:(SPTExampleGroup *)root {
  self = [self init];
  if (self) {
    self.name = name;
    self.parent = parent;
    self.root = root;
  }
  return self;
}

- (SPTExampleGroup *)addExampleGroupWithName:(NSString *)name {
  return [self addExampleGroupWithName:name
                               focused:NO];
}


- (SPTExampleGroup *)addExampleGroupWithName:(NSString *)name  focused:(BOOL)focused {
  SPTExampleGroup *group = [[SPTExampleGroup alloc] initWithName:name parent:self root:self.root];
  group.focused = focused;
  [self.children addObject:group];
  return group;
}

- (SPTExample *)addExampleWithName:(NSString *)name block:(id)block {
  return [self addExampleWithName:name
                            block:block
                          focused:NO];
}

- (SPTExample *)addExampleWithName:(NSString *)name block:(id)block focused:(BOOL)focused {
  SPTExample *example;
  @synchronized(self) {
    example = [[SPTExample alloc] initWithName:name block:block];
    example.focused = focused;
    [self.children addObject:example];
    [self incrementExampleCount];
  }
  return example;
}

- (void)incrementExampleCount {
  SPTExampleGroup *group = self;
  while (group != nil) {
    group.exampleCount ++;
    group = group.parent;
  }
}

- (void)resetRanExampleCountIfNeeded {
  SPTExampleGroup *group = self;
  while (group != nil) {
    if (group.ranExampleCount >= group.exampleCount) {
      group.ranExampleCount = 0;
    }
    group = group.parent;
  }
}

- (void)incrementRanExampleCount {
  SPTExampleGroup *group = self;
  while (group != nil) {
    group.ranExampleCount ++;
    group = group.parent;
  }
}

- (void)addBeforeAllBlock:(SPTVoidBlock)block {
  if (!block) return;
  [self.beforeAllArray addObject:[block copy]];
}

- (void)addAfterAllBlock:(SPTVoidBlock)block {
  if (!block) return;
  [self.afterAllArray addObject:[block copy]];
}

- (void)addBeforeEachBlock:(SPTVoidBlock)block {
  if (!block) return;
  [self.beforeEachArray addObject:[block copy]];
}

- (void)addAfterEachBlock:(SPTVoidBlock)block {
  if (!block) return;
  [self.afterEachArray addObject:[block copy]];
}

- (void)runGlobalBeforeEachHooks:(NSString *)compiledName {
  static NSArray *globalBeforeEachClasses;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    globalBeforeEachClasses = ClassesWithClassMethod(@selector(beforeEach));
  });

  for (Class class in globalBeforeEachClasses) {
    [class beforeEach];
  }
}

- (void)runGlobalAfterEachHooks:(NSString *)compiledName {
  static NSArray *globalAfterEachClasses;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    globalAfterEachClasses = ClassesWithClassMethod(@selector(afterEach));
  });

  for (Class class in globalAfterEachClasses) {
    [class afterEach];
  }
}

- (void)runBeforeHooks:(NSString *)compiledName {
  NSMutableArray *groups = [NSMutableArray array];
  SPTExampleGroup *group = self;
  while (group != nil) {
    [groups insertObject:group atIndex:0];
    group = group.parent;
  }

  // run beforeAll hooks
  for(group in groups) {
    if (group.ranExampleCount == 0) {
      for(id beforeAllBlock in group.beforeAllArray) {
        runExampleBlock(beforeAllBlock, [NSString stringWithFormat:@"%@ - before all block", compiledName]);
      }
    }
  }

  // run beforeEach hooks
  [self runGlobalBeforeEachHooks:compiledName];
  for(group in groups) {
    for(id beforeEachBlock in group.beforeEachArray) {
      runExampleBlock(beforeEachBlock, [NSString stringWithFormat:@"%@ - before each block", compiledName]);
    }
  }
}

- (void)runAfterHooks:(NSString *)compiledName {
  NSMutableArray *groups = [NSMutableArray array];
  SPTExampleGroup *group = self;
  while (group != nil) {
    [groups addObject:group];
    group = group.parent;
  }
  // run afterEach hooks
  for(group in groups) {
    for(id afterEachBlock in group.afterEachArray) {
      runExampleBlock(afterEachBlock, [NSString stringWithFormat:@"%@ - after each block", compiledName]);
    }
  }
  [self runGlobalAfterEachHooks:compiledName];

  // run afterAll hooks
  for(group in groups) {
    if (group.ranExampleCount == group.exampleCount) {
      for(id afterAllBlock in group.afterAllArray) {
        runExampleBlock(afterAllBlock, [NSString stringWithFormat:@"%@ - after all block", compiledName]);
      }
    }
  }
}

- (BOOL)isFocusedOrHasFocusedAncestor {
  SPTExampleGroup *ancestor = self;
  while (ancestor != nil) {
    if (ancestor.focused) {
      return YES;
    } else {
      ancestor = ancestor.parent;
    }
  }

  return NO;
}

- (NSArray *)compileExamplesWithNameStack:(NSArray *)nameStack {
  BOOL groupIsFocusedOrHasFocusedAncestor = [self isFocusedOrHasFocusedAncestor];

  NSArray *compiled = @[];
  for(id child in self.children) {
    if ([child isKindOfClass:[SPTExampleGroup class]]) {
      SPTExampleGroup *group = child;
      NSArray *newNameStack = [nameStack arrayByAddingObject:group.name];
      compiled = [compiled arrayByAddingObjectsFromArray:[group compileExamplesWithNameStack:newNameStack]];
    } else if ([child isKindOfClass:[SPTExample class]]) {
      SPTExample *example = child;
      NSArray *newNameStack = [nameStack arrayByAddingObject:example.name];
      NSString *compiledName = [newNameStack componentsJoinedByString:@" "];

      SPTVoidBlock compiledBlock = example.pending ? nil : ^{
        @synchronized(self.root) {
          [self resetRanExampleCountIfNeeded];
          [self runBeforeHooks:compiledName];
        }
        @try {
          runExampleBlock(example.block, compiledName);
        }
        @finally {
          @synchronized(self.root) {
            [self incrementRanExampleCount];
            [self runAfterHooks:compiledName];
          }
        }
      };
      SPTExample *compiledExample = [[SPTExample alloc] initWithName:compiledName block:compiledBlock];
      compiledExample.pending = example.pending;
      compiledExample.focused = (groupIsFocusedOrHasFocusedAncestor || example.focused);
      compiled = [compiled arrayByAddingObject:compiledExample];
    }
  }
  return compiled;
}

@end
