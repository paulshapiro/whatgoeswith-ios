//
//  UIView+Constraints.m
//  PitchforkWeekly
//
//  Created by Paul Shapiro on 10/22/13.
//  Copyright (c) 2013 Pitchfork. All rights reserved.
//

#import "UIView+Constraints.h"

@implementation UIView (Constraints)

- (void)addConstraintsToFillSuperview
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *containingView = [self superview];
    [containingView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [containingView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [containingView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [containingView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
}

@end
