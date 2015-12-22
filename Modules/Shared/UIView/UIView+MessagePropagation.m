//
//  UIView+MessagePropagation.m
//  Pitchfork
//
//  Created by Paul Shapiro on 9/15/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import "UIView+MessagePropagation.h"


////////////////////////////////////////////////////////////////////////////////

@implementation UIView (MessagePropagation)

- (void)propagateSelectorToSubviews:(SEL)selector withObject:(id)object
{
    for (UIView *subview in self.subviews) {
        if ([subview respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [subview performSelector:selector withObject:object];
#pragma clang diagnostic pop
        }
        
        [subview propagateSelectorToSubviews:selector withObject:object];
    }
}

@end
