//
//  TSMessageDefaultView.m
//  Pods
//
//  Created by Fedya Skitsko on 4/4/14.
//
//

#import "TSMessageDefaultView.h"
#import "HexColors.h"
#import "TSBlurView.h"

@interface TSMessageDefaultView()

/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UIButton *button;

@end

@implementation TSMessageDefaultView

#pragma mark - Initialization

- (id)initWithItem:(TSMessageItem *)item
{
    if (self = [super initWithItem:item])
    {
        [self setup];
    }
    return self;
}

#pragma mark - Setters / Getters

#pragma mark - Lifecycle

- (void)setup {
    [super setup];
    
    CGFloat screenWidth = self.item.viewController.view.bounds.size.width;
    
    // Set up button (if set)
    if ([self.item.buttonTitle length])
    {
        UIColor *fontColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"textColor"] alpha:1.0];
        
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *buttonBackgroundImage = [[UIImage imageNamed:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"buttonBackgroundImageName"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
        
        if (!buttonBackgroundImage)
        {
            buttonBackgroundImage = [[UIImage imageNamed:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"NotificationButtonBackground"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
        }
        
        [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        [self.button setTitle:self.item.buttonTitle forState:UIControlStateNormal];
        
        UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"buttonTitleShadowColor"] alpha:1.0];
        if (!buttonTitleShadowColor)
        {
            buttonTitleShadowColor = self.titleLabel.shadowColor;
        }
        
        [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];
        
        UIColor *buttonTitleTextColor = [UIColor colorWithHexString:[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"buttonTitleTextColor"] alpha:1.0];
        if (!buttonTitleTextColor)
        {
            buttonTitleTextColor = fontColor;
        }
        
        [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.button.titleLabel.shadowOffset = CGSizeMake([[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"buttonTitleShadowOffsetX"] floatValue],
                                                         [[[TSMessage notificationDesignWithMessageType:self.item.messageType] valueForKey:@"buttonTitleShadowOffsetY"] floatValue]);
        [self.button addTarget:self
                        action:@selector(buttonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        
        self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
        [self.button sizeToFit];
        self.button.frame = CGRectMake(screenWidth - TSMessageViewPadding - self.button.frame.size.width,
                                       0.0,
                                       self.button.frame.size.width,
                                       31.0);
        
        [self addSubview:self.button];
        
        self.textSpaceRight = self.button.frame.size.width + TSMessageViewPadding;
    }
}

+ (CGFloat)heightWithItem:(TSMessageDefaultItem *)item {
    CGFloat calculatedHeight = [super heightWithItem:item];
    
    return calculatedHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentHeight = self.frame.size.height;
    
    // z-align button
    self.button.center = CGPointMake([self.button center].x,
                                     roundf(currentHeight / 2.0));
    
    if (self.button)
    {
        self.button.frame = CGRectMake(self.frame.size.width - self.textSpaceRight,
                                       roundf((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
}

#pragma mark - Target/Action

- (void)buttonTapped:(id) sender
{
    if (self.item.buttonSelectionHandler)
    {
        self.item.buttonSelectionHandler(self.item);
    }
    
    [self fadeMeOut];
}

@end
