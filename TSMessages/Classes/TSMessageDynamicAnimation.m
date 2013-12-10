//
//  TSMessageDynamicAnimation.m
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import "TSMessageDynamicAnimation.h"
#import "TSMessageView.h"

#define iOS7Enabled __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000

@interface TSMessageDynamicAnimation () <UIDynamicAnimatorDelegate>
#if iOS7Enabled
@property (nonatomic, strong) UIDynamicAnimator *animator;
#endif
@property (nonatomic, copy) void (^completionBlock)(void);

@end

@implementation TSMessageDynamicAnimation

static TSMessageDynamicAnimation *TSMessageDynamicAnimationInstance = nil;

+ (void)animateMessageView:(TSMessageView *)view toFrame:(CGRect)targetFrame appearing:(BOOL)isAppearing completion:(void (^)(void))completionBlock {
#if iOS7Enabled
    // currently only one animation per time is supported
    if (TSMessageDynamicAnimationInstance) {
        [TSMessageDynamicAnimationInstance stopAnimation];
        TSMessageDynamicAnimationInstance = nil;
    }
    if (isAppearing && [UIDynamicAnimator class]) {
        TSMessageDynamicAnimation *animationObject = [TSMessageDynamicAnimation new];
        animationObject.completionBlock = ^{
            if (completionBlock) {
                completionBlock();
            }
        };
        [animationObject animateView:view toFrame:targetFrame];
        TSMessageDynamicAnimationInstance = animationObject;
    } else {
        [super animateMessageView:view toFrame:targetFrame appearing:isAppearing completion:completionBlock];
    }
#else
    // fallback to super implementation
    [super animateMessageView:view toFrame:targetFrame appearing:isAppearing completion:completionBlock];
#endif

    
}

- (void)stopAnimation {
    [self.animator removeAllBehaviors];
    self.animator = nil;
}
#if iOS7Enabled

#pragma mark - Dynamics
- (void) animateView:(UIView*) view toFrame:(CGRect)targetFrame {
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:view.superview];
    animator.delegate = self;
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[view]];
    CGFloat boundaryY = CGRectGetMaxY(targetFrame);
    CGPoint fromPoint = CGPointMake(CGRectGetMinX(targetFrame), boundaryY);
    CGPoint toPoint = CGPointMake(CGRectGetMaxX(targetFrame), boundaryY);
    [collision addBoundaryWithIdentifier:@"bottom" fromPoint:fromPoint toPoint:toPoint];
    [animator addBehavior:collision];
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[view]];
    [animator addBehavior:gravity];
    self.animator = animator;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [animator removeAllBehaviors];
    self.animator = nil;
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = nil;
    }
}

#endif

@end
