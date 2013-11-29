//
//  TSMessageAnimation.m
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import "TSMessageAnimation.h"
#import "TSMessageView.h"

@implementation TSMessageAnimation
+ (void)animateMessageView:(TSMessageView *)view toFrame:(CGRect)targetFrame withDuration:(NSTimeInterval)duration appearing:(BOOL)isAppearing completion:(void (^)(void))completionBlock {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.frame = targetFrame;
                         view.alpha = isAppearing ? TSMessageViewAlpha : 0.f;
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}
@end
