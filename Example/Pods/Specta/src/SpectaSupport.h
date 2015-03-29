#ifndef SPT_SUBCLASS
#define SPT_SUBCLASS SPTXCTestCase
#endif



#define _SPTSpecBegin(name, file, line) \
@interface name##Spec : SPT_SUBCLASS \
@end \
@implementation name##Spec \
- (void)spt_defineSpec { \
  const char *specFileName = file; \
  @try { \
    [self spt_setCurrentSpecWithFileName:(file) lineNumber:(line)];

#define _SPTSpecEnd \
    [self spt_unsetCurrentSpec]; \
  } @catch(NSException *exception) { \
    fprintf(stderr, "%s: An exception has occured outside of tests, aborting.\n\n%s (%s) \n", specFileName, [[exception name] UTF8String], [[exception reason] UTF8String]); \
    if ([exception respondsToSelector:@selector(callStackSymbols)]) { \
      NSArray *callStackSymbols = [exception callStackSymbols]; \
      if (callStackSymbols) { \
        NSString *callStack = [NSString stringWithFormat:@"\n  Call Stack:\n    %@\n", [callStackSymbols componentsJoinedByString:@"\n    "]]; \
        fprintf(stderr, "%s", [callStack UTF8String]); \
      } \
    } \
    exit(1); \
  } \
} \
@end

#define _SPTSharedExampleGroupsBegin(name) \
@interface name##SharedExampleGroups : SPTSharedExampleGroups \
@end \
@implementation name##SharedExampleGroups \
+ (void)defineSharedExampleGroups {

#define _SPTSharedExampleGroupsEnd \
} \
@end

#undef _XCTRegisterFailure
#define _XCTRegisterFailure(condition, format...) \
({ \
_XCTFailureHandler((id)self, YES, __FILE__, __LINE__, condition, @"" format); \
})