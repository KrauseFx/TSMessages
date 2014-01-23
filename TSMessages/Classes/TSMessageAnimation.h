//
//  TSMessageAnimation.h
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import <Foundation/Foundation.h>

@class TSMessageView;
@protocol TSMessageViewAnimationProtocol <NSObject>

/**
 *  Animates a TSMessageView to the desired frame
 *
 *  @param view            view to transition
 *  @param targetFrame     target frame of the view
 *  @param isAppearing     YES for appearance animation NO fo disappearance
 *  @param completionBlock block that is called when the animation finishes
 */
+ (void)animateMessageView:(TSMessageView*)view
                   toFrame:(CGRect)targetFrame
                 appearing:(BOOL)isAppearing
                completion:(void(^)(void))completionBlock;

@end

/**
 *  Normal UIViewAnimation
 */
@interface TSMessageAnimation : NSObject <TSMessageViewAnimationProtocol>
+ (void) setAnimationDuration:(NSTimeInterval)animationDuration; // default = 0.3
+ (NSTimeInterval)animationDuration;
@end
