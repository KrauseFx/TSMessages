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

@interface TSDemoViewController()

@property (nonatomic, strong) TSMessageView *endlessNotification;

@end

@implementation TSDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    self.wantsFullScreenLayout = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (IBAction)didTapError:(id)sender
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
                                subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil)
                                    type:TSMessageNotificationTypeError
                          simultaneously:NO];
}

- (IBAction)didTapWarning:(id)sender
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Some random warning", nil)
                                subtitle:NSLocalizedString(@"Look out! Something is happening there!", nil)
                                    type:TSMessageNotificationTypeWarning
                          simultaneously:YES];
}

- (IBAction)didTapMessage:(id)sender
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Tell the user something", nil)
                                subtitle:NSLocalizedString(@"This is some neutral notification!", nil)
                                    type:TSMessageNotificationTypeMessage
                          simultaneously:YES];
}

- (IBAction)didTapSuccess:(id)sender
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                subtitle:NSLocalizedString(@"Some task was successfully completed!", nil)
                                    type:TSMessageNotificationTypeSuccess
                          simultaneously:YES];
}

- (IBAction)didTapButton:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"New version available", nil)
                                       subtitle:NSLocalizedString(@"Please update our app. We would be very thankful", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:NSLocalizedString(@"Update", nil)
                                 buttonCallback:^{
                                     [TSMessage showNotificationWithTitle:NSLocalizedString(@"Thanks for updating", nil)
                                                                     type:TSMessageNotificationTypeSuccess
                                                            simultaneously:YES];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES
                                 simultaneously:NO];
}

- (IBAction)didTapToggleNavigationBar:(id)sender {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}
- (IBAction)didTapToggleNavigationBarAlpha:(id)sender {
    CGFloat alpha = self.navigationController.navigationBar.alpha;
    self.navigationController.navigationBar.alpha = (alpha==1.f)?0.5:1;
}
- (IBAction)didTapToggleWantsFullscreen:(id)sender {
    self.wantsFullScreenLayout = !self.wantsFullScreenLayout;
    [self.navigationController.navigationBar setTranslucent:!self.navigationController.navigationBar.isTranslucent];
}

- (IBAction)didTapCustomImage:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Custom image", nil)
                                       subtitle:NSLocalizedString(@"This uses an image you can define", nil)
                                          image:[UIImage imageNamed:@"NotificationButtonBackground.png"]
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES
                                 simultaneously:YES];
}

- (IBAction)didTapDismissCurrentMessage:(id)sender
{
    [TSMessage dismissActiveNotification];
}

- (IBAction)didTapEndless:(id)sender
{
    self.endlessNotification = [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Endless", nil)
                                       subtitle:NSLocalizedString(@"This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the currently shown message", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationEndless
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismissedByUser:NO
                                 simultaneously:YES];
}

- (IBAction)didTapLong:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Long", nil)
                                       subtitle:NSLocalizedString(@"This message is displayed 10 seconds instead of the calculated value", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeWarning
                                       duration:10.0
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES
                                 simultaneously:NO];
}

- (IBAction)didTapBottom:(id)sender
{
    [TSMessage dismissNotification:self.endlessNotification];
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Hu!", nil)
                                       subtitle:NSLocalizedString(@"I'm down here :)", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionBottom
                            canBeDismissedByUser:YES
                                 simultaneously:YES];
}

- (IBAction)didTapText:(id)sender
{
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"With 'Text' I meant a long text, so here it is", nil)
                                subtitle:NSLocalizedString(@"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus", nil)
                                    type:TSMessageNotificationTypeWarning
                          simultaneously:NO];
}

- (IBAction)didTapCustomDesign:(id)sender
{
    // this is an example on how to apply a custom design
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Updated to custom design file", nil)
                                    subtitle:NSLocalizedString(@"From now on, all the titles of success messages are larger", nil)
                                    type:TSMessageNotificationTypeSuccess
                          simultaneously:YES];
}






- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 55;
}

- (IBAction)didTapNavbarHidden:(id)sender {
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
}
@end
