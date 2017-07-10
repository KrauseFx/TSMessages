//
//  HexColorExampleViewController.h
//  HexColor Examples
//
//  Created by Marius Landwehr on 21.05.13.
//  Copyright (c) 2013 Marius Landwehr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HexColorExampleViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *backgroundView;

- (IBAction)colorOne:(id)sender;
- (IBAction)colorTwo:(id)sender;
- (IBAction)colorThree:(id)sender;
- (IBAction)color333:(id)sender;
- (IBAction)color656:(id)sender;
- (IBAction)color295:(id)sender;

@end
