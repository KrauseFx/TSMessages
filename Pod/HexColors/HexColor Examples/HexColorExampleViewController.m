//
//  HexColorExampleViewController.m
//  HexColor Examples
//
//  Created by Marius Landwehr on 21.05.13.
//  Copyright (c) 2013 Marius Landwehr. All rights reserved.
//

#import "HexColorExampleViewController.h"
#import "HexColor.h"

@interface HexColorExampleViewController ()

@end

@implementation HexColorExampleViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)colorOne:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#999999"];
}

- (IBAction)colorTwo:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#334455"];
}

- (IBAction)colorThree:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#ff0099"];
}

- (IBAction)color333:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"333"];
}

- (IBAction)color656:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"656"];
}

- (IBAction)color295:(id)sender {
    self.backgroundView.backgroundColor = [UIColor colorWithHexString:@"295"];
}
@end
