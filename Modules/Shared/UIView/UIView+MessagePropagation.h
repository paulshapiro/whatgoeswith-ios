//
//  UIView+MessagePropagation.h
//  Pitchfork
//
//  Created by Paul Shapiro on 9/15/12.
//  Copyright (c) 2012 Pitchfork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MessagePropagation)

- (void)propagateSelectorToSubviews:(SEL)selector withObject:(id)object;

@end
