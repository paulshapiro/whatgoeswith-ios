//
//  UIView+ImageEffects.m
//  PitchforkWeekly
//
//  Created by Paul Shapiro on 10/14/13.
//  Copyright (c) 2013 Pitchfork. All rights reserved.
//

#import "UIView+ImageEffects.h"

@implementation UIView (ImageEffects)

- (UIImage *)snapshot:(BOOL)afterScreenUpdates
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterScreenUpdates];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
