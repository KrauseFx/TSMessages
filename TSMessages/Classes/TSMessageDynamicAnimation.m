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

static CGFloat TSMessageGravityMagnitude = 2.0;
+ (void)setGravityMagnitude:(CGFloat)magnitude {
    TSMessageGravityMagnitude = magnitude;
}
+ (CGFloat)gravityMagnitude {
    return TSMessageGravityMagnitude;
}
static CGFloat TSMessageItemElasticity = 0.3;
+ (void)setItemElasticity:(CGFloat)elasticity {
    TSMessageItemElasticity = elasticity;
}
+ (CGFloat)itemElasticity {
    return TSMessageItemElasticity;
}
#if iOS7Enabled

#pragma mark - Dynamics

- (void)animateView:(TSMessageView*) view toFrame:(CGRect)targetFrame {
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:view.superview];
    animator.delegate = self;
    
    NSArray *itemsArray = @[view];

    BOOL isTopAnimation = view.messagePosition == TSMessageNotificationPositionTop;
    CGFloat boundaryY = isTopAnimation ? CGRectGetMaxY(targetFrame) : CGRectGetMinY(targetFrame);
    CGPoint fromPoint = CGPointMake(CGRectGetMinX(targetFrame), boundaryY);
    CGPoint toPoint = CGPointMake(CGRectGetMaxX(targetFrame), boundaryY);

    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:itemsArray];
    [collision addBoundaryWithIdentifier:@"bottom" fromPoint:fromPoint toPoint:toPoint];
    [animator addBehavior:collision];
    
    CGFloat gravityY = isTopAnimation ? [[self class] gravityMagnitude] : - [[self class] gravityMagnitude];
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:itemsArray];
    gravity.gravityDirection = CGVectorMake(0, gravityY);
    [animator addBehavior:gravity];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:itemsArray];
    itemBehavior.elasticity = [[self class] itemElasticity];
    [animator addBehavior:itemBehavior];

    self.animator = animator;
}

- (void)stopAnimation {
    [self.animator removeAllBehaviors];
    self.animator = nil;
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
