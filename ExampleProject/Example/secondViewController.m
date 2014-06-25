//
//  secondViewController.m
//  Example
//
//  Created by FTET on 14-5-8.
//  Copyright (c) 2014年 Toursprung. All rights reserved.
//

#import "secondViewController.h"

#import "TSMessage.h"

@interface secondViewController ()

@end

@implementation secondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)normalDidTap:(id)sender {
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Normal message in Second Tab", nil)
                                       subtitle:NSLocalizedString(@"This message is displayed 100 seconds for test simultaneous", nil)
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

- (IBAction)simultaneoulyDidTap:(id)sender {
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Simultaneously message in Second Tab", nil)
                                       subtitle:NSLocalizedString(@"This message is displayed 100 seconds for test simultaneous", nil)
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

@end
