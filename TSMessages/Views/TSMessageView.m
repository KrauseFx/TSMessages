//
//  TSMessageView.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessageView.h"
#import "HexColor.h"
#import "TSBlurView.h"
#import "TSMessage.h"
#import "TSMessage+Private.h"
#import "TSMessageView+Private.h"

#define TSMessageViewPadding 15.0

@interface TSMessageView () <UIGestureRecognizerDelegate>
@property (nonatomic) NSDictionary *config;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UIImageView *iconImageView;
@property (nonatomic) UIButton *button;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) UISwipeGestureRecognizer *swipeRecognizer;
@property (nonatomic) TSBlurView *backgroundBlurView;
@property (nonatomic, copy) TSMessageCallback buttonCallback;
@property (nonatomic, assign, getter = isMessageFullyDisplayed) BOOL messageFullyDisplayed;
@end

@implementation TSMessageView

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image type:(TSMessageType)type
{
    if ((self = [self init]))
    {
        self.userDismissEnabled = YES;
        self.duration = TSMessageDurationAutomatic;
        self.position = TSMessagePositionTop;
        
        [self setupConfigForType:type];
        [self setupBackgroundView];
        [self setupTitle:title];
        [self setupSubtitle:subtitle];
        [self setupImage:image];
        [self setupAutoresizing];
        [self setupGestureRecognizers];
    }
    
    return self;
}

#pragma mark - Setup helpers

- (void)setupConfigForType:(TSMessageType)type
{
    NSString *config;
    
    switch (type)
    {
        case TSMessageTypeError: config = @"error"; break;
        case TSMessageTypeSuccess: config = @"success"; break;
        case TSMessageTypeWarning: config = @"warning"; break;
            
        default: config = @"message"; break;
    }
    
    self.config = [TSMessage design][config];
}

- (void)setupBackgroundView
{
    self.backgroundBlurView = [[TSBlurView alloc] init];
    self.backgroundBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundBlurView.blurTintColor = [UIColor colorWithHexString:self.config[@"backgroundColor"]];
    
    [self addSubview:self.backgroundBlurView];
}

- (void)setupAutoresizing
{
    self.autoresizingMask = (self.position == TSMessagePositionTop) ?
        (UIViewAutoresizingFlexibleWidth) :
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
}

- (void)setupTitle:(NSString *)title
{
    UIColor *fontColor = [UIColor colorWithHexString:self.config[@"textColor"] alpha:1];
    CGFloat fontSize = [self.config[@"titleFontSize"] floatValue];
    NSString *fontName = self.config[@"titleFontName"];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.shadowOffset = CGSizeMake([self.config[@"shadowOffsetX"] floatValue], [self.config[@"shadowOffsetY"] floatValue]);
    self.titleLabel.shadowColor = [UIColor colorWithHexString:self.config[@"shadowColor"] alpha:1];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = fontColor;
    self.titleLabel.text = title;
    self.titleLabel.font = fontName ?
        [UIFont fontWithName:fontName size:fontSize] :
        [UIFont boldSystemFontOfSize:fontSize];
    
    [self addSubview:self.titleLabel];
}

- (void)setupSubtitle:(NSString *)subtitle
{
    if (!subtitle.length) return;
    
    UIColor *contentTextColor = [UIColor colorWithHexString:self.config[@"contentTextColor"] alpha:1];
    UIColor *fontColor = [UIColor colorWithHexString:self.config[@"textColor"] alpha:1];
    CGFloat fontSize = [self.config[@"contentFontSize"] floatValue];
    NSString *fontName = self.config[@"contentFontName"];
    
    if (!contentTextColor) contentTextColor = fontColor;
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.shadowOffset = CGSizeMake([self.config[@"shadowOffsetX"] floatValue], [self.config[@"shadowOffsetY"] floatValue]);
    self.contentLabel.shadowColor = [UIColor colorWithHexString:self.config[@"shadowColor"] alpha:1];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.textColor = contentTextColor;
    self.contentLabel.text = subtitle;
    self.contentLabel.font = fontName ?
        [UIFont fontWithName:fontName size:fontSize] :
        [UIFont systemFontOfSize:fontSize];
    
    [self addSubview:self.contentLabel];
}

- (void)setupImage:(UIImage *)image
{
    if (!image && self.config[@"imageName"] != [NSNull null] && [self.config[@"imageName"] length]) image = [UIImage imageNamed:self.config[@"imageName"]];
    
    self.iconImageView = [[UIImageView alloc] initWithImage:image];
    self.iconImageView.frame = CGRectMake(TSMessageViewPadding * 2, TSMessageViewPadding, image.size.width, image.size.height);
    
    [self addSubview:self.iconImageView];
}

- (void)setupGestureRecognizers
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewTap:)];
    self.tapRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapRecognizer];
    
    self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipe:)];
    self.swipeRecognizer.direction = (self.position == TSMessagePositionTop ? UISwipeGestureRecognizerDirectionUp : UISwipeGestureRecognizerDirectionDown);
    [self addGestureRecognizer:self.swipeRecognizer];
}

#pragma mark - Message view attributes and actions

