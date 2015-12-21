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
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{ // text position
    return CGRectInset(bounds, 10, 0);
}

@end
