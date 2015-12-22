//
//  WGWGoesWithAggregateItem.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWGoesWithAggregateItem.h"

@implementation WGWGoesWithAggregateItem


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    return [self isEqualToAggregateItem:(WGWGoesWithAggregateItem *)object];
}

- (BOOL)isEqualToAggregateItem:(WGWGoesWithAggregateItem *)item
{
    return [self.goesWithIngredient.keyword isEqual:item.goesWithIngredient.keyword];
}

@end
