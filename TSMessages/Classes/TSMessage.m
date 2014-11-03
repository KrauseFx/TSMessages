//
//  TSMessage.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageDefaultView.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageExtraDisplayTimePerPixel 0.04
#define kTSMessageAnimationDuration 0.3
#define TSDesignFileName @"TSMessagesDefaultDesign.json"

static NSMutableDictionary *_notificationDesign;

@interface TSMessage ()

/** The queued messages (TSMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;

- (void)fadeInCurrentNotification;

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
    TSMessageDefaultItem *item = [TSMessageDefaultItem itemWithTitle:title subtitle:subtitle image:image type:type duration:duration inViewController:viewController atPosition:messagePosition canBeDismissedByUser:dismissingEnabled tapHandler:callback iconHandler:nil buttonTitle:buttonTitle buttonTapHandler:buttonCallback];;
    
    [TSMessage showNotificationMessageWithItem:item];
}


+ (void)showNotificationMessageWithItem:(TSMessageItem *)item {
    [self prepareNotificationToBeShown:[item.classForView messageWithItem:item]];
}

+ (void)prepareNotificationToBeShown:(TSMessageView *)messageView
{
    NSString *title = messageView.item.title;
    NSString *subtitle = messageView.item.subtitle;
    
    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        if (([n.item.title isEqualToString:title] || (!n.item.title && !title)) && ([n.item.subtitle isEqualToString:subtitle] || (!n.item.subtitle && !subtitle)))
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
    
    if ([currentView.item.viewController isKindOfClass:[UINavigationController class]] || [currentView.item.viewController.parentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *currentNavigationController;
        
        if([currentView.item.viewController isKindOfClass:[UINavigationController class]])
            currentNavigationController = (UINavigationController *)currentView.item.viewController;
        else
            currentNavigationController = (UINavigationController *)currentView.item.viewController.parentViewController;
        
        BOOL isViewIsUnderStatusBar = [[[currentNavigationController childViewControllers] firstObject] wantsFullScreenLayout];
        if (!isViewIsUnderStatusBar && currentNavigationController.parentViewController == nil) {
            isViewIsUnderStatusBar = ![TSMessage isNavigationBarInNavigationControllerHidden:currentNavigationController]; // strange but true
        }
        if (![TSMessage isNavigationBarInNavigationControllerHidden:currentNavigationController])
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
            [currentView.item.viewController.view addSubview:currentView];
            if ([TSMessage iOS7StyleEnabled] || isViewIsUnderStatusBar) {
                addStatusBarHeightToVerticalOffset();
            }
        }
    }
    else
    {
        [currentView.item.viewController.view addSubview:currentView];
        if ([TSMessage iOS7StyleEnabled]) {
            addStatusBarHeightToVerticalOffset();
        }
    }
    
    CGPoint toPoint;
    if (currentView.item.messagePosition == TSMessageNotificationPositionTop)
    {
        CGFloat navigationbarBottomOfViewController = 0;
        
        if (currentView.delegate && [currentView.delegate respondsToSelector:@selector(navigationBarBottomOfViewController:)])
            navigationbarBottomOfViewController = [currentView.delegate navigationBarBottomOfViewController:currentView.item.viewController];
        
        toPoint = CGPointMake(currentView.center.x,
                              navigationbarBottomOfViewController + verticalOffset + CGRectGetHeight(currentView.frame) / 2.0);
    }
    else
    {
        CGFloat y = currentView.item.viewController.view.bounds.size.height - CGRectGetHeight(currentView.frame) / 2.0;
        if (!currentView.item.viewController.navigationController.isToolbarHidden) {
            y -= CGRectGetHeight(currentView.item.viewController.navigationController.toolbar.bounds);
        }
        toPoint = CGPointMake(currentView.center.x, y);
    }
    
    dispatch_block_t animationBlock = ^{
        currentView.center = toPoint;
        if (![TSMessage iOS7StyleEnabled]) {
            currentView.alpha = TSMessageViewAlpha;
        }
    };
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
        currentView.item.messageIsFullyDisplayed = YES;
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
    
    if (currentView.item.duration == TSMessageNotificationDurationAutomatic)
    {
        currentView.item.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + currentView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }
    
    if (currentView.item.duration != TSMessageNotificationDurationEndless)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self performSelector:@selector(fadeOutNotification:)
                                      withObject:currentView
                                      afterDelay:currentView.item.duration];
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
    currentView.item.messageIsFullyDisplayed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGPoint fadeOutToPoint;
    if (currentView.item.messagePosition == TSMessageNotificationPositionTop)
    {
        fadeOutToPoint = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame)/2.f);
    }
    else
    {
        fadeOutToPoint = CGPointMake(currentView.center.x,
                                     currentView.item.viewController.view.bounds.size.height + CGRectGetHeight(currentView.frame)/2.f);
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
     }];
}

+ (BOOL)dismissActiveNotification {
    if ([[TSMessage sharedMessage].messages count] == 0) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       if ([[TSMessage sharedMessage].messages count] == 0) return;
       TSMessageView *currentMessage = ([TSMessage sharedMessage].messages)[0];
       if (currentMessage.item.messageIsFullyDisplayed) {
           [[TSMessage sharedMessage] fadeOutNotification:currentMessage];
       }
    });
    return YES;
}

+ (BOOL)dismissAllNotifications {
    if (![TSMessage sharedMessage].messages.count) return NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        // remove all messages except first
        if ([TSMessage sharedMessage].messages.count > 1) {
            [[TSMessage sharedMessage].messages removeObjectsInRange:NSMakeRange(1, [TSMessage sharedMessage].messages.count - 1)];
        }
        TSMessageView *currentMessage = [TSMessage sharedMessage].messages[0];
        if (currentMessage.item.messageIsFullyDisplayed) {
            [[TSMessage sharedMessage] fadeOutNotification:currentMessage];
        }
    });

    return NO;
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

+ (NSMutableDictionary *)notificationDesign
{
    if (!_notificationDesign)
    {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:TSDesignFileName];
        _notificationDesign = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                                                                            options:(NSJSONReadingOptions) kNilOptions
                                                                                                              error:nil]];
    }
    
    return _notificationDesign;
}


+ (NSDictionary *)notificationDesignWithMessageType:(TSMessageNotificationType)messageType {
        NSString *currentString;
        switch (messageType)
        {
            case TSMessageNotificationTypeMessage:
            {
                currentString = @"message";
                break;
            }
            case TSMessageNotificationTypeError:
            {
                currentString = @"error";
                break;
            }
            case TSMessageNotificationTypeSuccess:
            {
                currentString = @"success";
                break;
            }
            case TSMessageNotificationTypeWarning:
            {
                currentString = @"warning";
                break;
            }
                
            default:
                break;
        }
    NSDictionary *dic = [[TSMessage notificationDesign] valueForKey:currentString];
    return dic;
}

+ (void)addCustomDesignFromFileWithName:(NSString *)fileName {
    [self addNotificationDesignFromFile:fileName];
}

+ (void)addNotificationDesignFromFile:(NSString *)filename
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSDictionary *design = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                           options:(NSJSONReadingOptions) kNilOptions
                                                             error:nil];
    
    [[TSMessage notificationDesign] addEntriesFromDictionary:design];
}

@end
