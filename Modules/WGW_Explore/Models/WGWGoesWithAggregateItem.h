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
@property (nonatomic, copy) NSString *cached_goesWithIngredientKeyword;
@property (nonatomic, copy) NSString *cached_hosted_ingredientThumbnailImageURLString;

@property (nonatomic) CGFloat totalScore;
@property (nonatomic) CGSize cached_blockSize;

- (BOOL)isEqualToAggregateItem:(WGWGoesWithAggregateItem *)item;

@end
