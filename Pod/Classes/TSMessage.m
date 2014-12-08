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

@end

@implementation TSMessage
static TSMessage *sharedMessage;
static BOOL notificationActive;

static BOOL _useiOS7Style;


__weak static UIViewController *_defaultViewController;

+ (TSMessage *)sharedMessage
{
    if (!sharedMessage)
    {
        sharedMessage = [[[self class] alloc] init];
    }
    return sharedMessage;
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
                                duration:(NSTimeInterval)duration
{
    [self showNotificationInViewController:viewController
                                     title:title
                                  subtitle:subtitle
                                     image:nil
                                      type:type
                                  duration:duration
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                       canBeDismissedByUser:YES];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                     canBeDismissedByUser:(BOOL)dismissingEnabled
{
    [self showNotificationInViewController:viewController
                                     title:title
                                  subtitle:subtitle
                                     image:nil
                                      type:type
                                  duration:duration
                                  callback:nil
                               buttonTitle:nil
                            buttonCallback:nil
                                atPosition:TSMessageNotificationPositionTop
                       canBeDismissedByUser:dismissingEnabled];
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
                      canBeDismissedByUser:YES];
}


+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                   image:(UIImage *)image
                                    type:(TSMessageNotificationType)type
                                duration:(NSTimeInterval)duration
                                callback:(void (^)())callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)())buttonCallback
                              atPosition:(TSMessageNotificationPosition)messagePosition
                    canBeDismissedByUser:(BOOL)dismissingEnabled
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
                                       canBeDismissedByUser:dismissingEnabled];
    [self prepareNotificationToBeShown:v];
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

- (void)fadeInCurrentNotification
{
    if ([self.messages count] == 0) return;
    
    notificationActive = YES;
    
    TSMessageView *currentView = [self.messages objectAtIndex:0];
    
    __block CGFloat verticalOffset = 0.0f;
    
    void (^addStatusBarHeightToVerticalOffset)() = ^void() {
        
        if (currentView.messagePosition == TSMessageNotificationPositionNavBarOverlay){
            return;
        }
        
        CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
        verticalOffset += MIN(statusBarSize.width, statusBarSize.height);
    };
    
    if ([currentView.viewController isKindOfClass:[UINavigationController class]] || [currentView.viewController.parentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *currentNavigationController;
        
        if([currentView.viewController isKindOfClass:[UINavigationController class]])
            currentNavigationController = (UINavigationController *)currentView.viewController;
        else
            currentNavigationController = (UINavigationController *)currentView.viewController.parentViewController;
        
        BOOL isViewIsUnderStatusBar = [[[currentNavigationController childViewControllers] firstObject] wantsFullScreenLayout];
        if (!isViewIsUnderStatusBar && currentNavigationController.parentViewController == nil) {
            isViewIsUnderStatusBar = ![TSMessage isNavigationBarInNavigationControllerHidden:currentNavigationController]; // strange but true
        }
        if (![TSMessage isNavigationBarInNavigationControllerHidden:currentNavigationController] && currentView.messagePosition != TSMessageNotificationPositionNavBarOverlay)
        {
            [currentNavigationController.view insertSubview:currentView
                                               belowSubview:[currentNavigationController navigationBar]];
            verticalOffset = [currentNavigationController navigationBar].bounds.size.height;
            if ([TSMessage iOS7StyleEnabled] || isViewIsUnderStatusBar) {
                addStatusBarHeightToVerticalOffset();
            }
        }
        else
        {
            [currentView.viewController.view addSubview:currentView];
            if ([TSMessage iOS7StyleEnabled] || isViewIsUnderStatusBar) {
                addStatusBarHeightToVerticalOffset();
            }
        }
    }
    else
    {
        [currentView.viewController.view addSubview:currentView];
        if ([TSMessage iOS7StyleEnabled]) {
            addStatusBarHeightToVerticalOffset();
        }
    }
    
    CGPoint toPoint;
    if (currentView.messagePosition != TSMessageNotificationPositionBottom)
    {
        CGFloat navigationbarBottomOfViewController = 0;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageLocationOfMessageView:)])
        {
            navigationbarBottomOfViewController = [self.delegate messageLocationOfMessageView:currentView];
        }
        
        toPoint = CGPointMake(currentView.center.x,
                              navigationbarBottomOfViewController + verticalOffset + CGRectGetHeight(currentView.frame) / 2.0);
    }
    else
    {
        CGFloat y = currentView.viewController.view.bounds.size.height - CGRectGetHeight(currentView.frame) / 2.0;
        if (!currentView.viewController.navigationController.isToolbarHidden)
        {
            y -= CGRectGetHeight(currentView.viewController.navigationController.toolbar.bounds);
        }
        toPoint = CGPointMake(currentView.center.x, y);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customizeMessageView:)])
    {
        [self.delegate customizeMessageView:currentView];
    }
    
    
    
    dispatch_block_t animationBlock = ^{
        currentView.center = toPoint;
        if (![TSMessage iOS7StyleEnabled]) {
            currentView.alpha = TSMessageViewAlpha;
        }
    };
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
        currentView.messageIsFullyDisplayed = YES;
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

+ (BOOL)isNavigationBarInNavigationControllerHidden:(UINavigationController *)navController
{
    if([navController isNavigationBarHidden]) {
        return YES;
    } else if ([[navController navigationBar] isHidden]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)fadeOutNotification:(TSMessageView *)currentView
{
    [self fadeOutNotification:currentView animationFinishedBlock:nil];
}

- (void)fadeOutNotification:(TSMessageView *)currentView animationFinishedBlock:(void (^)())animationFinished
{
    currentView.messageIsFullyDisplayed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGPoint fadeOutToPoint;
    if (currentView.messagePosition != TSMessageNotificationPositionBottom)
    {
        fadeOutToPoint = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame)/2.f);
    }
    else
    {
        fadeOutToPoint = CGPointMake(currentView.center.x,
                                     currentView.viewController.view.bounds.size.height + CGRectGetHeight(currentView.frame)/2.f);
    }
    
    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^
     {
         currentView.center = fadeOutToPoint;
         if (![TSMessage iOS7StyleEnabled]) {
             currentView.alpha = 0.f;
         }
     } completion:^(BOOL finished)
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
         
         if(animationFinished) {
             animationFinished();
         }
     }];
}

+ (BOOL)dismissActiveNotification
{
    return [self dismissActiveNotificationWithCompletion:nil];
}

+ (BOOL)dismissActiveNotificationWithCompletion:(void (^)())completion
{
    if ([[TSMessage sharedMessage].messages count] == 0) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if ([[TSMessage sharedMessage].messages count] == 0) return;
                       TSMessageView *currentMessage = [[TSMessage sharedMessage].messages objectAtIndex:0];
                       if (currentMessage.messageIsFullyDisplayed)
                       {
                           [[TSMessage sharedMessage] fadeOutNotification:currentMessage animationFinishedBlock:completion];
                       }
                   });
    return YES;
}

#pragma mark Customizing TSMessages

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
    _defaultViewController = defaultViewController;
}

+ (void)setDelegate:(id<TSMessageViewProtocol>)delegate
{
    [TSMessage sharedMessage].delegate = delegate;
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

+ (NSArray *)queuedMessages
{
    return [TSMessage sharedMessage].messages;
}

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if (!defaultViewController) {
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
