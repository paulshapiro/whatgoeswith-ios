//
//  UIView+Debug.h
//  Pitchfork
//
//  Created by Paul Shapiro on 9/15/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Debug)

- (void)giveBorderOfColour:(UIColor *)colour andWidth:(CGFloat)borderWidth;
- (void)giveBorder; // calls the above with random color

- (void)borderSubviews; // random borders all subviews through UIView+MessagePropagation

@end
