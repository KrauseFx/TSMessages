//
//  UIColor+TSHexString.m
//  Pods
//
//  Created by Stephen Williams on 31/05/14.
//
//

#import "UIColor+TSHexString.h"

@implementation UIColor (TSHexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    scanner.charactersToBeSkipped = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    unsigned value;
    [scanner scanHexInt:&value];
    
    CGFloat r = ((value & 0xFF0000) >> 16) / 255.0f;
    CGFloat g = ((value & 0xFF00) >> 8) / 255.0f;
    CGFloat b = ((value & 0xFF)) / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end
