//
//  WGWSearchController.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGWRealm.h"
#import "WGWRLMGoesWith.h"
#import "WGWRLMIngredient.h"

typedef NS_ENUM(NSUInteger, WGWSearchResultType)
{
    WGWSearchResultTypeNoSearch             = 0,
    WGWSearchResultTypeNoIngredientsFound,
    WGWSearchResultTypeIngredientsFoundButNoGoesWiths,
    WGWSearchResultTypeIngredientsAndGoesWithsFound
};

extern NSString *const WGWSearch_notification_resultUpdated;

@interface WGWSearchController : NSObject

- (void)setCurrentSearchQueryString:(NSString *)csvString;

@property (nonatomic, readonly) WGWSearchResultType searchResultType;

@property (nonatomic, strong, readonly) NSArray *currentSearch_didntFindKeywords;
@property (nonatomic, strong, readonly) NSDictionary *goesWithAggregateItems_byKeyword;
@property (nonatomic, strong, readonly) NSArray *scoreOrdered_desc_goesWithAggregateItems;

@end
