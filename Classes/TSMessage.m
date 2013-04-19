//
//  TSMessage.m
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"

#define TSMessageDisplayTime 1.5
#define TSMessageExtraDisplayTimePerPixel 0.04

@interface TSMessage ()

/** The duration the notification should be displayed */
@property (assign, nonatomic) NSTimeInterval duration;

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
                           withType:(notificationType)type
{
    [self showNotificationWithTitle:message withMessage:nil withType:type];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(notificationType)type
{
    [[self sharedMessage] setViewController:viewController];
    [self showNotificationWithTitle:title withMessage:message withType:type];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                             withMessage:(NSString *)message
                                withType:(notificationType)type
                            withDuration:(NSTimeInterval)duration
{
    [[self sharedMessage] setDuration:duration];
    [[self sharedMessage] setViewController:viewController];
    [self showNotificationWithTitle:title withMessage:message withType:type];
}

+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(notificationType)type
{
    
    for (NSDictionary *n in [TSMessage sharedMessage].messages)
    {
        if ([[n objectForKey:@"title"] isEqualToString:title] && [[n objectForKey:@"message"] isEqualToString:message])
        {
            return; // avoid showing the same messages twice in a row
        }
    }
    
    NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:title, message, [NSNumber numberWithInt:type], nil]
                                                    forKeys:[NSArray arrayWithObjects:@"title", @"message", @"type", nil]];
    
    [[TSMessage sharedMessage].messages addObject:d];
    
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
                                withType:kNotificationError];
}

+ (void)showLocationError
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Location error", nil)
                             withMessage:NSLocalizedString(@"Couldn't detect your current location.", nil)
                                withType:kNotificationError];
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
    
    //    TSMessageView *currentView = [self.messages objectAtIndex:0];
    TSMessageView *currentView = [[TSMessageView alloc] initWithTitle:[[self.messages objectAtIndex:0] objectForKey:@"title"]
                                                          withContent:[[self.messages objectAtIndex:0] objectForKey:@"message"]
                                                             withType:[[[self.messages objectAtIndex:0] objectForKey:@"type"] intValue]];
    
    if (!self.viewController)
    {
        _viewController = [[self class] getViewController];
    }
    
    CGFloat verticalOffset = 0.0f;
    
    if ([self.viewController isKindOfClass:[UINavigationController class]])
    {
        if (![(UINavigationController *)self.viewController isNavigationBarHidden])
        {
            [self.viewController.view insertSubview:currentView belowSubview:[(UINavigationController *)self.viewController navigationBar]];
            verticalOffset = [(UINavigationController *)self.viewController navigationBar].bounds.size.height;
            
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
            [self.viewController.view addSubview:currentView];
        }
    }
    else
    {
        [self.viewController.view addSubview:currentView];
    }
    
    [UIView animateWithDuration:TSMessageAnimationDuration animations:^
     {
         currentView.center = CGPointMake(currentView.center.x,
                                          [[self class] navigationbarBottomOfViewController:self.viewController] + verticalOffset + CGRectGetHeight(currentView.frame) / 2.);
         currentView.alpha = TSMessageViewAlpha;
     }];
    
    NSTimeInterval duration = self.duration;
    
    if (duration == 0.0)
    {
        duration = TSMessageAnimationDuration + TSMessageDisplayTime + currentView.frame.size.height * TSMessageExtraDisplayTimePerPixel;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self performSelector:@selector(fadeOutNotification:) withObject:currentView afterDelay:duration];
                   });
}

- (void)fadeOutNotification:(TSMessageView *)currentView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutNotification:) object:currentView];
    
    [UIView animateWithDuration:TSMessageAnimationDuration animations:^
     {
         currentView.center = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame) / 2.);
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
         else
         {
             _viewController = nil;
         }
     }];
}

#pragma mark class Methods to subclass

+ (UIViewController *)getViewController
{
    return nil;
    // Implement this in subclass
}


+ (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 0;
    // Implement this in subclass
}

@end
