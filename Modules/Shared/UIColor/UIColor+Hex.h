//
//  UIColor+Extensions.h
//  Pitchfork
//
//  Created by Paul Shapiro on 8/5/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)hexString;
+ (NSString *)hexFromColor:(UIColor *)color;
+ (NSString *)hexColorStringFromCGColor:(CGColorRef)colorref;

@end
