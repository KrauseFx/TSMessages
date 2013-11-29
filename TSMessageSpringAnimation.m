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
              withDuration:(NSTimeInterval)duration
                 appearing:(BOOL)isAppearing
                completion:(void (^)(void))completionBlock {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    CGFloat damping = isAppearing ? 0.8 : 1.0;
    [UIView animateWithDuration:duration + 0.1
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
@end
