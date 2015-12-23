//
//  WGWSearchController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWSearchController.h"
#import "WGWGoesWithAggregateItem.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants

NSString *const WGWSearch_notification_resultUpdated = @"WGWSearch_notification_resultUpdated";


////////////////////////////////////////////////////////////////////////////////
#pragma mark - C

NSString *NSStringFromWGWSearchResultType(WGWSearchResultType searchResultType)
{
    switch (searchResultType) {
        case WGWSearchResultTypeIngredientsAndGoesWithsFound:
            return @"ingredients + goes withs found";
            
        case WGWSearchResultTypeIngredientsFoundButNoGoesWiths:
            return @"ingredients but no goes withs found";
            
        case WGWSearchResultTypeNoIngredientsFound:
            return @"no ingredients found";
            
        case WGWSearchResultTypeNoSearch:
            return @"no search";
            
        default:
            return @"unrecognized";
            break;
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWSearchController ()

@property (nonatomic, strong) NSString *currentSearchQuery_CSVString;
@property (nonatomic, strong) NSArray *currentSearchQuery_keywords;

@property (nonatomic, readwrite) WGWSearchResultType searchResultType;
@property (nonatomic, strong, readwrite) NSArray *currentSearch_didntFindKeywords;
@property (nonatomic, strong, readwrite) NSDictionary *goesWithAggregateItems_byKeyword;
@property (nonatomic, strong, readwrite) NSArray *scoreOrdered_desc_goesWithAggregateItems;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWSearchController


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Entrypoints

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [self teardown];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Setup

- (void)setup
{
}

- (void)startObserving
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

- (void)teardown
{
    [self stopObserving];
}

- (void)stopObserving
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors

- (NSArray *)_new_scoreOrdered_desc_goesWithAggregateItems
{
    return [[self.goesWithAggregateItems_byKeyword allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        WGWGoesWithAggregateItem *item1 = (WGWGoesWithAggregateItem *)obj1;
        WGWGoesWithAggregateItem *item2 = (WGWGoesWithAggregateItem *)obj2;
        
        return [@(item2.totalScore) compare:@(item1.totalScore)];
    }];
}

- (NSString *)new_searchQueryStringByAppendingIngredientAtIndex:(NSUInteger)index
{
    NSUInteger numberOf_scoreOrdered_desc_goesWithAggregateItems = _scoreOrdered_desc_goesWithAggregateItems.count;
    if (index >= numberOf_scoreOrdered_desc_goesWithAggregateItems) {
        assert(false);
        
        return @"";
    }
    WGWGoesWithAggregateItem *item = _scoreOrdered_desc_goesWithAggregateItems[index];
    NSString *keyword = item.goesWithIngredient.keyword;
    NSString *trimmed_currentSearchQueryString = [self.currentSearchQuery_CSVString stringByTrimmingWrappingWhitespace];
    NSString *newQueryString;
    {
        if (trimmed_currentSearchQueryString.length > 0) {
            newQueryString = [trimmed_currentSearchQueryString stringByAppendingFormat:@", %@", keyword];
        } else {
            newQueryString = keyword;
        }
    }
    
    return newQueryString;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)setCurrentSearchQueryString:(NSString *)csvString
{
    NSString *newQueryCSVString = [csvString stringByTrimmingWrappingWhitespace];
    if (self.currentSearchQuery_CSVString && [newQueryCSVString isEqualToString:self.currentSearchQuery_CSVString]) {
        return;
    }
    self.currentSearchQuery_CSVString = newQueryCSVString;
    
    NSMutableArray *keywords = [NSMutableArray new];
    {
        NSArray *stringSplitByComma = [csvString componentsSeparatedByString:@","];
        for (NSString *token in stringSplitByComma) {
            NSString *finalized_token = [[token stringByTrimmingWrappingWhitespace] lowercaseString];
            if (finalized_token.length > 0) {
                [keywords addObject:finalized_token];
            }
        }
    }
    if (keywords.count > 0 && _currentSearchQuery_keywords.count > 0) {
        if ([keywords isEqualToArray:_currentSearchQuery_keywords]) {
            return; // nothing to change
        }
    }
    self.currentSearchQuery_keywords = keywords;
    [self _refreshQueryResults];
}

- (void)_refreshQueryResults
{
    {
        self.goesWithAggregateItems_byKeyword = nil;
        self.scoreOrdered_desc_goesWithAggregateItems = nil;
        self.currentSearch_didntFindKeywords = nil;
    }
    
    if (self.currentSearchQuery_CSVString.length == 0) {
        self.searchResultType = WGWSearchResultTypeNoSearch;
        [self loadRandomIngredients];
        
        return;
    }
    RLMRealm *realm = WGWRealm_readOnly_ingredientsSearchRealm();
    NSMutableArray *keywordsNotFound = [_currentSearchQuery_keywords mutableCopy]; // to finalize
    {
        self.currentSearch_didntFindKeywords = keywordsNotFound;
    }
    RLMResults *ingredientsForKeywords = WGWRLM_lookup_ingredientsWithKeywords__inRealm(_currentSearchQuery_keywords, realm);
//    DDLogInfo(@"'%@': ingredientsForKeywords %@", self.currentSearchQuery_CSVString, ingredientsForKeywords);
    if (ingredientsForKeywords.count == 0) {
        self.searchResultType = WGWSearchResultTypeNoIngredientsFound;
        [self _yieldThat_searchResultUpdated];
        
        return;
    }
    NSMutableDictionary *goesWithAggregateItems_byKeyword = [NSMutableDictionary new];
    
    for (WGWRLMIngredient *ingredient in ingredientsForKeywords) {
        NSString *keyword = ingredient.keyword;
        {
            [keywordsNotFound removeObject:keyword];
        }
        RLMArray <WGWRLMGoesWith> *goesWiths = ingredient.goesWiths;
        for (WGWRLMGoesWith *goesWith in goesWiths) {
            WGWRLMIngredient *goesWithOtherIngredient;
            {
                if ([goesWith.ingredient.keyword isEqualToString:keyword]) {
                    goesWithOtherIngredient = goesWith.withIngredient;
                } else {
                    goesWithOtherIngredient = goesWith.ingredient;
                }
            }
            if ([ingredientsForKeywords indexOfObject:goesWithOtherIngredient] == NSNotFound) {
                WGWGoesWithAggregateItem *goesWithItem = goesWithAggregateItems_byKeyword[keyword];
                { // lazy
                    if (goesWithItem == nil) {
                        goesWithItem = [[WGWGoesWithAggregateItem alloc] init];
                        {
                            goesWithItem.goesWithIngredient = goesWithOtherIngredient;
                            goesWithItem.totalScore = 0;
                        }
                        goesWithAggregateItems_byKeyword[goesWithOtherIngredient.keyword] = goesWithItem;
                    }
                }
                goesWithItem.totalScore += goesWith.matchScore;
            } else { // it's one of the search tokens
//                DDLogInfo(@"%@ is already in the list of %@", goesWithOtherIngredient.keyword, self.currentSearchQuery_keywords);
            }
        }
    }
    self.currentSearch_didntFindKeywords = keywordsNotFound;

    self.searchResultType = goesWithAggregateItems_byKeyword.count > 0 ? WGWSearchResultTypeIngredientsAndGoesWithsFound : WGWSearchResultTypeIngredientsFoundButNoGoesWiths;
    self.goesWithAggregateItems_byKeyword = goesWithAggregateItems_byKeyword;

    self.scoreOrdered_desc_goesWithAggregateItems = [self _new_scoreOrdered_desc_goesWithAggregateItems];
    [self _yieldThat_searchResultUpdated];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Random/'no search' mode

- (void)loadRandomIngredients
{
    RLMRealm *realm = WGWRealm_readOnly_ingredientsSearchRealm();
    int n = 50;
    NSArray *randomIngredients = WGWRLM_lookup_nRandomIngredients__inRealm(n, realm);
    
    NSMutableArray *items = [NSMutableArray new];
    {
        CGFloat scoreStep = 1.0/(float)n;
        CGFloat latestScore = 1;
        for (WGWRLMIngredient *ingredient in randomIngredients) {
            WGWGoesWithAggregateItem *goesWithItem = [[WGWGoesWithAggregateItem alloc] init];
            {
                goesWithItem.goesWithIngredient = ingredient;
                goesWithItem.totalScore = latestScore;
                
                latestScore -= scoreStep;
            }
            [items addObject:goesWithItem];
        }
    }
    
    self.scoreOrdered_desc_goesWithAggregateItems = items;
    [self _yieldThat_searchResultUpdated];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Shake to reload with active search

- (void)regenerateExistingOrderingAndYield
{
    [self _refreshQueryResults];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Yield

- (void)_yieldThat_searchResultUpdated
{
    {
        WGWAnalytics_trackEvent(@"search result updated", @
        {
            @"search query csv string" : self.currentSearchQuery_CSVString ?: @"",
            @"search result type" : NSStringFromWGWSearchResultType(self.searchResultType),
            @"didnt find keywords" : self.currentSearch_didntFindKeywords.count > 0 ? self.currentSearch_didntFindKeywords : @[], // aww yeahhhh
            @"found n items" : @(self.scoreOrdered_desc_goesWithAggregateItems.count)
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WGWSearch_notification_resultUpdated object:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation


@end
