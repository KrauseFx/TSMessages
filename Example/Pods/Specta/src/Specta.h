#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SpectaSupport.h"
#import "SPTXCTestCase.h"
#import "SPTSpec.h"
#import "SPTExampleGroup.h"
#import "SPTSharedExampleGroups.h"

@interface Specta : NSObject
@end

#define SpecBegin(name)    _SPTSpecBegin(name, __FILE__, __LINE__)
#define SpecEnd            _SPTSpecEnd

#define SharedExamplesBegin(name)      _SPTSharedExampleGroupsBegin(name)
#define SharedExamplesEnd              _SPTSharedExampleGroupsEnd
#define SharedExampleGroupsBegin(name) _SPTSharedExampleGroupsBegin(name)
#define SharedExampleGroupsEnd         _SPTSharedExampleGroupsEnd

#ifdef SPT_CEDAR_SYNTAX
#  define SPEC_BEGIN(name) SpecBegin(name)
#  define SPEC_END         SpecEnd
#  define SHARED_EXAMPLE_GROUPS_BEGIN(name) SharedExamplesBegin(name)
#  define SHARED_EXAMPLE_GROUPS_END         SharedExamplesEnd
#  ifndef PENDING
#    define PENDING nil
#  endif
#endif

void SPTdescribe(NSString *name, BOOL focused, void (^block)());
void    describe(NSString *name, void (^block)());
void   fdescribe(NSString *name, void (^block)());
void     context(NSString *name, void (^block)());
void    fcontext(NSString *name, void (^block)());

void SPTexample(NSString *name, BOOL focused, id block);
void    example(NSString *name, id block);
void   fexample(NSString *name, id block);
void         it(NSString *name, id block);
void        fit(NSString *name, id block);
void    specify(NSString *name, id block);
void   fspecify(NSString *name, id block);


void SPTpending(NSString *name, ...);
#define xdescribe(...) SPTpending(__VA_ARGS__, nil)
#define  xcontext(...) SPTpending(__VA_ARGS__, nil)
#define  xexample(...) SPTpending(__VA_ARGS__, nil)
#define       xit(...) SPTpending(__VA_ARGS__, nil)
#define  xspecify(...) SPTpending(__VA_ARGS__, nil)
#define   pending(...) SPTpending(__VA_ARGS__, nil)

void  beforeAll(id block);
void   afterAll(id block);
void beforeEach(id block);
void  afterEach(id block);
void     before(id block);
void      after(id block);

void sharedExamplesFor(NSString *name, void (^block)(NSDictionary *data));
void    sharedExamples(NSString *name, void (^block)(NSDictionary *data));

void SPTitShouldBehaveLike(const char *fileName, NSUInteger lineNumber, NSString *name, id dictionaryOrBlock);
void    itShouldBehaveLike(NSString *name, id dictionaryOrBlockOrNil); // aid code completion
void         itBehavesLike(NSString *name, id dictionaryOrBlockOrNil);
#define itShouldBehaveLike(...) SPTitShouldBehaveLike(__FILE__, __LINE__, __VA_ARGS__)
#define      itBehavesLike(...) SPTitShouldBehaveLike(__FILE__, __LINE__, __VA_ARGS__)

void setAsyncSpecTimeout(NSTimeInterval timeout);
#define AsyncBlock (void (^done)(void))
