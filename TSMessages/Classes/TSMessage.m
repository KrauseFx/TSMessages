//
//  TSMessage.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"
#import "TSMessageAnimation.h"
#import "TSMessageSpringAnimation.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageExtraDisplayTimePerPixel 0.04


@interface TSMessage ()

/** The queued messages (TSMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;

- (void)fadeInCurrentNotification;
- (void)fadeOutNotification:(TSMessageView *)currentView;

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
        sharedMessages.animationClass = [TSMessage iOS7StyleEnabled] ? [TSMessageSpringAnimation class] : [TSMessageAnimation class];
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
                                callback:(void (^)())callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)())buttonCallback
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
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
        CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
        CGFloat offset = isPortrait ? statusBarSize.height : statusBarSize.width;
        verticalOffset += offset;
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
            isViewIsUnderStatusBar = ![currentNavigationController isNavigationBarHidden]; // strange but true
        }
        if (![currentNavigationController isNavigationBarHidden])
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
    
    CGRect toFrame = currentView.frame;
    if (currentView.messagePosition == TSMessageNotificationPositionTop)
    {
        CGFloat navigationbarBottomOfViewController = 0;
        
        if (currentView.delegate && [currentView.delegate respondsToSelector:@selector(navigationbarBottomOfViewController:)])
            navigationbarBottomOfViewController = [currentView.delegate navigationbarBottomOfViewController:currentView.viewController];
        toFrame.origin.y = navigationbarBottomOfViewController + verticalOffset;
    }
    else
    {
        CGFloat y = currentView.viewController.view.bounds.size.height - CGRectGetHeight(currentView.frame);
        if (!currentView.viewController.navigationController.isToolbarHidden) {
            y -= CGRectGetHeight(currentView.viewController.navigationController.toolbar.bounds);
        }
        toFrame.origin.y = y;
    }

    if (currentView.duration == TSMessageNotificationDurationAutomatic)
    {
        currentView.duration = + kTSMessageDisplayTime + currentView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }
    
    [self.animationClass animateMessageView:currentView
                                    toFrame:toFrame
                                  appearing:YES
                                 completion:^{
                                     currentView.messageIsFullyDisplayed = YES;
                                     
                                     if (currentView.duration != TSMessageNotificationDurationEndless)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^
                                                        {
                                                            [self performSelector:@selector(fadeOutNotification:)
                                                                       withObject:currentView
                                                                       afterDelay:currentView.duration];
                                                        });
                                     }

                                 }];
    
    
}

- (void)fadeOutNotification:(TSMessageView *)currentView
{
    currentView.messageIsFullyDisplayed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGRect toFrame = currentView.frame;

    if (currentView.messagePosition == TSMessageNotificationPositionTop)
    {
        toFrame.origin.y = -CGRectGetHeight(currentView.frame);
    }
    else
    {
        toFrame.origin.y = CGRectGetHeight(currentView.viewController.view.bounds);
    }
    
    [self.animationClass animateMessageView:currentView
                                    toFrame:toFrame
                                  appearing:NO
                                 completion:^{
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
                       if ([[TSMessage sharedMessage].messages count] == 0) return;
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
