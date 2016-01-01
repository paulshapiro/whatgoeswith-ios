//
//  WGWExploreSearchTextField.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreSearchTextField.h"

@implementation WGWExploreSearchTextField


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Overrides

- (CGRect)textRectForBounds:(CGRect)bounds
{ // placeholder position
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 10, 0, 0))];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{ // text position
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 10, 0, 0))];
}


@end
