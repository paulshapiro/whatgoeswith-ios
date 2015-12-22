//
//  UIView+Debug.m
//  Pitchfork
//
//  Created by Paul Shapiro on 9/15/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Debug.h"

@implementation UIView (Debug)

- (void)giveBorder
{    
    [self giveBorderOfColour:[UIColor randomColour] andWidth:1];
}

- (void)giveBorderOfColour:(UIColor *)colour andWidth:(CGFloat)borderWidth
{
    self.layer.borderColor = colour.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)borderSubviews
{
    [self propagateSelectorToSubviews:@selector(giveBorder) withObject:nil];
}


@end
