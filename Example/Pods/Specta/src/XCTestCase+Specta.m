#import "XCTestCase+Specta.h"
#import "SPTXCTestCase.h"
#import "SPTExample.h"
#import <objc/runtime.h>

@interface XCTestCase (xct_allSubclasses)

- (NSArray *)xct_allSubclasses;

@end

@implementation XCTestCase (Specta)

+ (void)load {
  Method xct_allSubclasses = class_getClassMethod(self, @selector(xct_allSubclasses));
  Method xct_allSubclasses_swizzle = class_getClassMethod(self, @selector(xct_allSubclasses_swizzle));
  method_exchangeImplementations(xct_allSubclasses, xct_allSubclasses_swizzle);
}

+ (NSArray *)xct_allSubclasses_swizzle {
  NSMutableArray *subclasses = [[self xct_allSubclasses_swizzle] mutableCopy]; // call original
  [subclasses removeObject:[SPTXCTestCase class]];
  return subclasses;
}

@end