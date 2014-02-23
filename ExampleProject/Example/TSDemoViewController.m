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

@interface TSDemoViewController ()

@property (nonatomic) BOOL hideStatusbar;

@end

@implementation TSDemoViewController

- (void)awakeFromNib
{
    self.hideStatusbar = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)setHideStatusbar:(BOOL)hideStatusbar
{
    _hideStatusbar = hideStatusbar;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return self.hideStatusbar;
}

- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController
{
    return 55;
}

#pragma mark Actions

- (IBAction)didTapError:(id)sender
{
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"Something failed", nil)
                              subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil)
                                  type:TSMessageTypeError];
}

- (IBAction)didTapWarning:(id)sender
{
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"Some random warning", nil)
                              subtitle:NSLocalizedString(@"Look out! Something is happening there!", nil)
                                  type:TSMessageTypeWarning];
}

- (IBAction)didTapMessage:(id)sender
{
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"Tell the user something", nil)
                              subtitle:NSLocalizedString(@"This is some neutral message!", nil)
                                  type:TSMessageTypeDefault];
}

- (IBAction)didTapSuccess:(id)sender
{
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"Success", nil)
                              subtitle:NSLocalizedString(@"Some task was successfully completed!", nil)
                                  type:TSMessageTypeSuccess];
}

- (IBAction)didTapButton:(id)sender
{
    TSMessageView *view = [TSMessage messageWithTitle:NSLocalizedString(@"New version available", nil)
                                             subtitle:NSLocalizedString(@"Please update our app. We would be very thankful", nil)
                                                 type:TSMessageTypeDefault];
    
    [view setButtonWithTitle:NSLocalizedString(@"Update", nil) callback:^(TSMessageView *messageView) {
        [messageView dismiss];

        [TSMessage displayMessageWithTitle:NSLocalizedString(@"Thanks for updating", nil)
                                  subtitle:nil
                                      type:TSMessageTypeSuccess];
    }];
    
    [view displayOrEnqueue];
}

- (IBAction)didTapPermanent:(id)sender
{
    TSMessageView *view = [TSMessage messageWithTitle:NSLocalizedString(@"Permanent message", nil)
                                             subtitle:NSLocalizedString(@"Stays here until it gets dismissed", nil)
                                                 type:TSMessageTypeDefault];
    
    view.userDismissEnabled = NO;
    view.position = TSMessagePositionBottom;
    
    [view setButtonWithTitle:NSLocalizedString(@"Dismiss", nil) callback:^(TSMessageView *messageView) {
        [messageView dismiss];
    }];
    
    view.tapCallback = ^(TSMessageView *messageView) {
        [TSMessage displayMessageWithTitle:NSLocalizedString(@"Action triggered", nil)
                                  subtitle:nil
                                      type:TSMessageTypeSuccess];
    };
    
    [view displayPermanently];
}

- (IBAction)didTapToggleNavigationBar:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction)didTapToggleNavigationBarAlpha:(id)sender
{
    CGFloat alpha = self.navigationController.navigationBar.alpha;
    
    self.navigationController.navigationBar.alpha = (alpha == 1.f) ? 0.5 : 1;
}

- (IBAction)didTapToggleStatusbar:(id)sender
{
    self.hideStatusbar = !self.hideStatusbar;
}

- (IBAction)didTapCustomImage:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"MessageButtonBackground.png"];
    
    TSMessageView *messageView = [TSMessage messageWithTitle:NSLocalizedString(@"Custom image", nil)
                                                    subtitle:NSLocalizedString(@"This uses an image you can define", nil)
                                                       image:image
                                                        type:TSMessageTypeDefault
                                            inViewController:self];
    
    [messageView displayOrEnqueue];
}

- (IBAction)didTapDismissCurrentMessage:(id)sender
{
    [TSMessage dismissCurrentMessage];
}

- (IBAction)didTapEndless:(id)sender
{
    TSMessageView *messageView = [TSMessage messageWithTitle:NSLocalizedString(@"Endless", nil)
                                                    subtitle:NSLocalizedString(@"This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the current message.", nil)
                                                        type:TSMessageTypeSuccess];
    
    messageView.duration = TSMessageDurationEndless;
    messageView.userDismissEnabled = NO;
    
    [messageView displayOrEnqueue];
}

- (IBAction)didTapLong:(id)sender
{
    TSMessageView *messageView = [TSMessage messageWithTitle:NSLocalizedString(@"Long", nil)
                                                    subtitle:NSLocalizedString(@"This message is displayed 10 seconds instead of the calculated value", nil)
                                                        type:TSMessageTypeWarning];
    messageView.duration = 10.0;
    
    [messageView displayOrEnqueue];
}

- (IBAction)didTapBottom:(id)sender
{
    TSMessageView *messageView = [TSMessage messageWithTitle:NSLocalizedString(@"Hu!", nil)
                                                    subtitle:NSLocalizedString(@"I'm down here :)", nil)
                                                        type:TSMessageTypeSuccess];
    
    messageView.duration = TSMessageDurationAutomatic;
    messageView.position = TSMessagePositionBottom;
    
    [messageView displayOrEnqueue];
}

- (IBAction)didTapText:(id)sender
{
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"With 'Text' I meant a long text, so here it is", nil)
                              subtitle:NSLocalizedString(@"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus", nil)
                                  type:TSMessageTypeWarning];
}

- (IBAction)didTapCustomDesign:(id)sender
{
    [TSMessage addCustomDesignFromFileWithName:@"AlternativeDesign.json"];
    
    [TSMessage displayMessageWithTitle:NSLocalizedString(@"Updated to custom design file", nil)
                              subtitle:NSLocalizedString(@"From now on, all the titles of success messages are larger", nil)
                                  type:TSMessageTypeSuccess];
}

@end
