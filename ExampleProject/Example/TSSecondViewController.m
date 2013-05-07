//
//  TSSecondViewController.m
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Toursprung. All rights reserved.
//

#import "TSSecondViewController.h"
#import "TSMessage.h"

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
                                   }];
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
                                   withDuration:duration];
}

- (IBAction)didTapMessage:(id)sender
{
    NSString *notificationTitle = NSLocalizedString(@"Tell the user something", nil);
    NSString *notificationDescription = (self.descriptionToggle.on ?
                                         NSLocalizedString(@"This is some neutral notification.", nil) :
                                         nil);
    
    NSString *buttonTitle = self.buttonToggle.on ? @"UPDATE" : nil;
    
    CGFloat duration = (self.longDurationToggle.on ? TSSecondViewControllerLongDuration : 0.0);
    
    [TSMessage showNotificationInViewController:self
                                      withTitle:notificationTitle
                                    withMessage:notificationDescription
                                       withType:TSMessageNotificationTypeMessage
                                   withDuration:duration
                                   withCallback:nil
                                withButtonTitle:buttonTitle
                             withButtonCallback:^{
                                 [TSMessage showNotificationInViewController:self
                                                                   withTitle:NSLocalizedString(@"Button tapped!", nil)
                                                                 withMessage:nil
                                                                    withType:TSMessageNotificationTypeSuccess];
                             }
                                     atPosition:TSMessageNotificationPositionTop];
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
                                   withDuration:duration];
}

@end
