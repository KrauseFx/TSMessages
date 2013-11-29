//
//  TSMessageAnimation.h
//  Pods
//
//  Created by Tobias Conradi on 29.11.13.
//
//

#import <Foundation/Foundation.h>
@class TSMessageView;

/**
 *  A animation class which allows different transition-types via subclassing.
 */
@interface TSMessageAnimation : NSObject
/**
 *  Animates a TSMessageView to the desired frame
 *
 *  @param view            view to transition
 *  @param targetFrame     target frame of the view
 *  @param duration        animation duration (can be ignored by subclasses)
 *  @param isAppearing     YES for appearance animation NO fo disappearance
 *  @param completionBlock block that is called when the animation finishes
 */
+ (void)animateMessageView:(TSMessageView*)view toFrame:(CGRect)targetFrame withDuration:(NSTimeInterval)duration appearing:(BOOL)isAppearing completion:(void(^)(void))completionBlock;

@end
