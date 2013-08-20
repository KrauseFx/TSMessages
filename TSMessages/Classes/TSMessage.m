//
//  TSMessage.m
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageExtraDisplayTimePerPixel 0.04
#define kTSMessageAnimationDuration 0.3

@interface TSMessage ()

/** The queued messages (TSMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;

- (void)fadeInCurrentNotification;
- (void)fadeOutNotification:(TSMessageView *)currentView;

@end

@implementation TSMessage

static TSMessage *sharedMessages;
static BOOL notificationActive;

__weak static UIViewController *_defaultViewController;

+ (TSMessage *)sharedMessage
{
    if (!sharedMessages)
    {
        sharedMessages = [[[self class] alloc] init];
    }
    return sharedMessages;
}

+ (BOOL)isNotificationActive
{
    return notificationActive;
}

#pragma mark Methods to call from outside

+ (void)showNotificationWithMessage:(NSString *)message
                           withType:(TSMessageNotificationType)type
{
    [self showNotificationWithTitle:message withMessage:nil withType:type];
}

+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(TSMessageNotificationType)type
{
    [self showNotificationInViewController:[self defaultViewController]
                                 withTitle:title
                               withMessage:message
                                  withType:type];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
{
    [self showNotificationInViewController:viewController
                                 withTitle:title
                               withMessage:message
                                  withType:type
                              withDuration:0.0];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
{
    [self showNotificationInViewController:viewController
                                 withTitle:title
                               withMessage:message
                                  withType:type
                              withDuration:duration
                              withCallback:nil];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback
{
    [self showNotificationInViewController:viewController
                                 withTitle:title
                               withMessage:message
                                  withType:type
                              withDuration:duration
                              withCallback:callback
                                atPosition:TSMessageNotificationPositionTop];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback
                              atPosition:(TSMessageNotificationPosition)messagePosition
{
    [self showNotificationInViewController:viewController
                                 withTitle:title
                               withMessage:message
                                  withType:type
                              withDuration:duration
                              withCallback:callback
                           withButtonTitle:nil
                        withButtonCallback:nil
                                atPosition:messagePosition
                       canBeDismisedByUser:YES];
}


+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(TSMessageNotificationType)type
                            withDuration:(NSTimeInterval)duration
                            withCallback:(void (^)())callback
                         withButtonTitle:(NSString *)buttonTitle
                      withButtonCallback:(void (^)())buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                     canBeDismisedByUser:(BOOL)dismissingEnabled
{
    // Create the TSMessageView
    if(!viewController) viewController = [self defaultViewController];
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                withContent:message
                                                   withType:type
                                               withDuration:duration
                                           inViewController:viewController
                                               withCallback:callback
                                            withButtonTitle:buttonTitle
                                         withButtonCallback:buttonCallback
                                                 atPosition:messagePosition
                                          shouldBeDismissed:dismissingEnabled];
    [self showNotification:v];
}

+ (void)showNotification:(TSMessageView *)messageView
{
    NSString *title = messageView.title;
    NSString *content = messageView.content;

    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        if (([n.title isEqualToString:title] || (!n.title && !title)) && ([n.content isEqualToString:content] || (!n.content && !content)))
        {
            return; // avoid showing the same messages twice in a row
        }
    }
    
    [[TSMessage sharedMessage].messages addObject:messageView];
    
    if (!notificationActive)
    {
        [[TSMessage sharedMessage] fadeInCurrentNotification];
    }
}

#pragma mark Example uses

+ (void)showInternetError
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Network error", nil)
                             withMessage:NSLocalizedString(@"Couldn't connect to the server. Check your network connection.", nil)
                                withType:TSMessageNotificationTypeError];
}

+ (void)showLocationError
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Location error", nil)
                             withMessage:NSLocalizedString(@"Couldn't detect your current location.", nil)
                                withType:TSMessageNotificationTypeError];
}


#pragma mark Setting up of notification views

- (id)init
{
    if ((self = [super init]))
    {
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fadeInCurrentNotification
{
    if ([self.messages count] == 0) return;
    
    notificationActive = YES;
    
    TSMessageView *currentView = [self.messages objectAtIndex:0];
    
    CGFloat verticalOffset = 0.0f;
    
    if ([currentView.viewController isKindOfClass:[UINavigationController class]])
    {
        if (![(UINavigationController *)currentView.viewController isNavigationBarHidden])
        {
            [currentView.viewController.view insertSubview:currentView
                                              belowSubview:[(UINavigationController *)currentView.viewController navigationBar]];
            verticalOffset = [(UINavigationController *)currentView.viewController navigationBar].bounds.size.height;
            
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            {
                verticalOffset += [UIApplication sharedApplication].statusBarFrame.size.height;
            }
            else
            {
                verticalOffset += [UIApplication sharedApplication].statusBarFrame.size.width;
            }
        }
        else
        {
            [currentView.viewController.view addSubview:currentView];
        }
    }
    else
    {
        [currentView.viewController.view addSubview:currentView];
    }
    
    CGPoint toPoint;
    if (currentView.messagePosition == TSMessageNotificationPositionTop)
    {
        CGFloat navigationbarBottomOfViewController = 0;

        if (currentView.delegate && [currentView.delegate respondsToSelector:@selector(navigationbarBottomOfViewController:)])
            navigationbarBottomOfViewController = [currentView.delegate navigationbarBottomOfViewController:currentView.viewController];

        toPoint = CGPointMake(currentView.center.x,
                              navigationbarBottomOfViewController + verticalOffset + CGRectGetHeight(currentView.frame) / 2.0);
    }
    else
    {
        toPoint = CGPointMake(currentView.center.x,
                              currentView.viewController.view.bounds.size.height - CGRectGetHeight(currentView.frame) / 2.0);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         currentView.center = toPoint;
         currentView.alpha = TSMessageViewAlpha;
     } completion:^(BOOL finished) {
         currentView.messageIsFullyDisplayed = YES;
     }];
    
    
    if (currentView.duration == TSMessageNotificationDurationAutomatic)
    {
        currentView.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + currentView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }
    
    if (currentView.duration != TSMessageNotificationDurationEndless)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self performSelector:@selector(fadeOutNotification:)
                       withObject:currentView
                       afterDelay:currentView.duration];
        });
    }
}

#pragma mark Fading out

- (void)fadeOutNotification:(TSMessageView *)currentView
{
    currentView.messageIsFullyDisplayed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGPoint fadeOutToPoint;
    if (currentView.messagePosition == TSMessageNotificationPositionTop)
    {
        fadeOutToPoint = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame) / 2.0);;
    }
    else
    {
        fadeOutToPoint = CGPointMake(currentView.center.x,
                                     currentView.viewController.view.bounds.size.height);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         currentView.center = fadeOutToPoint;
         currentView.alpha = 0.0;
     }
                     completion:^(BOOL finished)
     {
         [currentView removeFromSuperview];
         
         if ([self.messages count] > 0)
         {
             [self.messages removeObjectAtIndex:0];
         }
         
         notificationActive = NO;
         
         if ([self.messages count] > 0)
         {
             [self fadeInCurrentNotification];
         }
     }];
}

+ (BOOL)dismissActiveNotification
{
    if ([[TSMessage sharedMessage].messages count] == 0) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        TSMessageView *currentMessage = [[TSMessage sharedMessage].messages objectAtIndex:0];
        if (currentMessage.messageIsFullyDisplayed)
        {
            [[TSMessage sharedMessage] fadeOutNotification:currentMessage];
        }
    });
    return YES;
}

#pragma mark Customizing TSMessages

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
    _defaultViewController = defaultViewController;
}

#pragma mark class Method to subclass

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;

    if(!defaultViewController) {
        NSLog(@"Attempted to present TSMessage in default view controller, but no default view controller was set. Use +[TSMessage setDefaultViewController:].");
    }
    return defaultViewController;
}

@end
