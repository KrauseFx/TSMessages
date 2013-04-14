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

- (void)fadeInCurrentNotification;
- (void)fadeOutCurrentNotification;
- (void)startFadingOutWithDelay:(NSNumber *)delay;

@end

@implementation TSMessage

static TSMessage *sharedNotification;
static BOOL notificationActive;


+ (TSMessage *)sharedNotification
{
    if (!sharedNotification)
    {
        sharedNotification = [[[self class] alloc] init];
    }
    return sharedNotification;
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
    [[self sharedNotification] setViewController:viewController];
    [self showNotificationWithTitle:title withMessage:message withType:type];
}

+ (void)showNotificationWithTitle:(NSString *)title
                      withMessage:(NSString *)message
                         withType:(notificationType)type
{
    for (TSMessageView *n in [TSMessage sharedNotification].messages)
    {
        if ([n.title isEqualToString:title] && [n.content isEqualToString:message])
        {
            return; // avoid showing the same messages twice in a row
        }
    }

    // Create the TSMessageView
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                          withContent:message
                                                             withType:type];
    [[TSMessage sharedNotification].messages addObject:v];

    if (!notificationActive)
    {
        [[TSMessage sharedNotification] fadeInCurrentNotification];
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
    
    TSMessageView *currentView = [self.messages objectAtIndex:0];
    
    if (!self.viewController)
    {
        _viewController = [[self class] getViewController];
    }
    [self.viewController.view addSubview:currentView];
    
    [UIView animateWithDuration:TSMessageAnimationDuration animations:^
    {
        currentView.frame = CGRectMake(currentView.frame.origin.x,
                                       [[self class] navigationbarBottomOfViewController:self.viewController],
                                       currentView.frame.size.width,
                                       currentView.frame.size.height);
        currentView.alpha = TSMessageViewAlpha;
    }];
    
    [self performSelectorOnMainThread:@selector(startFadingOutWithDelay:)
                           withObject:[NSNumber numberWithFloat:TSMessageAnimationDuration + TSMessageDisplayTime + currentView.frame.size.height * TSMessageExtraDisplayTimePerPixel]
                        waitUntilDone:NO];
}

- (void)startFadingOutWithDelay:(NSNumber *)delay
{
    [self performSelector:@selector(fadeOutCurrentNotification)
               withObject:nil
               afterDelay:[delay floatValue]];
}

- (void)fadeOutCurrentNotification
{
    TSMessageView *currentView = [self.messages objectAtIndex:0];
    
    [UIView animateWithDuration:TSMessageAnimationDuration animations:^
    {
        currentView.frame = CGRectMake(currentView.frame.origin.x,
                                       -currentView.frame.size.height,
                                       currentView.frame.size.width,
                                       currentView.frame.size.height);
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
}

@end