- (void)setButtonWithTitle:(NSString *)title callback:(TSMessageCallback)callback
{
    self.buttonCallback = callback;
    
    UIImage *buttonBackgroundImage = [[UIImage imageNamed:self.config[@"buttonBackgroundImageName"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
    UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:self.config[@"buttonTitleShadowColor"] alpha:1];
    UIColor *buttonTitleTextColor = [UIColor colorWithHexString:self.config[@"buttonTitleTextColor"] alpha:1];
    UIColor *fontColor = [UIColor colorWithHexString:self.config[@"textColor"] alpha:1];
    
    if (!buttonBackgroundImage) buttonBackgroundImage = [[UIImage imageNamed:self.config[@"MessageButtonBackground"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
    if (!buttonTitleShadowColor) buttonTitleShadowColor = [UIColor colorWithHexString:self.config[@"shadowColor"] alpha:1];
    if (!buttonTitleTextColor) buttonTitleTextColor = fontColor;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.button.titleLabel.shadowOffset = CGSizeMake([self.config[@"buttonTitleShadowOffsetX"] floatValue], [self.config[@"buttonTitleShadowOffsetY"] floatValue]);
    
    [self.button setTitle:title forState:UIControlStateNormal];
    [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];
    [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.button sizeToFit];
    
    self.button.frame = CGRectMake(self.viewController.view.bounds.size.width - TSMessageViewPadding - self.button.frame.size.width, 0, self.button.frame.size.width, 31);
    
    [self addSubview:self.button];
}

- (void)displayOrEnqueue {
    [TSMessage displayOrEnqueueMessage:self];
}

- (void)displayPermanently {
    [TSMessage displayPermanentMessage:self];
}

#pragma mark - View handling

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.duration == TSMessageDurationEndless && self.superview && !self.window)
    {
        [self dismiss];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentHeight;
    CGFloat screenWidth = self.viewController.view.bounds.size.width;
    CGFloat textSpaceRight = self.button.frame.size.width + TSMessageViewPadding;
    CGFloat textSpaceLeft = 2 * TSMessageViewPadding;
    UIImage *image = self.iconImageView.image;
    
    if (image) textSpaceLeft += image.size.width + 2 * TSMessageViewPadding;
    
    // title
    self.titleLabel.frame = CGRectMake(textSpaceLeft,
                                       TSMessageViewPadding,
                                       screenWidth - TSMessageViewPadding - textSpaceLeft - textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];
    
    // subtitle
    if (self.contentLabel)
    {
        self.contentLabel.frame = CGRectMake(textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - TSMessageViewPadding - textSpaceLeft - textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];
        
        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }
    
    currentHeight += TSMessageViewPadding;
    
    // image
    if (self.iconImageView)
    {
        // check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + TSMessageViewPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height;
        }
        else
        {
            self.iconImageView.center = CGPointMake([self.iconImageView center].x, round(currentHeight / 2.0));
        }
    }
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
    
    // button
    if (self.button)
    {
        self.button.center = CGPointMake([self.button center].x, round(currentHeight / 2.0));
    
        self.button.frame = CGRectMake(self.frame.size.width - textSpaceRight,
                                       round((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }
    
    
    CGRect backgroundFrame = CGRectMake(self.backgroundBlurView.frame.origin.x,
                                        self.backgroundBlurView.frame.origin.y,
                                        screenWidth,
                                        currentHeight);
    
    // increase frame of background view because of the spring animation
    if (self.position == TSMessagePositionTop)
    {
        float topOffset = 0.f;
        
        UINavigationController *navigationController = self.viewController.navigationController;
        
        if (!navigationController && [self.viewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController *)self.viewController;
        }
        
        BOOL isNavBarIsHidden = !navigationController || self.viewController.navigationController.navigationBarHidden;
        BOOL isNavBarIsOpaque = !self.viewController.navigationController.navigationBar.isTranslucent && self.viewController.navigationController.navigationBar.alpha == 1;
        
        if (isNavBarIsHidden || isNavBarIsOpaque) {
            topOffset = -30.f;
        }
        
        backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.f, topOffset, 0.f));
    }
    else if (self.position == TSMessagePositionBottom)
    {
        backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.f, 0.f, -30.f, 0.f));
    }
    
    self.backgroundBlurView.frame = backgroundFrame;
}

- (void)prepareForDisplay
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGFloat actualHeight = self.frame.size.height;
    CGFloat topPosition = -actualHeight;
    
    if (self.position == TSMessagePositionBottom)
    {
        topPosition = self.viewController.view.bounds.size.height;
    }
    
    self.frame = CGRectMake(0.0, topPosition, self.viewController.view.bounds.size.width, actualHeight);
}

#pragma mark - Actions

- (void)handleButtonTap:(id) sender
{
    if (self.buttonCallback)
    {
        self.buttonCallback(self);
    }
}

- (void)handleViewTap:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state != UIGestureRecognizerStateRecognized) return;
    
    if (self.isUserDismissEnabled)
    {
        [self dismiss];
    }
    
    if (self.tapCallback)
    {
        self.tapCallback(self);
    }
}

- (void)handleViewSwipe:(UISwipeGestureRecognizer *)swipeRecognizer
{
    if (swipeRecognizer.state == UIGestureRecognizerStateRecognized && self.isUserDismissEnabled)
    {
        [self dismiss];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return !([touch.view isKindOfClass:[UIControl class]]);
}

- (void)dismiss
{
    if (self == [TSMessage sharedMessage].currentMessage)
    {
        [[TSMessage sharedMessage] performSelectorOnMainThread:@selector(dismissCurrentMessage) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [[TSMessage sharedMessage] performSelectorOnMainThread:@selector(dismissMessage:) withObject:self waitUntilDone:NO];
    }
}

#pragma mark - Private

- (NSString *)title
{
    return self.titleLabel.text;
}

- (NSString *)subtitle
{
    return self.contentLabel.text;
}

@end
