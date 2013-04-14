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
static NSDictionary *notificationDesign;

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
    
    screenWidth = [[[TSMessage sharedNotification] viewController] view].frame.size.width;
    
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
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:backgroundImageView];
        
        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]
                                                   alpha:1.0];
        
        
        CGFloat leftSpace = 2 * TSMessageViewPadding;
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
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(TSMessageViewPadding * 2,
                                         TSMessageViewPadding,
                                         image.size.width,
                                         image.size.height);
            [self addSubview:imageView];
            
            // Check if that makes the popup larger (height)
            if (imageView.frame.origin.y + imageView.frame.size.height + TSMessageViewPadding > currentHeight)
            {
                currentHeight = imageView.frame.origin.y + imageView.frame.size.height + TSMessageViewPadding;
            }
            else
            {
                // z-align
                imageView.center = CGPointMake([imageView center].x, round(currentHeight / 2.0));
            }
        }
        
        // Add a border on the bottom
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      currentHeight,
                                                                      screenWidth,
                                                                      [[current valueForKey:@"borderHeight"] floatValue])];
        borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]
                                                           alpha:1.0];
        [self addSubview:borderView];
        currentHeight += borderView.frame.size.height;
        
        self.frame = CGRectMake(0.0, -currentHeight, screenWidth, currentHeight);
        
        backgroundImageView.frame = CGRectMake(backgroundImageView.frame.origin.x,
                                               backgroundImageView.frame.origin.y,
                                               self.frame.size.width,
                                               currentHeight);
        
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
    [UIView animateWithDuration:TSMessageAnimationDuration animations:^
     {
         self.frame = CGRectMake(self.frame.origin.x,
                                 -self.frame.size.height,
                                 self.frame.size.width,
                                 self.frame.size.height);
         self.alpha = 0.0;
     }];
}

@end
