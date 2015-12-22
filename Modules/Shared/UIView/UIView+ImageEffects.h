//
//  UIView+ImageEffects.h
//  PitchforkWeekly
//
//  Created by Paul Shapiro on 10/14/13.
//  Copyright (c) 2013 Pitchfork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ImageEffects)

- (UIImage *)snapshot:(BOOL)afterScreenUpdates;

@end
