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


+ (TSMessage *)sharedMessage
{
    if (!sharedMessages)
    {
        sharedMessages = [[[self class] alloc] init];
    }
    return sharedMessages;
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
    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        if ([n.title isEqualToString:title] && [n.content isEqualToString:message])
        {
            return; // avoid showing the same messages twice in a row
        }
    }
    
    // Create the TSMessageView
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                withContent:message
                                                   withType:type
                                               withDuration:duration
                                           inViewController:viewController
                                               withCallback:callback
                                                 atPosition:messagePosition];
    
    [[TSMessage sharedMessage].messages addObject:v];
    
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
    if (currentView.messsagePosition == TSMessageNotificationPositionTop)
    {
        toPoint = CGPointMake(currentView.center.x,
                              [[self class] navigationbarBottomOfViewController:currentView.viewController] + verticalOffset + CGRectGetHeight(currentView.frame) / 2.0);
    }
    else
    {
        toPoint = CGPointMake(currentView.center.x,
                              currentView.viewController.view.frame.size.height - CGRectGetHeight(currentView.frame) / 2.0);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         currentView.center = toPoint;
         currentView.alpha = TSMessageViewAlpha;
     }];
    
    
    if (currentView.duration == 0.0)
    {
        currentView.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + currentView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self performSelector:@selector(fadeOutNotification:)
                   withObject:currentView
                   afterDelay:currentView.duration];
    });
}

- (void)fadeOutNotification:(TSMessageView *)currentView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGPoint fadeOutToPoint;
    if (currentView.messsagePosition == TSMessageNotificationPositionTop)
    {
        fadeOutToPoint = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame) / 2.0);;
    }
    else
    {
        fadeOutToPoint = CGPointMake(currentView.center.x,
                                     currentView.viewController.view.frame.size.height);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         currentView.center = fadeOutToPoint;
         currentView.alpha = 0.0;
     }
                     completion:^(BOOL finished)
     {
         [currentView removeFromSuperview];
         
         [self.messages removeObjectAtIndex:0];
         notificationActive = NO;
         
         if ([self.messages count] > 0)
         {
             [self fadeInCurrentNotification];
         }
     }];
}

#pragma mark class Methods to subclass

+ (UIViewController *)defaultViewController
{
    NSLog(@"No view controller was set as parameter and TSMessage was not subclassed. If you want to subclass, implement defaultViewController to set the default viewController.");
    return nil;
    // Implement this in subclass
}


+ (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 0;
    // Implement this in subclass
}

@end
