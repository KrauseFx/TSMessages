#import "SPTExample.h"

@implementation SPTExample

- (id)initWithName:(NSString *)name block:(id)block {
  self = [super init];
  if (self) {
    self.name = name;
    self.block = block;
    self.pending = block == nil;
  }
  return self;
}

@end

