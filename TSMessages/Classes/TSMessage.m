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

- (void)fadeInCurrentNotification;
- (void)fadeOutCurrentNotification;

@end

@implementation TSMessage

static TSMessage *sharedMessages;
static BOOL notificationActive;

static BOOL _useiOS7Style;


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
                                     image:nil
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
                                   image:(UIImage *)image
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                                callback:(TSMessageCallback)callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(TSMessageCallback)buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                     canBeDismisedByUser:(BOOL)dismissingEnabled
{
    // Create the TSMessageView
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                   subtitle:subtitle
                                                      image:image
                                                       type:type
                                                   duration:duration
                                           inViewController:viewController
                                                   callback:callback
                                                buttonTitle:buttonTitle
                                             buttonCallback:buttonCallback
                                                 atPosition:messagePosition
                                          shouldBeDismissed:dismissingEnabled];
    [self prepareNotificationToBeShown:v];
}

+ (TSMessageView *)showPermanentNotificationInViewController:(UIViewController *)viewController
                                                       title:(NSString *)title
                                                    subtitle:(NSString *)subtitle
                                                       image:(UIImage *)image
                                                        type:(TSMessageNotificationType)type
                                                    callback:(TSMessageCallback)callback
                                                 buttonTitle:(NSString *)buttonTitle
                                              buttonCallback:(TSMessageCallback)buttonCallback
                                                  atPosition:(TSMessageNotificationPosition)messagePosition
                                        canBeDismissedByUser:(BOOL)dismissingEnabled {
    TSMessageView *v = [[TSMessageView alloc] initWithTitle:title
                                                   subtitle:subtitle
                                                      image:image
                                                       type:type
                                                   duration:TSMessageNotificationDurationEndless
                                           inViewController:viewController
                                                   callback:callback
                                                buttonTitle:buttonTitle
                                             buttonCallback:buttonCallback
                                                 atPosition:messagePosition
                                          shouldBeDismissed:dismissingEnabled];
    
    [[TSMessage sharedMessage] fadeInNotification:v];
    
    return v;
}


+ (void)prepareNotificationToBeShown:(TSMessageView *)messageView
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

- (TSMessageView *)currentNotification {
    if ([self.messages count] > 0)
    {
        return [self.messages objectAtIndex:0];
    }

    return nil;
}

- (void)fadeInCurrentNotification
{
    if (!self.currentNotification) return;
    
    notificationActive = YES;
    
    [self fadeInNotification:self.currentNotification];
}

