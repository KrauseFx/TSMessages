//
//  TSMessageView.m
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import "TSMessageView.h"
#import "UIColor+MLColorAdditions.h"

#define TSMessageViewPadding 15.0

#define TSDesignFileName @"design.json"

static CGFloat screenWidth;
static CGFloat leftSpace;
static NSDictionary *notificationDesign;

@interface TSMessageView ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation TSMessageView

- (id)initWithTitle:(NSString *)title withContent:(NSString *)content withType:(notificationType)notificationType
{
    if (!notificationDesign)
    {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:TSDesignFileName];
        notificationDesign = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                             options:kNilOptions
                                                               error:nil];
    }
    
    screenWidth = [[[TSMessage sharedMessage] viewController] view].frame.size.width;
    leftSpace = 2 * TSMessageViewPadding;
    
    if ((self = [self init]))
    {
        _title = title;
        _content = content;
        CGFloat currentHeight;
        NSDictionary *current;
        NSString *currentString;
        switch (notificationType)
        {
            case kNotificationMessage:
            {
                currentString = @"message";
                break;
            }
            case kNotificationError:
            {
                currentString = @"error";
                break;
            }
            case kNotificationSuccessful:
            {
                currentString = @"success";
                break;
            }
            case kNotificationWarning:
            {
                currentString = @"warning";
                break;
            }
                
            default:
                break;
        }
        
        current = [notificationDesign valueForKey:currentString];
        
        self.alpha = 0.0;
        
        UIImage *image;
        if ([current valueForKey:@"imageName"])
        {
            image = [UIImage imageNamed:[current valueForKey:@"imageName"]];
        }
        
        // add background image here
        UIImage *backgroundImage = [[UIImage imageNamed:[current valueForKey:@"backgroundImageName"]] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:self.backgroundImageView];
        
        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]
                                                   alpha:1.0];
        
        if (image) leftSpace += image.size.width + 2 * TSMessageViewPadding;
        
        // Set up title label
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:title];
        [titleLabel setTextColor:fontColor];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:[[current valueForKey:@"titleFontSize"] floatValue]]];
        [titleLabel setShadowColor:[UIColor colorWithHexString:[current valueForKey:@"shadowColor"] alpha:1.0]];
        [titleLabel setShadowOffset:CGSizeMake([[current valueForKey:@"shadowOffsetX"] floatValue],
                                               [[current valueForKey:@"shadowOffsetY"] floatValue])];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.frame = CGRectMake(leftSpace,
                                      TSMessageViewPadding,
                                      screenWidth - TSMessageViewPadding - leftSpace,
                                      0.0);
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        
        // Set up content label (if set)
        if (content)
        {
            UILabel *contentLabel = [[UILabel alloc] init];
            [contentLabel setText:content];
            [contentLabel setTextColor:fontColor];
            [contentLabel setBackgroundColor:[UIColor clearColor]];
            [contentLabel setFont:[UIFont systemFontOfSize:[[current valueForKey:@"contentFontSize"] floatValue]]];
            [contentLabel setShadowColor:titleLabel.shadowColor];
            [contentLabel setShadowOffset:titleLabel.shadowOffset];
            contentLabel.lineBreakMode = titleLabel.lineBreakMode;
            contentLabel.numberOfLines = 0;
            contentLabel.frame = CGRectMake(leftSpace,
                                            titleLabel.frame.origin.y + titleLabel.frame.size.height + 5.0,
                                            screenWidth - TSMessageViewPadding - leftSpace,
                                            0.0);
            [contentLabel sizeToFit];
            [self addSubview:contentLabel];
            currentHeight = contentLabel.frame.origin.y + contentLabel.frame.size.height;
        }
        else
        {
            // only the title was set
            currentHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height;
        }
        currentHeight += TSMessageViewPadding;
        
        if (image)
        {
            self.imageView = [[UIImageView alloc] initWithImage:image];
            self.imageView.frame = CGRectMake(TSMessageViewPadding * 2,
                                              TSMessageViewPadding,
                                              image.size.width,
                                              image.size.height);
            [self addSubview:self.imageView];
            
            // Check if that makes the popup larger (height)
            if (self.imageView.frame.origin.y + self.imageView.frame.size.height + TSMessageViewPadding > currentHeight)
            {
                currentHeight = self.imageView.frame.origin.y + self.imageView.frame.size.height + TSMessageViewPadding;
            }
            else
            {
                // z-align
                self.imageView.center = CGPointMake([self.imageView center].x, round(currentHeight / 2.0));
            }
        }
        
        // Add a border on the bottom
        self.borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   currentHeight,
                                                                   screenWidth,
                                                                   [[current valueForKey:@"borderHeight"] floatValue])];
        self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]
                                                                alpha:1.0];
        [self addSubview:self.borderView];
        currentHeight += self.borderView.frame.size.height;
        
        self.frame = CGRectMake(0.0, -currentHeight, screenWidth, currentHeight);
        
        self.backgroundImageView.frame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                                    self.backgroundImageView.frame.origin.y,
                                                    self.frame.size.width,
                                                    currentHeight);
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(fadeMeOut)];
        [self.gestureRec setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:self.gestureRec];
        
        _tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(fadeMeOut)];
        [self addGestureRecognizer:self.tapRec];
    }
    return self;
}

- (void)fadeMeOut
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[TSMessage sharedMessage] performSelector:@selector(fadeOutNotification:) withObject:self];
                   });
}

- (void)layoutSubviews {
    screenWidth = [[[TSMessage sharedMessage] viewController] view].frame.size.width;
    CGFloat currentHeight;
    
    for(UIView *v in [self subviews])
    {
        if ([v isKindOfClass:[UILabel class]])
        {
            CGRect rect = v.frame;
            rect.size.width = screenWidth - TSMessageViewPadding - leftSpace;
            v.frame = rect;
            [v sizeToFit];
            currentHeight = v.frame.origin.y + v.frame.size.height;
        }
    }
    
    currentHeight += TSMessageViewPadding;
    
    if(self.imageView)
    {
        self.imageView.center = CGPointMake([self.imageView center].x, round(currentHeight / 2.0));
    }
    
    CGRect bRect = self.borderView.frame;
    bRect.origin.y = currentHeight;
    self.borderView.frame = bRect;
    
    currentHeight += self.borderView.frame.size.height;
    
    CGRect selfRect = self.frame;
    selfRect.size.height = currentHeight;
    self.frame = selfRect;
    
    CGRect bkRect = self.backgroundImageView.frame;
    bkRect.size.height = currentHeight;
    self.backgroundImageView.frame = bkRect;
}

@end
