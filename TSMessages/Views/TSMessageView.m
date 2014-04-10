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


@interface TSMessageView ()<UIGestureRecognizerDelegate>

/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation TSMessageView

#pragma mark - Initialization

+ (instancetype)messageWithItem:(TSMessageItem *)item {
    return [[self alloc] initWithItem:item];
}

-(id)initWithItem:(TSMessageItem *)item {
    if (self = [super init]) {
        self.item = item;
        
        [self setup];
    }
    
    return self;
}

#pragma mark - Height

+ (CGFloat)heightWithItem:(TSMessageItem *)item {
    
    CGFloat calculatedHeight = TSMessageViewPadding; //padding on top
    
    if (item.title.length) {
        CGFloat fontSize = [[[TSMessage notificationDesignWithMessageType:item.messageType] valueForKey:@"titleFontSize"] floatValue];
        NSString *fontName = [[TSMessage notificationDesignWithMessageType:item.messageType] valueForKey:@"titleFontName"];
        UIFont *titleFont = fontName ? [UIFont fontWithName:fontName size:fontSize] : [UIFont boldSystemFontOfSize:fontSize];
        CGSize titleSize = [item.title sizeWithFont:titleFont forWidth:item.viewController.view.bounds.size.width - TSMessageViewPadding * 4 lineBreakMode:NSLineBreakByWordWrapping];
        
        calculatedHeight += titleSize.height + 5.f; //title size
    }
    
    if (item.subtitle.length) {
        CGFloat fontSizeContent = [[[TSMessage notificationDesignWithMessageType:item.messageType] valueForKey:@"contentFontSize"] floatValue];
        NSString *fontNameContent = [[TSMessage notificationDesignWithMessageType:item.messageType] valueForKey:@"contentFontName"];
        UIFont *contentFont = fontNameContent ? [UIFont fontWithName:fontNameContent size:fontSizeContent] : [UIFont boldSystemFontOfSize:fontSizeContent];
        CGSize contentSize = [item.subtitle sizeWithFont:contentFont forWidth:item.viewController.view.bounds.size.width - TSMessageViewPadding * 4 lineBreakMode:NSLineBreakByWordWrapping];
        
        calculatedHeight += contentSize.height + 5.f; //content size
    }
    
    if (item.image)
    {
        // Check if that makes the popup larger (height)
        CGFloat imageSize = TSMessageViewPadding + item.image.size.height + TSMessageViewPadding;
        if (TSMessageViewPadding + item.image.size.height + TSMessageViewPadding > calculatedHeight)
        {
            calculatedHeight = imageSize;
        }
    }
    
    return calculatedHeight + TSMessageViewPadding; //padding at bottom
}

#pragma mark - Setters / Getters

-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeCenter;
        _iconImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTap:)];
        [_iconImageView addGestureRecognizer:tapGesture];
    }
    return _iconImageView;
}

-(UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        // add background image here
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    }
    return _backgroundImageView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setText:_item.title];
        UIColor *fontColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"textColor"] alpha:1.0];
        [_titleLabel setTextColor:fontColor];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        CGFloat fontSize = [[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"titleFontSize"] floatValue];
        NSString *fontName = [[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"titleFontName"];
        UIFont *titleFont = fontName ? [UIFont fontWithName:fontName size:fontSize] : [UIFont boldSystemFontOfSize:fontSize];
        _titleLabel.font = titleFont;
        [_titleLabel setShadowColor:[UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"shadowColor"] alpha:1.0]];
        [_titleLabel setShadowOffset:CGSizeMake([[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"shadowOffsetX"] floatValue],
                                                    [[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"shadowOffsetY"] floatValue])];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
    }
    return _titleLabel;
}

-(UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setText:_item.subtitle];

        UIColor *contentTextColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"contentTextColor"] alpha:1.0];
        CGFloat fontSizeContent = [[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"contentFontSize"] floatValue];
        NSString *fontNameContent = [[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"contentFontName"];

        if (!contentTextColor) {
            UIColor *fontColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"textColor"] alpha:1.0];
            contentTextColor = fontColor;
        }
        [_contentLabel setTextColor:contentTextColor];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        if (fontNameContent) {
            [_contentLabel setFont:[UIFont fontWithName:fontNameContent size:fontSizeContent]];
        } else {
            [_contentLabel setFont:[UIFont systemFontOfSize:fontSizeContent]];
        }
        [_contentLabel setShadowColor:self.titleLabel.shadowColor];
        [_contentLabel setShadowOffset:self.titleLabel.shadowOffset];
        _contentLabel.lineBreakMode = self.titleLabel.lineBreakMode;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

-(UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0, // will be set later
                                                                   _item.viewController.view.bounds.size.width,
                                                                   [[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"borderHeight"] floatValue])];
        _borderView.backgroundColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"borderColor"]
                                                                alpha:1.0];
        _borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    }
    return _borderView;
}

#pragma mark - Setup

