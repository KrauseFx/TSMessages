#import "Specta.h"
#import "SpectaTypes.h"
#import "SpectaUtility.h"

@implementation Specta
@end

void SPTdescribe(NSString *name, BOOL focused, void (^block)()) {
  if (block) {
    [SPTGroupStack addObject:[SPTCurrentGroup addExampleGroupWithName:name focused:focused]];
    block();
    [SPTGroupStack removeLastObject];
  } else {
    SPTexample(name, focused, nil);
  }
}

void describe(NSString *name, void (^block)()) {
  SPTdescribe(name, NO, block);
}

void fdescribe(NSString *name, void (^block)()) {
  SPTdescribe(name, YES, block);
}

void context(NSString *name, void (^block)()) {
  SPTdescribe(name, NO, block);
}
void fcontext(NSString *name, void (^block)()) {
  SPTdescribe(name, YES, block);
}

void SPTexample(NSString *name, BOOL focused, id block) {
  SPTReturnUnlessBlockOrNil(block);
  [SPTCurrentGroup addExampleWithName:name block:block focused:focused];
}

void example(NSString *name, id block) {
  SPTexample(name, NO, block);
}

void fexample(NSString *name, id block) {
  SPTexample(name, YES, block);
}

void it(NSString *name, id block) {
  SPTexample(name, NO, block);
}

void fit(NSString *name, id block) {
  SPTexample(name, YES, block);
}

void specify(NSString *name, id block) {
  SPTexample(name, NO, block);
}

void fspecify(NSString *name, id block) {
  SPTexample(name, YES, block);
}

void SPTpending(NSString *name, ...) {
  SPTexample(name, NO, nil);
}

void beforeAll(id block) {
  SPTReturnUnlessBlockOrNil(block);
  [SPTCurrentGroup addBeforeAllBlock:block];
}

void afterAll(id block) {
  SPTReturnUnlessBlockOrNil(block);
  [SPTCurrentGroup addAfterAllBlock:block];
}

void beforeEach(id block) {
  SPTReturnUnlessBlockOrNil(block);
  [SPTCurrentGroup addBeforeEachBlock:block];
}

void afterEach(id block) {
  SPTReturnUnlessBlockOrNil(block);
  [SPTCurrentGroup addAfterEachBlock:block];
}

void before(id block) {
  beforeEach(block);
}

void after(id block) {
  afterEach(block);
}

void sharedExamplesFor(NSString *name, void (^block)(NSDictionary *data)) {
  [SPTSharedExampleGroups addSharedExampleGroupWithName:name block:block exampleGroup:SPTCurrentGroup];
}

void sharedExamples(NSString *name, void (^block)(NSDictionary *data)) {
  sharedExamplesFor(name, block);
}

void SPTitShouldBehaveLike(const char *fileName, NSUInteger lineNumber, NSString *name, id dictionaryOrBlock) {
  SPTDictionaryBlock block = [SPTSharedExampleGroups sharedExampleGroupWithName:name exampleGroup:SPTCurrentGroup];
  if (block) {
    if (SPTIsBlock(dictionaryOrBlock)) {
      id (^dataBlock)(void) = [dictionaryOrBlock copy];

      describe(name, ^{
        __block NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];

        beforeEach(^{
          NSDictionary *blockData = dataBlock();
          [dataDict removeAllObjects];
          [dataDict addEntriesFromDictionary:blockData];
        });

        block(dataDict);

        afterAll(^{
          dataDict = nil;
        });
      });
    } else {
      NSDictionary *data = dictionaryOrBlock;

      describe(name, ^{
        block(data);
      });
    }
  } else {
    SPTXCTestCase *currentTestCase = SPTCurrentTestCase;
    if (currentTestCase) {
      [currentTestCase recordFailureWithDescription:@"itShouldBehaveLike should not be invoked inside an example block!" inFile:@(fileName) atLine:lineNumber expected:NO];
    } else {
      it(name, ^{
        [currentTestCase recordFailureWithDescription:[NSString stringWithFormat:@"Shared example group \"%@\" does not exist.", name] inFile:@(fileName) atLine:lineNumber expected:NO];
      });
    }
  }
}

void setAsyncSpecTimeout(NSTimeInterval timeout) {
  [SPTExampleGroup setAsyncSpecTimeout:timeout];
}