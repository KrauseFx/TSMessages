//
//  TSMessageSpringAnimation.h
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import "TSMessageAnimation.h"
/**
 *  A spring animation using the new UIViewAnimation-Method in iOS 7
 *  Falls back to superclass implementation when comiled with pre 7.0 SDK and is still called.
 */
NS_CLASS_AVAILABLE_IOS(7_0) @interface TSMessageSpringAnimation : TSMessageAnimation

+ (void) setAnimationDuration:(NSTimeInterval)animationDuration; // default = 0.4
+ (NSTimeInterval)animationDuration;
@end
