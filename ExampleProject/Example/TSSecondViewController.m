//
//  TSSecondViewController.m
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Toursprung. All rights reserved.
//


#import "TSSecondViewController.h"
#import "TSMessage.h"
#import "TSMessageView.h"

#define TSSecondViewControllerLongDuration 10.0

@implementation TSSecondViewController


- (IBAction)didTapError:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"Something failed", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil) :
                                         nil);
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeError
                                   withDuration:duration
                                   withCallback:^{
                                       [TSMessage showNotificationInViewController:self
                                                                         withTitle:NSLocalizedString(@"You dismisses it", nil)
                                                                       withMessage:nil
                                                                          withType:TSMessageNotificationTypeSuccess];
                                   }
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)];
}

- (IBAction)didTapWarning:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"Some random warning", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"Look out! Something is happening there!", nil) :
                                         nil);
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeWarning
                                   withDuration:duration
                                   withCallback:nil
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)];
}

- (IBAction)didTapMessage:(id)sender
{

    NSString *notificationTitle = NSLocalizedString(@"Tell the user something", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"This is some neutral notification.", nil) :
                                         nil);
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeMessage
                                   withDuration:duration
                                   withCallback:nil
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)];
}

- (IBAction)didTapSuccess:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"Success", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"Some task was successfully completed!", nil) :
                                         nil);
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeSuccess
                                   withDuration:duration
                                   withCallback:nil
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)];
}

- (IBAction)didTapButtonidsender:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"New version available", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"Please update our app. This is some neutral notification.", nil) :
                                         nil);
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeMessage
                                   withDuration:duration
                                   withCallback:nil
                                withButtonTitle:@"Update" // that's the title of the added button
                             withButtonCallback:^{
                                 [TSMessage showNotificationInViewController:self
                                                                   withTitle:NSLocalizedString(@"Button tapped!", nil)
                                                                 withMessage:nil
                                                                    withType:TSMessageNotificationTypeSuccess];
                             }
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)
                            canBeDismisedByUser:YES];
}

- (IBAction)didTapDismissCurrentMessage:(id)sender
{
    [TSMessage dismissActiveNotification];
}

- (IBAction)didTapEndless:(id)sender
{
    [TSMessage showNotificationInViewController:self
                                      withTitle:NSLocalizedString(@"Endless notification", nil)
                                    withMessage:NSLocalizedString(@"This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' to dismiss the currently shown message", nil)
                                       withType:TSMessageNotificationTypeMessage
                                   withDuration:TSMessageNotificationDurationEndless
                                   withCallback:nil
                                withButtonTitle:nil
                             withButtonCallback:nil
                                     atPosition:(self.onBottomToggle.on ? TSMessageNotificationPositionBottom : TSMessageNotificationPositionTop)
                            canBeDismisedByUser:NO];
}

- (IBAction)didTapMessageWithDelegate:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"Tell the user something", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"This is some neutral notification.", nil) :
                                         nil);

    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);

    TSMessageView *warningMessage = [[TSMessageView alloc] initWithTitle:notificationTitle
                                                             withContent:notificationDescription
                                                                withType:TSMessageNotificationTypeMessage
                                                            withDuration:duration
                                                        inViewController:self
                                                            withCallback:nil
                                                         withButtonTitle:nil
                                                      withButtonCallback:nil
                                                              atPosition:TSMessageNotificationPositionTop
                                                       shouldBeDismissed:YES];
    warningMessage.delegate = self;

    [TSMessage showNotification:warningMessage];
}

- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 55;
}

@end
