//
//  TSMessage.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessage.h"
#import "TSMessageView.h"
#import "TSMessageView+Private.h"

#define kTSMessageDisplayTime 1.5
#define kTSMessageAnimationDuration 0.3
#define kTSMessageExtraDisplayTimePerPixel 0.04
#define kTSDesignFileName @"TSMessagesDefaultDesign.json"

@interface TSMessage ()
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation TSMessage

__weak static UIViewController *_defaultViewController;

+ (TSMessage *)sharedMessage
{
    static TSMessage *sharedMessage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMessage = [[[self class] alloc] init];
    });
    
    return sharedMessage;
}

- (id)init
{
    if ((self = [super init]))
    {
        _messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Setup messages

+ (TSMessageView *)messageWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageType)type
{
    return [self messageWithTitle:title subtitle:subtitle image:nil type:type inViewController:self.defaultViewController];
}

+ (TSMessageView *)messageWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageType)type inViewController:(UIViewController *)viewController
{
    TSMessageView *view = [[TSMessageView alloc] initWithTitle:title subtitle:subtitle image:image type:type];
    
    view.viewController = viewController;
    
    return view;
}

#pragma mark - Setup messages and display them right away

+ (TSMessageView *)displayMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageType)type
{
    return [self displayMessageWithTitle:title subtitle:subtitle image:nil type:type inViewController:self.defaultViewController];
}

+ (TSMessageView *)displayMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageType)type inViewController:(UIViewController *)viewController
{
    TSMessageView *view = [self messageWithTitle:title subtitle:subtitle image:image type:type inViewController:viewController];
    
    [self displayOrEnqueueMessage:view];
    
    return view;
}

#pragma mark - Displaying messages

+ (void)displayPermanentMessage:(TSMessageView *)messageView
{
    [[TSMessage sharedMessage] displayMessage:messageView];
}

+ (void)displayOrEnqueueMessage:(TSMessageView *)messageView
{
    NSString *title = messageView.title;
    NSString *subtitle = messageView.subtitle;

    for (TSMessageView *n in [TSMessage sharedMessage].messages)
    {
        // avoid displaying the same messages twice in a row
        BOOL equalTitle = ([n.title isEqualToString:title] || (!n.title && !title));
        BOOL equalSubtitle = ([n.subtitle isEqualToString:subtitle] || (!n.subtitle && !subtitle));
        
        if (equalTitle && equalSubtitle) return;
    }
    
    BOOL isDisplayable = !self.isDisplayingMessage;

    [[TSMessage sharedMessage].messages addObject:messageView];

    if (isDisplayable)
    {
        [[TSMessage sharedMessage] displayCurrentMessage];
    }
}

+ (BOOL)dismissCurrentMessageForce:(BOOL)force
{
    TSMessageView *currentMessage = [TSMessage sharedMessage].currentMessage;
    
    if (!currentMessage) return NO;
    if (!currentMessage.isMessageFullyDisplayed && !force) return NO;
    
    [[TSMessage sharedMessage] dismissCurrentMessage];
    
    return YES;
}

+ (BOOL)dismissCurrentMessage
{
    return [self dismissCurrentMessageForce:NO];
}

+ (BOOL)isDisplayingMessage
{
    return !![TSMessage sharedMessage].currentMessage;
}

#pragma mark - Customizing design

+ (void)addCustomDesignFromFileWithName:(NSString *)fileName
{
    NSError *error = nil;
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *design = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    [self.design addEntriesFromDictionary:design];
}

+ (NSMutableDictionary *)design
{
    static NSMutableDictionary *design = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kTSDesignFileName];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *config = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        design = [NSMutableDictionary dictionaryWithDictionary:config];
    });
    
    return design;
}

#pragma mark - Default view controller

+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if (!defaultViewController)
    {
        NSLog(@"TSMessages: It is recommended to set a custom defaultViewController that is used to display the messages");
        defaultViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    return defaultViewController;
}

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
    _defaultViewController = defaultViewController;
}

#pragma mark - Internals

- (TSMessageView *)currentMessage
{
    if (!self.messages.count) return nil;
    
    return [self.messages firstObject];
}

- (void)displayCurrentMessage
{
    if (!self.currentMessage) return;

    [self displayMessage:self.currentMessage];
}

- (void)displayMessage:(TSMessageView *)messageView
{
    [messageView prepareForDisplay];
    
    // add view
    UIViewController *viewController = messageView.viewController;
    UINavigationController *navigationController = (UINavigationController *)([viewController isKindOfClass:[UINavigationController class]] ? viewController : viewController.parentViewController);
    
    if (navigationController.isNavigationBarHidden)
    {
        [messageView.viewController.view addSubview:messageView];
    }
    else
    {
        [navigationController.view insertSubview:messageView belowSubview:navigationController.navigationBar];
    }

    // animate
    [UIView animateWithDuration:kTSMessageAnimationDuration + 0.1
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         messageView.center = messageView.centerForDisplay;
                     }
                     completion:^(BOOL finished) {
                         messageView.messageFullyDisplayed = YES;
                     }];

    // duration
    if (messageView.duration == TSMessageDurationAutomatic)
    {
        messageView.duration = kTSMessageAnimationDuration + kTSMessageDisplayTime + messageView.frame.size.height * kTSMessageExtraDisplayTimePerPixel;
    }

    if (messageView.duration != TSMessageDurationEndless)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(dismissCurrentMessage) withObject:nil afterDelay:messageView.duration];
        });
    }
}

- (void)dismissMessage:(TSMessageView *)messageView
{
    [self dismissMessage:messageView completion:NULL];
}

- (void)dismissMessage:(TSMessageView *)messageView completion:(void (^)())completion
{
    messageView.messageFullyDisplayed = NO;

    CGPoint dismissToPoint;
    
    if (messageView.position == TSMessagePositionTop)
    {
        dismissToPoint = CGPointMake(messageView.center.x, -CGRectGetHeight(messageView.frame)/2.f);
    }
    else
    {
        dismissToPoint = CGPointMake(messageView.center.x, messageView.viewController.view.bounds.size.height + CGRectGetHeight(messageView.frame)/2.f);
    }

    [UIView animateWithDuration:kTSMessageAnimationDuration animations:^{
         messageView.center = dismissToPoint;
     } completion:^(BOOL finished) {
         [messageView removeFromSuperview];

         if (completion) completion();
     }];
}

- (void)dismissCurrentMessage
{
    if (!self.currentMessage) return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissCurrentMessage) object:nil];

    [self dismissMessage:self.currentMessage completion:^{
        if (self.messages.count)
        {
            [self.messages removeObjectAtIndex:0];
        }

        if (self.messages.count)
        {
            [self displayCurrentMessage];
        }
    }];
}

@end
