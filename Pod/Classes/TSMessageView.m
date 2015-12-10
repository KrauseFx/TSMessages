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

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (copy) void (^callback)();
@property (copy) void (^buttonCallback)();

- (CGFloat)updateHeightOfMessageView;
- (void)layoutSubviews;

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

        CGFloat screenWidth = [self containingView].bounds.size.width;
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
            self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.backgroundImageView];
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
            
            self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.backgroundView];
        }

        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]];


        self.textSpaceLeft = horizontalPadding;
        if (image) self.textSpaceLeft += image.size.width + horizontalPadding;

        // Set up title label
        _titleLabel = [[UILabel alloc] init];
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

        // Set up content label (if set)
        if ([subtitle length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:subtitle];

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
        }

        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];
            
            UIColor* imageTintColor = [UIColor colorWithHexString:[current valueForKey:@"imageTintColor"]];
            if(imageTintColor){
                self.iconImageView.tintColor = imageTintColor;
            }
            self.iconImageView.frame = CGRectMake(horizontalPadding,
                                                  verticalPadding,
                                                  image.size.width,
                                                  image.size.height);
            [self addSubview:self.iconImageView];
        }

        // Set up button (if set)
        if (buttonCallback)
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];

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
            [self.button sizeToFit];
            self.button.frame = CGRectMake(screenWidth - horizontalPadding - self.button.frame.size.width,
                                           0.0,
                                           self.button.frame.size.width,
                                           31.0);

            [self addSubview:self.button];

            self.textSpaceRight = self.button.frame.size.width + verticalPadding;
        }

        // Add a border on the bottom (or on the top, depending on the view's postion)
        if (![TSMessage iOS7StyleEnabled])
        {
            _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0, // will be set later
                                                                   screenWidth,
                                                                   [[current valueForKey:@"borderHeight"] floatValue])];
            self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]];
            self.borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.borderView];
        }


        CGFloat actualHeight = [self updateHeightOfMessageView]; // this call also takes care of positioning the labels
        CGFloat topPosition = -actualHeight;

        if (self.messagePosition == TSMessageNotificationPositionBottom)
        {
            topPosition = [self containingView].bounds.size.height;
        }

        self.frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight);

        if (self.messagePosition == TSMessageNotificationPositionTop)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else
        {
            self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
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


- (CGFloat)updateHeightOfMessageView
{
    CGFloat currentHeight;
    CGFloat screenWidth = [self containingView].bounds.size.width;
    CGFloat verticalPadding = [self verticalPadding];
    CGFloat horizontalPadding = [self horizonalPadding];

    self.titleLabel.frame = CGRectMake(self.textSpaceLeft,
                                       verticalPadding,
                                       screenWidth - horizontalPadding - self.textSpaceLeft - self.textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];

    if ([self.subtitle length])
    {
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - horizontalPadding - self.textSpaceLeft - self.textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];

        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        // only the title was set
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }

    currentHeight += verticalPadding;

    if (self.iconImageView)
    {
        // Check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + verticalPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + verticalPadding;
        }
        else
        {
            // z-align
            self.iconImageView.center = CGPointMake([self.iconImageView center].x,
                                                    round(currentHeight / 2.0));
        }
        
        if (![self.subtitle length]){
            self.titleLabel.center = CGPointMake([self.titleLabel center].x,
                                                 round(currentHeight / 2.0));

        }

    }

    // z-align button
    self.button.center = CGPointMake([self.button center].x,
                                     round(currentHeight / 2.0));

    if (self.messagePosition == TSMessageNotificationPositionTop)
    {
        // Correct the border position
        CGRect borderFrame = self.borderView.frame;
        borderFrame.origin.y = currentHeight;
        self.borderView.frame = borderFrame;
    }

    currentHeight += self.borderView.frame.size.height;

    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);


    if (self.button)
    {
        self.button.frame = CGRectMake(self.frame.size.width - self.textSpaceRight,
                                       round((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }


    CGRect backgroundFrame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                        self.backgroundImageView.frame.origin.y,
                                        screenWidth,
                                        currentHeight);

    // increase frame of background view because of the spring animation
    if ([TSMessage iOS7StyleEnabled])
    {
        if (self.messagePosition == TSMessageNotificationPositionTop)
        {
            float topOffset = 0.f;

            UINavigationController *navigationController = self.viewController.navigationController;
            if (!navigationController && [self.viewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)self.viewController;
            }
            BOOL isNavBarIsHidden = !navigationController || [TSMessage isNavigationBarInNavigationControllerHidden:navigationController];
            BOOL isNavBarIsOpaque = !navigationController.navigationBar.isTranslucent && navigationController.navigationBar.alpha == 1;

            if (isNavBarIsHidden || isNavBarIsOpaque) {
                topOffset = -30.f;
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.f, 0.f, 0.f));
        }
        else if (self.messagePosition == TSMessageNotificationPositionBottom)
        {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.f, 0.f, -30.f, 0.f));
        }
    }

    self.backgroundImageView.frame = backgroundFrame;
    self.backgroundView.frame = backgroundFrame;

    return currentHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeightOfMessageView];
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
