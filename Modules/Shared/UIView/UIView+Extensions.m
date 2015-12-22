//
//  UIView+Extensions.m
//  Pitchfork
//
//  Created by Paul Shapiro on 8/11/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//


////////////////////////////////////////////////////////////////////////////////

#import "UIView+Extensions.h"


////////////////////////////////////////////////////////////////////////////////

@implementation UIView (Extensions)


////////////////////////////////////////////////////////////////////////////////

- (void)removeAllSubviews
{
    if (!self.subviews || !self.subviews.count) {
        return;
    }
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
