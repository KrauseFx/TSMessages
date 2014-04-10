//
//  TSMessageCustomView.m
//  Example
//
//  Created by Fedya Skitsko on 4/4/14.
//  Copyright (c) 2014 Toursprung. All rights reserved.
//

#import "TSMessageCustomView.h"

@interface TSMessageCustomView()

@property (nonatomic) UIButton *closeButton;

@end

@implementation TSMessageCustomView

#pragma mark - Setters / Getters

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"closeIcon"] forState:UIControlStateNormal];
        _closeButton.frame = CGRectMake(0, 0, 20, 20);
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark - Initialization

- (id)initWithItem:(TSMessageItem *)item
{
    if (self = [super initWithItem:item])
    {
        [self setup];
    }
    return self;
}

+ (CGFloat)heightWithItem:(TSMessageCustomItem *)item {
    CGFloat calculatedHeight = [super heightWithItem:item];
    
    return calculatedHeight;
}

#pragma mark - Lifecycle

- (void)setup {
    [super setup];

    [self.iconImageView removeFromSuperview];
    
    self.textSpaceLeft = 17.5f;
    [self addSubview:self.closeButton];
    self.alpha = 0.9f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    _closeButton.frame = CGRectMake(CGRectGetWidth(self.frame) - self.textSpaceLeft - CGRectGetWidth(_closeButton.frame), roundf((CGRectGetHeight(self.frame) - CGRectGetHeight(_closeButton.frame))/2), _closeButton.frame.size.width, _closeButton.frame.size.height);
}

#pragma mark - Actions

- (void)closeButtonPressed {
    NSLog(@"closeButtonPressed");
    
    if (self.item.disclosureSelectionHandler) {
        self.item.disclosureSelectionHandler(self.item);
    }
}

@end