- (void)setup {
    self.textSpaceLeft = 2 * TSMessageViewPadding;
    self.textSpaceRight = 2 * TSMessageViewPadding;
    
    //Set up background view
    UIImage *backgroundImage = [[UIImage imageNamed:[[TSMessage notificationDesignWithMessageType:_item.messageType] valueForKey:@"backgroundImageName"]] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    if (backgroundImage) {
        self.backgroundImageView.image = backgroundImage;
        [self addSubview:self.backgroundImageView];
    } else {
        UIColor *backgroundColor = [UIColor colorWithHexString:[TSMessage notificationDesignWithMessageType:_item.messageType][@"backgroundColor"]];
        self.backgroundColor = backgroundColor;
    }
    
    // Set up title label
    if (_item.title.length) {
        [self addSubview:self.titleLabel];
    }
    
    // Set up content label (if set)
    if ([_item.subtitle length]) {
        [self addSubview:self.contentLabel];
    }
    
    // Add a border on the bottom (or on the top, depending on the view's postion)
    if (![TSMessage iOS7StyleEnabled])
    {
        [self addSubview:self.borderView];
    }
    
    if (_item.dismissingEnabled)
    {
        UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(fadeMeOut)];
        [gestureRec setDirection:(_item.messagePosition == TSMessageNotificationPositionTop ?
                                  UISwipeGestureRecognizerDirectionUp :
                                  UISwipeGestureRecognizerDirectionDown)];
        [self addGestureRecognizer:gestureRec];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    if (!self.item.image && [[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"imageName"])
    {
        self.item.image = [UIImage imageNamed:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"imageName"]];
    }
    
    if (self.item.image) self.textSpaceLeft += self.item.image.size.width + 2 * TSMessageViewPadding;
    
    if (self.item.image)
    {
        self.iconImageView.image = self.item.image;
        self.iconImageView.frame = CGRectMake(0, 0, self.item.image.size.width, self.item.image.size.height);
        [self addSubview:self.iconImageView];
    }
    
    if (_item.messagePosition == TSMessageNotificationPositionTop)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    else
    {
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    }
    
    CGFloat actualHeight = [TSMessageView heightWithItem:_item];
    CGFloat topPosition = -actualHeight;
    
    if (_item.messagePosition == TSMessageNotificationPositionBottom)
    {
        topPosition = _item.viewController.view.bounds.size.height;
    }
    
    self.frame = CGRectMake(0.0, topPosition, _item.viewController.view.bounds.size.width, actualHeight);
}

#pragma mark - Actions

- (void)fadeMeOut
{
    [[TSMessage sharedMessage] fadeOutNotification:self];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (_item.selectionHandler)
        {
            NSLog(@"selectionHandler triggered");
            _item.selectionHandler(_item);
        }
    }
}

- (void)iconTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (_item.iconSelectionHandler)
        {
            NSLog(@"iconSelectionHandler triggered");
            _item.iconSelectionHandler(_item);
        }
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (_item.duration == TSMessageNotificationDurationEndless && self.superview && !self.window ) {
        // view controller was dismissed, let's fade out
        [self fadeMeOut];
    }
}

#pragma mark - Layout

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat currentHeight;
    CGFloat screenWidth = _item.viewController.view.bounds.size.width;
    
    self.titleLabel.frame = CGRectMake(self.textSpaceLeft,
                                       TSMessageViewPadding,
                                       screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];
    
    if ([_item.subtitle length])
    {
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];
        
        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        // only the title was set
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }
    
    currentHeight += TSMessageViewPadding;
    
    if (_item.messagePosition == TSMessageNotificationPositionTop)
    {
        // Correct the border position
        CGRect borderFrame = self.borderView.frame;
        borderFrame.origin.y = currentHeight;
        self.borderView.frame = borderFrame;
    }
    
    currentHeight += self.borderView.frame.size.height;
    
    if (self.iconImageView.image)
    {
        // Check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + TSMessageViewPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height;
        }
        else
        {
            // z-align
            self.iconImageView.center = CGPointMake([self.iconImageView center].x, roundf(currentHeight / 2.0));
        }
        
        self.iconImageView.frame = CGRectMake(round((_textSpaceLeft - self.iconImageView.frame.size.width)/2),
                                              self.iconImageView.frame.origin.y,
                                              self.iconImageView.frame.size.width,
                                              self.iconImageView.frame.size.height);
    }
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
    
    CGRect backgroundFrame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                        self.backgroundImageView.frame.origin.y,
                                        screenWidth,
                                        currentHeight);
    
    // increase frame of background view because of the spring animation
    if ([TSMessage iOS7StyleEnabled])
    {
        if (_item.messagePosition == TSMessageNotificationPositionTop)
        {
            float topOffset = 0.f;
            
            UINavigationController *navigationController = _item.viewController.navigationController;
            if (!navigationController && [_item.viewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)_item.viewController;
            }
            BOOL isNavBarIsHidden = !navigationController || [TSMessage isNavigationBarInNavigationControllerHidden:_item.viewController.navigationController];
            BOOL isNavBarIsOpaque = !_item.viewController.navigationController.navigationBar.isTranslucent && _item.viewController.navigationController.navigationBar.alpha == 1;
            
            if (isNavBarIsHidden || isNavBarIsOpaque) {
                topOffset = -30.f;
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.f, 0.f, 0.f));
        }
        else if (_item.messagePosition == TSMessageNotificationPositionBottom)
        {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.f, 0.f, -30.f, 0.f));
        }
    }
    
    self.backgroundImageView.frame = backgroundFrame;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

@end
