//
//  TSAppDelegate.m
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Felix Krause. All rights reserved.
//

#import "TSAppDelegate.h"
#import <TSMessages/TSMessageView.h>
@implementation TSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /**
    //If you want you can overidde some properties using UIAppearance
    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:6]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor redColor]];
    [[TSMessageView appearance] setContentFont:[UIFont boldSystemFontOfSize:10]];
    [[TSMessageView appearance]setContentTextColor:[UIColor greenColor]];
    [[TSMessageView appearance]setErrorIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
    [[TSMessageView appearance]setSuccessIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
    [[TSMessageView appearance]setMessageIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
    [[TSMessageView appearance]setWarningIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
    //End of override
     */
    return YES;
}

@end 
