//
//  TSSecondViewController.m
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Felix Krause. All rights reserved.
//


#import "TSDemoViewController.h"
#import "TSMessage.h"
#import "TSMessageView.h"

@interface TSDemoViewController ()

@property (nonatomic) BOOL hideStatusbar;

@end

@implementation TSDemoViewController

- (void)awakeFromNib
{
    self.hideStatusbar = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)setHideStatusbar:(BOOL)hideStatusbar
{
    _hideStatusbar = hideStatusbar;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return self.hideStatusbar;
}

- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 55;
}

#pragma mark Actions

- (IBAction)didTapError:(id)sender
{
    TSMessageView *messageView = [TSMessage showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
                                                             subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil)
                                                                 type:TSMessageNotificationTypeError];
    [messageView setUserDismissEnabled];
}

- (IBAction)didTapWarning:(id)sender
{
    TSMessageView *messageView = [TSMessage showNotificationWithTitle:NSLocalizedString(@"Some random warning", nil)
                                                             subtitle:NSLocalizedString(@"Look out! Something is happening there!", nil)
                                                                 type:TSMessageNotificationTypeWarning];
    [messageView setUserDismissEnabled];
}

- (IBAction)didTapMessage:(id)sender
{
    TSMessageView *messageView = [TSMessage showNotificationWithTitle:NSLocalizedString(@"Tell the user something", nil)
                                                             subtitle:NSLocalizedString(@"This is some neutral notification!", nil)
                                                                 type:TSMessageNotificationTypeMessage];
    [messageView setUserDismissEnabled];
}

- (IBAction)didTapSuccess:(id)sender
{
    TSMessageView *messageView =  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                                              subtitle:NSLocalizedString(@"Some task was successfully completed!", nil)
                                                                  type:TSMessageNotificationTypeSuccess];
    [messageView setUserDismissEnabled];
}

- (IBAction)didTapButton:(id)sender
{
    TSMessageView *view = [TSMessage notificationWithTitle:NSLocalizedString(@"New version available", nil)
                                                  subtitle:NSLocalizedString(@"Please update our app. We would be very thankful", nil)
                                                      type:TSMessageNotificationTypeMessage];
    
    [view setButtonWithTitle:NSLocalizedString(@"Update", nil) callback:^(TSMessageView *messageView) {
        [messageView dismiss];
        
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Thanks for updating", nil) subtitle:nil type:TSMessageNotificationTypeSuccess];
    }];
    
    [view setUserDismissEnabled];
    
    [TSMessage prepareNotificationToBeShown:view];
}

- (IBAction)didTapPermanent:(id)sender
{
    TSMessageView *view = [TSMessage notificationWithTitle:NSLocalizedString(@"Permanent notification", nil)
                                                  subtitle:NSLocalizedString(@"Stays here until it gets dismissed", nil)
                                                      type:TSMessageNotificationTypeMessage];

    view.position = TSMessageNotificationPositionBottom;
    
    [view setButtonWithTitle:NSLocalizedString(@"Dismiss", nil) callback:^(TSMessageView *messageView) {
        [messageView dismiss];
    }];
    
    view.tapCallback = ^(TSMessageView *messageView) {
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Action triggered", nil) subtitle:nil type:TSMessageNotificationTypeSuccess];
    };
    
    [view setUserDismissEnabled];
    
    [TSMessage showPermanentNotification:view];
}

- (IBAction)didTapToggleNavigationBar:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction)didTapToggleNavigationBarAlpha:(id)sender
{
    CGFloat alpha = self.navigationController.navigationBar.alpha;
    
    self.navigationController.navigationBar.alpha = (alpha == 1.f) ? 0.5 : 1;
}

- (IBAction)didTapToggleStatusbar:(id)sender
{
    self.hideStatusbar = !self.hideStatusbar;
}

- (IBAction)didTapCustomImage:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"NotificationButtonBackground.png"];
    
    TSMessageView *messageView = [TSMessage notificationWithTitle:NSLocalizedString(@"Custom image", nil)
                                                         subtitle:NSLocalizedString(@"This uses an image you can define", nil)
                                                            image:image
                                                             type:TSMessageNotificationTypeMessage
                                                 inViewController:self];
    
    [messageView setUserDismissEnabled];
    
    [TSMessage prepareNotificationToBeShown:messageView];
}

- (IBAction)didTapDismissCurrentMessage:(id)sender
{
    [TSMessage dismissActiveNotification];
}

- (IBAction)didTapEndless:(id)sender
{
    TSMessageView *messageView = [TSMessage notificationWithTitle:NSLocalizedString(@"Endless", nil)
                                                         subtitle:NSLocalizedString(@"This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the currently shown message", nil)
                                                             type:TSMessageNotificationTypeSuccess];
    
    messageView.duration = TSMessageNotificationDurationEndless;
    
    [TSMessage prepareNotificationToBeShown:messageView];
}

- (IBAction)didTapLong:(id)sender
{
    TSMessageView *messageView = [TSMessage notificationWithTitle:NSLocalizedString(@"Long", nil)
                                                         subtitle:NSLocalizedString(@"This message is displayed 10 seconds instead of the calculated value", nil)
                                                             type:TSMessageNotificationTypeWarning];
    messageView.duration = 10.0;
    
    [messageView setUserDismissEnabled];
    
    [TSMessage prepareNotificationToBeShown:messageView];
}

- (IBAction)didTapBottom:(id)sender
{
    TSMessageView *messageView = [TSMessage notificationWithTitle:NSLocalizedString(@"Hu!", nil)
                                                         subtitle:NSLocalizedString(@"I'm down here :)", nil)
                                                             type:TSMessageNotificationTypeSuccess];
    
    messageView.duration = TSMessageNotificationDurationAutomatic;
    messageView.position = TSMessageNotificationPositionBottom;
    
    [messageView setUserDismissEnabled];
    
    [TSMessage prepareNotificationToBeShown:messageView];
}

- (IBAction)didTapText:(id)sender
{
    TSMessageView *messageView = [TSMessage showNotificationWithTitle:NSLocalizedString(@"With 'Text' I meant a long text, so here it is", nil)
                                                             subtitle:NSLocalizedString(@"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus", nil)
                                                                 type:TSMessageNotificationTypeWarning];
    
    [messageView setUserDismissEnabled];
}

- (IBAction)didTapCustomDesign:(id)sender
{
    // this is an example on how to apply a custom design
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
    
    TSMessageView *messageView = [TSMessage showNotificationWithTitle:NSLocalizedString(@"Updated to custom design file", nil)
                                    subtitle:NSLocalizedString(@"From now on, all the titles of success messages are larger", nil)
                                    type:TSMessageNotificationTypeSuccess];
    
    [messageView setUserDismissEnabled];
}

@end
