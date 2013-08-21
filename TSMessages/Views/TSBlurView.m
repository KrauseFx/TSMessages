//
//  TSBlurView.m
//  Pods
//
//  Created by Felix Krause on 20.08.13.
//
//

#import "TSBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface TSBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation TSBlurView


- (UIToolbar *)toolbar
{
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbar.userInteractionEnabled = NO;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_toolbar];
    }

    return _toolbar;
}

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    if ([self.toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.toolbar performSelector:@selector(setBarTintColor:) withObject:blurTintColor];
    }
}

- (UIColor *)blurTintColor
{
    if ([self.toolbar respondsToSelector:@selector(barTintColor)]) {
        return [self.toolbar performSelector:@selector(barTintColor:)];
    }
    return nil;
}

@end
