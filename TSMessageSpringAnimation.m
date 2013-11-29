//
//  TSMessageSpringAnimation.m
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import "TSMessageSpringAnimation.h"
#import "TSMessageView.h"

@implementation TSMessageSpringAnimation
+ (void)animateMessageView:(TSMessageView *)view
                   toFrame:(CGRect)targetFrame
                 appearing:(BOOL)isAppearing
                completion:(void (^)(void))completionBlock {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    CGFloat damping = isAppearing ? 0.8 : 1.0;
    [UIView animateWithDuration:self.animationDuration
                          delay:0
         usingSpringWithDamping:damping
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.frame = targetFrame;
                     } completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
#else
    // fallback to super
    [super animateMessageView:view
                      toFrame:targetFrame
                 withDuration:duration
                    appearing:isAppearing
                   completion:completionBlock];
#endif
}

static NSTimeInterval TSMessageAnimationDuration = 0.4;
+ (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    TSMessageAnimationDuration = animationDuration;
}
+ (NSTimeInterval)animationDuration {
    return TSMessageAnimationDuration;
}

@end
