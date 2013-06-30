//
//  TSSecondViewController.h
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessageView.h"

@interface TSSecondViewController : UIViewController <TSMessageViewProtocol>

@property (weak, nonatomic) IBOutlet UISwitch *descriptionToggle;
@property (weak, nonatomic) IBOutlet UISwitch *longDurationToggle;
@property (weak, nonatomic) IBOutlet UISwitch *onBottomToggle;


- (IBAction)didTapError:(id)sender;
- (IBAction)didTapWarning:(id)sender;
- (IBAction)didTapMessage:(id)sender;
- (IBAction)didTapSuccess:(id)sender;
- (IBAction)didTapButtonidsender:(id)sender;
- (IBAction)didTapDismissCurrentMessage:(id)sender;
- (IBAction)didTapEndless:(id)sender;

@end
