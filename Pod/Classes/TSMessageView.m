//
//  TSMessageView.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessageView.h"
#import "HexColors.h"
#import "TSBlurView.h"
#import "TSMessage.h"
#import <Masonry/Masonry.h>

#define TSMessageViewMinimumPadding 15.0

#define TSDesignFileName @"TSMessagesDefaultDesign"

static NSMutableDictionary *_notificationDesign;

@interface TSMessage (TSMessageView)
- (void)fadeOutNotification:(TSMessageView *)currentView; // private method of TSMessage, but called by TSMessageView in -[fadeMeOut]
@end

@interface TSMessageView () <UIGestureRecognizerDelegate>

/** The displayed title of this message */
@property (nonatomic, strong) NSString *title;

/** The displayed subtitle of this message view */
@property (nonatomic, strong) NSString *subtitle;

/** The title of the added button */
@property (nonatomic, strong) NSString *buttonTitle;

/** The view controller this message is displayed in */
@property (nonatomic, strong) UIViewController *viewController;


/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundView; // Only used in iOS 7

@property (copy) void (^callback)();
@property (copy) void (^buttonCallback)();

@end


@implementation TSMessageView{
    TSMessageNotificationType notificationType;
}
-(void) setContentFont:(UIFont *)contentFont{
    _contentFont = contentFont;
    [self.contentLabel setFont:contentFont];
}

-(void) setContentTextColor:(UIColor *)contentTextColor{
    _contentTextColor = contentTextColor;
    [self.contentLabel setTextColor:_contentTextColor];
}

-(void) setTitleFont:(UIFont *)aTitleFont{
    _titleFont = aTitleFont;
    [self.titleLabel setFont:_titleFont];
}

-(void)setTitleTextColor:(UIColor *)aTextColor{
    _titleTextColor = aTextColor;
    [self.titleLabel setTextColor:_titleTextColor];
}

-(void) setMessageIcon:(UIImage *)messageIcon{
    _messageIcon = messageIcon;
    [self updateCurrentIcon];
}

-(void) setErrorIcon:(UIImage *)errorIcon{
    _errorIcon = errorIcon;
    [self updateCurrentIcon];
}

-(void) setSuccessIcon:(UIImage *)successIcon{
    _successIcon = successIcon;
    [self updateCurrentIcon];
}

-(void) setWarningIcon:(UIImage *)warningIcon{
    _warningIcon = warningIcon;
    [self updateCurrentIcon];
}

-(void) updateCurrentIcon{
    UIImage *image = nil;
    switch (notificationType)
    {
        case TSMessageNotificationTypeMessage:
        {
            image = _messageIcon;
            self.iconImageView.image = _messageIcon;
            break;
        }
        case TSMessageNotificationTypeError:
        {
            image = _errorIcon;
            self.iconImageView.image = _errorIcon;
            break;
        }
        case TSMessageNotificationTypeSuccess:
        {
            image = _successIcon;
            self.iconImageView.image = _successIcon;
            break;
        }
        case TSMessageNotificationTypeWarning:
        {
            image = _warningIcon;
            self.iconImageView.image = _warningIcon;
            break;
        }
        default:
            break;
    }
    self.iconImageView.frame = CGRectMake([self verticalPadding] * 2,
                                          [self verticalPadding],
                                          image.size.width,
                                          image.size.height);
}




+ (NSMutableDictionary *)notificationDesign
{
    if (!_notificationDesign)
    {
        NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:TSDesignFileName ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSAssert(data != nil, @"Could not read TSMessages config file from main bundle with name %@.json", TSDesignFileName);

        _notificationDesign = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:kNilOptions
                                                                                                              error:nil]];
    }

    return _notificationDesign;
}


+ (void)addNotificationDesignFromFile:(NSString *)filename
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *design = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                               options:kNilOptions
                                                                 error:nil];

        [[TSMessageView notificationDesign] addEntriesFromDictionary:design];
    }
    else
    {
        NSAssert(NO, @"Error loading design file with name %@", filename);
    }
}

- (CGFloat)verticalPadding
{
    // Adds 10 padding to to cover navigation bar
    return self.messagePosition == TSMessageNotificationPositionNavBarOverlay ? TSMessageViewMinimumPadding + 10.0f : TSMessageViewMinimumPadding;
}

- (CGFloat)horizonalPadding
{
    return TSMessageViewMinimumPadding;
}

- (UIView*)containingView{
    if(self.viewController){
        return self.viewController.view;
    }else{
        return [UIApplication sharedApplication].keyWindow;
    }
}

- (id)initWithTitle:(NSString *)title
           subtitle:(NSString *)subtitle
              image:(UIImage *)image
               type:(TSMessageNotificationType)aNotificationType
           duration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
           callback:(void (^)())callback
        buttonTitle:(NSString *)buttonTitle
     buttonCallback:(void (^)())buttonCallback
         atPosition:(TSMessageNotificationPosition)position
