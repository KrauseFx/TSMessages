//
//  TSSecondViewController.h
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSSecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *descriptionToggle;


- (IBAction)didTapError:(id)sender;
- (IBAction)didTapWarning:(id)sender;
- (IBAction)didTapMessage:(id)sender;
- (IBAction)didTapSuccess:(id)sender;

@end
