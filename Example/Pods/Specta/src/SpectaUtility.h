#import <Foundation/Foundation.h>
extern NSString * const SPTCurrentSpecKey;
extern NSString * const SPTCurrentTestCaseKey;

#define SPTCurrentSpec     [[NSThread currentThread] threadDictionary][SPTCurrentSpecKey]
#define SPTCurrentTestCase [[NSThread currentThread] threadDictionary][SPTCurrentTestCaseKey]
#define SPTCurrentGroup    [SPTCurrentSpec currentGroup]
#define SPTGroupStack      [SPTCurrentSpec groupStack]

#define SPTReturnUnlessBlockOrNil(block) if ((block) && !SPTIsBlock((block))) return;
#define SPTIsBlock(obj) [(obj) isKindOfClass:NSClassFromString(@"NSBlock")]

const char *SPTGetBlockSignature(id blockObject);
BOOL SPTIsSpecClass(Class aClass);