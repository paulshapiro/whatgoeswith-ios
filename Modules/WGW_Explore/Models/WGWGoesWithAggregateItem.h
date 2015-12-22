//
//  WGWGoesWithAggregateItem.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGWRLMIngredient.h"

@interface WGWGoesWithAggregateItem : NSObject

@property (nonatomic) WGWRLMIngredient *goesWithIngredient;
@property (nonatomic) CGFloat totalScore;

- (BOOL)isEqualToAggregateItem:(WGWGoesWithAggregateItem *)item;

@end
