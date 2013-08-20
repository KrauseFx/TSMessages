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

@implementation TSDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
}

- (IBAction)didTapError:(id)sender
{
    [TSMessage showNotificationwithTitle:NSLocalizedString(@"Something failed", nil)
                                subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil)
                                    type:TSMessageNotificationTypeError];
    
    
//    [TSMessage showNotificationInViewController:self
//                                      title:notificationTitle
//                                    message:notificationDescription
//                                       type:TSMessageNotificationTypeError
//                                   duration:duration
//                                   callback:^{
//                                       [TSMessage showNotificationInViewController:self
//                                                                         withTitle:NSLocalizedString(@"You dismisses it", nil)
//                                                                       withMessage:nil
//                                                                          withType:TSMessageNotificationTypeSuccess];
//                                   }
//                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)];
}

- (IBAction)didTapWarning:(id)sender
{
    [TSMessage showNotificationwithTitle:NSLocalizedString(@"Some random warning", nil)
                                subtitle:NSLocalizedString(@"Look out! Something is happening there!", nil)
                                    type:TSMessageNotificationTypeWarning];
}

- (IBAction)didTapMessage:(id)sender
{
    [TSMessage showNotificationwithTitle:NSLocalizedString(@"Tell the user something", nil)
                                subtitle:NSLocalizedString(@"This is some neutral notification!", nil)
                                    type:TSMessageNotificationTypeMessage];
}

- (IBAction)didTapSuccess:(id)sender
{
    [TSMessage showNotificationwithTitle:NSLocalizedString(@"Success", nil)
                                subtitle:NSLocalizedString(@"Some task was successfully completed!", nil)
                                    type:TSMessageNotificationTypeSuccess];
}

- (IBAction)didTapButton:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"New version available", nil)
                                       subtitle:NSLocalizedString(@"Please update our app. We would be very thankful", nil)
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:NSLocalizedString(@"Update", nil)
                                 buttonCallback:^{
                                     [TSMessage showNotificationWithTitle:NSLocalizedString(@"Thanks for updating", nil)
                                                                     type:TSMessageNotificationTypeSuccess];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:YES];
}

- (IBAction)didTapDismissCurrentMessage:(id)sender
{
    [TSMessage dismissActiveNotification];
}

- (IBAction)didTapEndless:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Endless", nil)
                                       subtitle:NSLocalizedString(@"This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the currently shown message", nil)
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationEndless
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:NO];
}





- (IBAction)didTapLong:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Long", nil)
                                       subtitle:NSLocalizedString(@"This message is displayed 10 seconds instead of the calculated value", nil)
                                           type:TSMessageNotificationTypeWarning
                                       duration:10.0
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:YES];
}

- (IBAction)didTapBottom:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Hu!", nil)
                                       subtitle:NSLocalizedString(@"I'm down here :)", nil)
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionBottom
                            canBeDismisedByUser:YES];
}






- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 55;
}

@end
