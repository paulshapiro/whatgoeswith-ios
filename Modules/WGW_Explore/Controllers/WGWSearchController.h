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
@class WGWSearchController;


////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, WGWSearchResultType)
{
    WGWSearchResultTypeNoSearch             = 0,
    WGWSearchResultTypeNoIngredientsFound,
    WGWSearchResultTypeIngredientsFoundButNoGoesWiths,
    WGWSearchResultTypeIngredientsAndGoesWithsFound
};


////////////////////////////////////////////////////////////////////////////////

extern NSUInteger const WGWSearch_maximumAllowedSearchTerms; // something like 30

extern void WGWSearch_alertAndTrackThatAtMaxRecipeIngredients(UIView *inView, CGFloat yOffset, WGWSearchController *searchController);


////////////////////////////////////////////////////////////////////////////////

extern NSString *const WGWSearch_notification_resultUpdated;


////////////////////////////////////////////////////////////////////////////////

@interface WGWSearchController : NSObject

- (void)setCurrentSearchQueryString:(NSString *)csvString;
@property (atomic, readonly) BOOL isCurrentlySearching;

@property (nonatomic, readonly) WGWSearchResultType searchResultType;

@property (nonatomic, strong, readonly) NSString *currentSearchQuery_CSVString;
- (NSUInteger)new_numberOfTermsInCSVStringBySplitting;
- (NSUInteger)new_hasMaxNumTermsInCSVString;

@property (nonatomic, strong, readonly) NSArray *currentSearch_didntFindKeywords;
@property (nonatomic, strong, readonly) NSDictionary *goesWithAggregateItems_byKeyword;
@property (nonatomic, strong, readonly) NSArray *scoreOrdered_desc_goesWithAggregateItems;

- (NSString *)new_searchQueryStringByAppendingIngredientAtIndex:(NSUInteger)index;
- (void)loadRandomIngredients;
- (void)regenerateExistingOrderingAndYield;

@end