- (void)fadeInNotification:(TSMessageView *)messageView
{
    __block CGFloat verticalOffset = 0.0f;
    
    void (^addStatusBarHeightToVerticalOffset)() = ^void() {
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
        CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
        CGFloat offset = isPortrait ? statusBarSize.height : statusBarSize.width;
        verticalOffset += offset;
    };
    
    if ([messageView.viewController isKindOfClass:[UINavigationController class]] || [messageView.viewController.parentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *currentNavigationController;
        
        if([messageView.viewController isKindOfClass:[UINavigationController class]])
            currentNavigationController = (UINavigationController *)messageView.viewController;
        else
            currentNavigationController = (UINavigationController *)messageView.viewController.parentViewController;
            
        BOOL isViewIsUnderStatusBar = [[[currentNavigationController childViewControllers] firstObject] wantsFullScreenLayout];
        if (!isViewIsUnderStatusBar && currentNavigationController.parentViewController == nil) {
            isViewIsUnderStatusBar = ![currentNavigationController isNavigationBarHidden]; // strange but true
        }
        if (![currentNavigationController isNavigationBarHidden])
        {
            [currentNavigationController.view insertSubview:messageView
                                               belowSubview:[currentNavigationController navigationBar]];
            verticalOffset = [currentNavigationController navigationBar].bounds.size.height;
            if ([TSMessage iOS7StyleEnabled] || isViewIsUnderStatusBar) {
                addStatusBarHeightToVerticalOffset();
            }
        }
        else
        {
            [messageView.viewController.view addSubview:messageView];
            if ([TSMessage iOS7StyleEnabled] || isViewIsUnderStatusBar) {
                addStatusBarHeightToVerticalOffset();
            }
        }
    }
    else
    {
        [messageView.viewController.view addSubview:messageView];
        if ([TSMessage iOS7StyleEnabled]) {
            addStatusBarHeightToVerticalOffset();
        }
    }
    
    CGPoint toPoint;
    if (messageView.messagePosition == TSMessageNotificationPositionTop)
    {
        CGFloat navigationbarBottomOfViewController = 0;
        
        if (messageView.delegate && [messageView.delegate respondsToSelector:@selector(navigationbarBottomOfViewController:)])
            navigationbarBottomOfViewController = [messageView.delegate navigationbarBottomOfViewController:messageView.viewController];
        
        toPoint = CGPointMake(messageView.center.x,
                              navigationbarBottomOfViewController + verticalOffset + CGRectGetHeight(messageView.frame) / 2.0);
    }
    else
    {
        CGFloat y = messageView.viewController.view.bounds.size.height - CGRectGetHeight(messageView.frame) / 2.0;
        if (!messageView.viewController.navigationController.isToolbarHidden) {
            y -= CGRectGetHeight(messageView.viewController.navigationController.toolbar.bounds);
        }
        toPoint = CGPointMake(messageView.center.x, y);
    }

    dispatch_block_t animationBlock = ^{
        messageView.center = toPoint;
        if (![TSMessage iOS7StyleEnabled]) {
            messageView.alpha = TSMessageViewAlpha;
        }
    };
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
        messageView.messageIsFullyDisplayed = YES;
    };
    
    if (![TSMessage iOS7StyleEnabled]) {
        [UIView animateWithDuration:kTSMessageAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:animationBlock
                         completion:completionBlock];
    } else {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        [UIView animateWithDuration:kTSMessageAnimationDuration + 0.1
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:animationBlock
                         completion:completionBlock];
        #endif
    }
    
    if (messageView.duration == TSMessageNotificationDurationAutomatic)
    {
        messageView.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + messageView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }
    
    if (messageView.duration != TSMessageNotificationDurationEndless)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self performSelector:@selector(fadeOutCurrentNotification)
                                      withObject:nil
                                      afterDelay:messageView.duration];
                       });
    }
}

- (void)fadeOutNotification:(TSMessageView *)messageView
{
    [self fadeOutNotification:messageView completion:NULL];
}

- (void)fadeOutNotification:(TSMessageView *)messageView completion:(void (^)())completion
{
    messageView.messageIsFullyDisplayed = NO;
    
    CGPoint fadeOutToPoint;
    if (messageView.messagePosition == TSMessageNotificationPositionTop)
    {
        fadeOutToPoint = CGPointMake(messageView.center.x, -CGRectGetHeight(messageView.frame)/2.f);
    }
    else
    {
        fadeOutToPoint = CGPointMake(messageView.center.x,
                                     messageView.viewController.view.bounds.size.height + CGRectGetHeight(messageView.frame)/2.f);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         messageView.center = fadeOutToPoint;
         if (![TSMessage iOS7StyleEnabled]) {
             messageView.alpha = 0.f;
         }
     } completion:^(BOOL finished)
     {
         [messageView removeFromSuperview];
         
         if (completion) {
             completion();
         }
     }];
}

- (void)fadeOutCurrentNotification
{
    if (!self.currentNotification) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutCurrentNotification)
                                               object:nil];
    
    [self fadeOutNotification:self.currentNotification completion:^{
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
    if (![TSMessage sharedMessage].currentNotification) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[TSMessage sharedMessage] fadeOutCurrentNotification];
                   });
    return YES;
}

#pragma mark Customizing TSMessages

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
    _defaultViewController = defaultViewController;
}

+ (void)addCustomDesignFromFileWithName:(NSString *)fileName
{
    [TSMessageView addNotificationDesignFromFile:fileName];
}


#pragma mark Other methods


+ (BOOL)isNotificationActive
{
    return notificationActive;
}

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if (!defaultViewController) {
        NSLog(@"TSMessages: It is recommended to set a custom defaultViewController that is used to display the notifications");
        defaultViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return defaultViewController;
}

+ (BOOL)iOS7StyleEnabled
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Decide wheter to use iOS 7 style or not based on the running device and the base sdk
        BOOL iOS7SDK = NO;
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            iOS7SDK = YES;
        #endif
        
        _useiOS7Style = ! (TS_SYSTEM_VERSION_LESS_THAN(@"7.0") || !iOS7SDK);
    });
    return _useiOS7Style;
}

@end
