//
//  TSMessageDynamicAnimation.h
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import "TSMessageAnimation.h"

@interface TSMessageDynamicAnimation : TSMessageAnimation

+ (void)setGravityMagnitude:(CGFloat)magnitude; // default = 2.0
+ (CGFloat)gravityMagnitude;

+ (void)setItemElasticity:(CGFloat)elasticity; // default = 0.3
+ (CGFloat)itemElasticity;
@end
