//
//  TSDemoViewController.h
//  Example
//
//  Created by Felix Krause on 13.04.13.
//  Copyright (c) 2013 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessageView.h"

@interface TSDemoViewController : UIViewController <TSMessageViewProtocol>


- (IBAction)didTapError:(id)sender;
- (IBAction)didTapWarning:(id)sender;
- (IBAction)didTapMessage:(id)sender;
- (IBAction)didTapSuccess:(id)sender;
- (IBAction)didTapButton:(id)sender;
- (IBAction)didTapDismissCurrentMessage:(id)sender;
- (IBAction)didTapEndless:(id)sender;
- (IBAction)didTapLong:(id)sender;
- (IBAction)didTapBottom:(id)sender;
- (IBAction)didTapText:(id)sender;
- (IBAction)didTapCustomDesign:(id)sender;
- (IBAction)didTapNavbarHidden:(id)sender;

@end