canBeDismissedByUser:(BOOL)dismissingEnabled
{
    NSDictionary *notificationDesign = [TSMessageView notificationDesign];

    if ((self = [self init]))
    {
        _title = title;
        _subtitle = subtitle;
        _buttonTitle = buttonTitle;
        _duration = duration;
        _viewController = viewController;
        _messagePosition = position;
        self.callback = callback;
        self.buttonCallback = buttonCallback;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        CGFloat verticalPadding = [self verticalPadding];
        CGFloat horizontalPadding = [self horizonalPadding];

        NSDictionary *current;
        NSString *currentString;
        notificationType = aNotificationType;
        switch (notificationType)
        {
            case TSMessageNotificationTypeMessage:
            {
                currentString = @"message";
                break;
            }
            case TSMessageNotificationTypeError:
            {
                currentString = @"error";
                break;
            }
            case TSMessageNotificationTypeSuccess:
            {
                currentString = @"success";
                break;
            }
            case TSMessageNotificationTypeWarning:
            {
                currentString = @"warning";
                break;
            }

            default:
                break;
        }

        current = [notificationDesign valueForKey:currentString];


        if (!image && [[current valueForKey:@"imageName"] length])
        {
            image = [self bundledImageNamed:[current valueForKey:@"imageName"]];
        }

        if (![TSMessage iOS7StyleEnabled])
        {
            self.alpha = 0.0;

            // add background image here
            UIImage *backgroundImage = [self bundledImageNamed:[current valueForKey:@"backgroundImageName"]];
            backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];

            _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:self.backgroundImageView];
            [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                if(self.messagePosition == TSMessageNotificationPositionBottom){
                    make.leading.and.trailing.equalTo(self);
                    make.top.equalTo(self.mas_top);
                    make.bottom.equalTo(self).offset([self bottomOverlap]);
                }else{
                    make.leading.and.trailing.equalTo(self);
                    make.top.equalTo(self).offset([self topOverlap]);
                    make.bottom.equalTo(self.mas_bottom);
                }
            }];
        }
        else
        {
            NSNumber* blurValue = [current valueForKey:@"blurBackground"];
            BOOL useBlur = YES;
            if(blurValue){
                useBlur = blurValue.boolValue;
            }
            
            UIColor* bgColor = [UIColor colorWithHexString:current[@"backgroundColor"]];

            if(useBlur){
                TSBlurView* blur = [[TSBlurView alloc] init];
                blur.blurTintColor = bgColor;
                _backgroundView = blur;

            }else{
                _backgroundView = [[UIView alloc] init];
                _backgroundView.backgroundColor = bgColor;

            }
            
            self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:self.backgroundView];
            [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                if(self.messagePosition == TSMessageNotificationPositionBottom){
                    make.leading.and.trailing.equalTo(self);
                    make.top.equalTo(self.mas_top);
                    make.bottom.equalTo(self).offset([self bottomOverlap]);
                }else{
                    make.leading.and.trailing.equalTo(self);
                    make.top.equalTo(self).offset([self topOverlap]);
                    make.bottom.equalTo(self.mas_bottom);
                }
            }];
        }

        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]];

        // Setup Image
        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];
            self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            UIColor* imageTintColor = [UIColor colorWithHexString:[current valueForKey:@"imageTintColor"]];
            if(imageTintColor){
                self.iconImageView.tintColor = imageTintColor;
            }
            [self addSubview:self.iconImageView];
            [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(horizontalPadding);
                make.centerY.equalTo(self);
                make.width.equalTo(@(image.size.width));
                make.height.equalTo(@(image.size.height));
            }];
        }

        
        // Set up title label
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textAlignment = NSTextAlignmentNatural;
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:fontColor];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        CGFloat fontSize = [[current valueForKey:@"titleFontSize"] floatValue];
        NSString *fontName = [current valueForKey:@"titleFontName"];
        if (fontName != nil) {
            [self.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
        } else {
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
        }
        [self.titleLabel setShadowColor:[UIColor colorWithHexString:[current valueForKey:@"shadowColor"]]];
        [self.titleLabel setShadowOffset:CGSizeMake([[current valueForKey:@"shadowOffsetX"] floatValue],
                                                    [[current valueForKey:@"shadowOffsetY"] floatValue])];

        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(self.iconImageView){
                make.leading.equalTo(self.iconImageView.mas_trailing).offset(horizontalPadding);
            }else{
                make.leading.equalTo(self).offset(horizontalPadding);
            }
            make.top.equalTo(self.mas_top).offset(verticalPadding);

            if(!buttonCallback){
                make.trailing.equalTo(self.mas_trailing).offset(-horizontalPadding);
            }

            if(![subtitle length]){
                make.bottom.equalTo(self).offset(-verticalPadding);
            }
        }];

        // Set up content label (if set)
        if ([subtitle length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:subtitle];
            self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
            self.contentLabel.textAlignment = NSTextAlignmentNatural;

            UIColor *contentTextColor = [UIColor colorWithHexString:[current valueForKey:@"contentTextColor"]];
            if (!contentTextColor)
            {
                contentTextColor = fontColor;
            }
            [self.contentLabel setTextColor:contentTextColor];
            [self.contentLabel setBackgroundColor:[UIColor clearColor]];
            CGFloat fontSize = [[current valueForKey:@"contentFontSize"] floatValue];
            NSString *fontName = [current valueForKey:@"contentFontName"];
            if (fontName != nil) {
                [self.contentLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
            } else {
                [self.contentLabel setFont:[UIFont systemFontOfSize:fontSize]];
            }
            [self.contentLabel setShadowColor:self.titleLabel.shadowColor];
            [self.contentLabel setShadowOffset:self.titleLabel.shadowOffset];
            self.contentLabel.lineBreakMode = self.titleLabel.lineBreakMode;
            self.contentLabel.numberOfLines = 0;

            [self addSubview:self.contentLabel];
            [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.and.trailing.equalTo(self.titleLabel);
                make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
                make.bottom.equalTo(self).offset(-verticalPadding);
            }];
        }

        // Set up button (if set)
        if (buttonCallback)
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            self.button.translatesAutoresizingMaskIntoConstraints = NO;

            UIColor* buttonTintColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTintColor"]];
            if(buttonTintColor){
                self.button.tintColor = buttonTintColor;
            }

            UIImage *buttonBackgroundImage = [self bundledImageNamed:[current valueForKey:@"buttonBackgroundImageName"]];

            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];

            if (!buttonBackgroundImage)
            {
                buttonBackgroundImage = [self bundledImageNamed:[current valueForKey:@"NotificationButtonBackground"]];
                buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            }

            [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            
            UIImage *buttonImage = [self bundledImageNamed:[current valueForKey:@"buttonImageName"]];
            [self.button setImage:buttonImage forState:UIControlStateNormal];

            [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];

            UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleShadowColor"]];
            if (!buttonTitleShadowColor)
            {
                buttonTitleShadowColor = self.titleLabel.shadowColor;
            }

            [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];

            UIColor *buttonTitleTextColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleTextColor"]];
            if (!buttonTitleTextColor)
            {
                buttonTitleTextColor = fontColor;
            }

            [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            self.button.titleLabel.shadowOffset = CGSizeMake([[current valueForKey:@"buttonTitleShadowOffsetX"] floatValue],
                                                             [[current valueForKey:@"buttonTitleShadowOffsetY"] floatValue]);
            [self.button addTarget:self
                            action:@selector(buttonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];

            self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
            [self addSubview:self.button];
            
            [self.button sizeToFit];
            [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.titleLabel.mas_trailing).offset(horizontalPadding);
                make.trailing.equalTo(self.mas_trailing).offset(-horizontalPadding);
                make.centerY.equalTo(self);
                make.width.equalTo(@(self.button.frame.size.width));
            }];
        }

        // Add a border on the bottom (or on the top, depending on the view's postion)
        if (![TSMessage iOS7StyleEnabled])
        {
            _borderView = [[UIView alloc] initWithFrame:CGRectZero];
            self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]];
            self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:self.borderView];
            [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.and.trailing.equalTo(self);
                make.height.equalTo([current valueForKey:@"borderHeight"] ? : @1);
                if(self.messagePosition == TSMessageNotificationPositionBottom){
                    make.top.equalTo(self);
                }else{
                    make.bottom.equalTo(self);
                }
            }];

        }

        if (dismissingEnabled)
        {
            UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(fadeMeOut)];
            [gestureRec setDirection:(self.messagePosition == TSMessageNotificationPositionTop ?
                                      UISwipeGestureRecognizerDirectionUp :
                                      UISwipeGestureRecognizerDirectionDown)];
            [self addGestureRecognizer:gestureRec];

            UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(fadeMeOut)];
            [self addGestureRecognizer:tapRec];
        }

        if (self.callback) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tapGesture.delegate = self;
            [self addGestureRecognizer:tapGesture];
        }
    }
    return self;
}

- (CGFloat)topOverlap{
    return -30.0;
}
- (CGFloat)bottomOverlap{
    return 30.0;
}


- (void)fadeMeOut
{
    [[TSMessage sharedMessage] performSelectorOnMainThread:@selector(fadeOutNotification:) withObject:self waitUntilDone:NO];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.duration == TSMessageNotificationDurationEndless && self.superview && !self.window )
    {
        // view controller was dismissed, let's fade out
        [self fadeMeOut];
    }
}
#pragma mark - Target/Action

- (void)buttonTapped:(id) sender
{
    if (self.buttonCallback)
    {
        self.buttonCallback();
    }

    [self fadeMeOut];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.callback)
        {
            self.callback();
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark - Grab Image From Pod Bundle
- (UIImage *)bundledImageNamed:(NSString*)name{
    UIImage* image = [UIImage imageNamed:name];
    
    if(!image){
        image = [self imageInBundle:[NSBundle bundleForClass:[self class]] named:name];;
    }
    return image;
}

- (UIImage *)imageInBundle:(NSBundle*)bundle named:(NSString*)name{
    NSString *imagePath = [bundle pathForResource:name ofType:nil];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    return image;
}



@end
