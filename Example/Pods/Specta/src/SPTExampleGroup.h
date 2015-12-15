#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SpectaTypes.h"

@class
  SPTExample
;

@interface SPTExampleGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) SPTExampleGroup *root;
@property (nonatomic, strong) SPTExampleGroup *parent;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableArray *beforeAllArray;
@property (nonatomic, strong) NSMutableArray *afterAllArray;
@property (nonatomic, strong) NSMutableArray *beforeEachArray;
@property (nonatomic, strong) NSMutableArray *afterEachArray;
@property (nonatomic, strong) NSMutableDictionary *sharedExamples;
@property (nonatomic) unsigned int exampleCount;
@property (nonatomic) unsigned int ranExampleCount;
@property (nonatomic, getter=isFocused) BOOL focused;

+ (void)setAsyncSpecTimeout:(NSTimeInterval)timeout;
- (id)initWithName:(NSString *)name parent:(SPTExampleGroup *)parent root:(SPTExampleGroup *)root;

- (SPTExampleGroup *)addExampleGroupWithName:(NSString *)name;
- (SPTExampleGroup *)addExampleGroupWithName:(NSString *)name  focused:(BOOL)focused;

- (SPTExample *)addExampleWithName:(NSString *)name block:(id)block;
- (SPTExample *)addExampleWithName:(NSString *)name block:(id)block focused:(BOOL)focused;

- (void)addBeforeAllBlock:(SPTVoidBlock)block;
- (void)addAfterAllBlock:(SPTVoidBlock)block;
- (void)addBeforeEachBlock:(SPTVoidBlock)block;
- (void)addAfterEachBlock:(SPTVoidBlock)block;

- (NSArray *)compileExamplesWithNameStack:(NSArray *)nameStack;

@end
