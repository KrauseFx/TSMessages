//
//  TSMessage.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageExtraDisplayTimePerPixel 0.04
#define kTSMessageAnimationDuration 0.3

@interface TSMessage ()

/** The queued messages (TSMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;

+ (UIViewController *)defaultViewController;


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


#pragma mark Public methods for setting up the notification

+ (void)showNotificationWithTitle:(NSString *)title
                             type:(TSMessageNotificationType)type
{
    [self showNotificationWithTitle:title
                           subtitle:nil
                               type:type];
}

+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(TSMessageNotificationType)type
{
    [self showNotificationInViewController:[self defaultViewController]
                                     title:title
                                  subtitle:subtitle
                                      type:type];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type
{
    [self showNotificationInViewController:viewController
                                     title:title
                                  subtitle:subtitle
                                      type:type
                                  duration:TSMessageNotificationDurationAutomatic
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                       canBeDismisedByUser:YES];
}


+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                                callback:(void (^)())callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)())buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                     canBeDismisedByUser:(BOOL)dismissingEnabled
{
    // Create the TSMessageView
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                   subtitle:subtitle
                                                       type:type
                                                   duration:duration
                                           inViewController:viewController
                                                   callback:callback
                                                buttonTitle:buttonTitle
                                             buttonCallback:buttonCallback
                                                 atPosition:messagePosition
                                          shouldBeDismissed:dismissingEnabled];
    [self prepareNotificatoinToBeShown:v];
}


+ (void)prepareNotificatoinToBeShown:(TSMessageView *)messageView
{
    NSString *title = messageView.title;
    NSString *subtitle = messageView.subtitle;
    
    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        if (([n.title isEqualToString:title] || (!n.title && !title)) && ([n.subtitle isEqualToString:subtitle] || (!n.subtitle && !subtitle)))
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


#pragma mark Fading in/out the message view

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

#pragma mark Other methods


+ (BOOL)isNotificationActive
{
    return notificationActive;
}

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if(!defaultViewController) {
        NSLog(@"Attempted to present TSMessage in default view controller, but no default view controller was set. Use +[TSMessage setDefaultViewController:].");
    }
    return defaultViewController;
}

@end
