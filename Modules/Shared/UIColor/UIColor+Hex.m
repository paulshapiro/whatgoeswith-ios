//
//  UIColor+Hex.m
//  Pitchfork
//
//  Created by Paul Shapiro on 8/5/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Public - Hex

+ (UIColor *)colorWithHex:(NSString *)hexString
{
	unsigned int colorValueR;
    unsigned int colorValueG;
    unsigned int colorValueB;
    unsigned int colorValueA;
    
	NSString *hexStringCleared = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (hexStringCleared.length < 3) {
        NSLog(@"Error: Can't produce a UIColor with %@. Returning red.", hexString);
        return [UIColor redColor];
    }
    
	if(hexStringCleared.length == 3) { // convert hex color's short form to long form
		// maybe there's a better way to convert from #fff to #ffffff
		hexStringCleared = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                            [hexStringCleared substringWithRange:NSMakeRange(0, 1)],
                            [hexStringCleared substringWithRange:NSMakeRange(0, 1)],
							[hexStringCleared substringWithRange:NSMakeRange(1, 1)],
                            [hexStringCleared substringWithRange:NSMakeRange(1, 1)],
							[hexStringCleared substringWithRange:NSMakeRange(2, 1)],
                            [hexStringCleared substringWithRange:NSMakeRange(2, 1)]];
	}
    
	if(hexStringCleared.length == 6) {
		hexStringCleared = [hexStringCleared stringByAppendingString:@"ff"];
	}
	
	NSString *red = [hexStringCleared substringWithRange:NSMakeRange(0, 2)];
	NSString *green = [hexStringCleared substringWithRange:NSMakeRange(2, 2)];
	NSString *blue = [hexStringCleared substringWithRange:NSMakeRange(4, 2)];
	NSString *alpha = [hexStringCleared substringWithRange:NSMakeRange(6, 2)];
	
	[[NSScanner scannerWithString:red] scanHexInt:&colorValueR];
	[[NSScanner scannerWithString:green] scanHexInt:&colorValueG];
	[[NSScanner scannerWithString:blue] scanHexInt:&colorValueB];
	[[NSScanner scannerWithString:alpha] scanHexInt:&colorValueA];
	
	return [UIColor colorWithRed:((colorValueR)&0xFF)/255.0
						   green:((colorValueG)&0xFF)/255.0
							blue:((colorValueB)&0xFF)/255.0
						   alpha:((colorValueA)&0xFF)/255.0];
}

+ (NSString *)hexFromColor:(UIColor *)color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }

    return [self hexColorStringFromCGColor:color.CGColor];
}

+ (NSString *)hexColorStringFromCGColor:(CGColorRef)colorRef
{
    if (CGColorSpaceGetModel(CGColorGetColorSpace(colorRef)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"%02X%02X%02X", (int)((CGColorGetComponents(colorRef))[0]*255.0), (int)((CGColorGetComponents(colorRef))[1]*255.0), (int)((CGColorGetComponents(colorRef))[2]*255.0)];
}

@end
