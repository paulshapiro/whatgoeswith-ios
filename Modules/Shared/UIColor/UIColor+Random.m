//
//  UIColor+Random.m
//  Pitchfork
//
//  Created by Paul Shapiro on 9/15/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColour
{
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;

	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
