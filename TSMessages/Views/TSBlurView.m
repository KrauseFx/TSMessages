//
//  TSBlurView.m
//  Pods
//
//  Created by Felix Krause on 20.08.13.
//
//

#import "TSBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface TSBlurView()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;
@property (nonatomic, strong) UIView *colorView; // TODO: Temporary workaround

- (void)setup;

@end

@implementation TSBlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
    [self setBlurLayer:[[self toolbar] layer]];
    
    UIView *blurView = [UIView new];
    [blurView setUserInteractionEnabled:NO];
    [blurView.layer addSublayer:[self blurLayer]];
    [self insertSubview:blurView atIndex:0];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    // TODO: Temporary workaround
    _colorView = [[UIView alloc] initWithFrame:[self bounds]];
    self.colorView.backgroundColor = [UIColor clearColor];
    self.colorView.alpha = 0.7;
    [self addSubview:self.colorView];
}

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    [self.toolbar setBarTintColor:blurTintColor];
    self.colorView.backgroundColor = blurTintColor; // TODO: Temporary workaround
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.blurLayer setFrame:self.bounds];
    [self.colorView setFrame:self.bounds]; // TODO: Temporary workaround
}


@end
