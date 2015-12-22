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
        [self _yieldThat_searchResultUpdated];
        
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
#pragma mark - Runtime - Imperatives - Yield

- (void)_yieldThat_searchResultUpdated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WGWSearch_notification_resultUpdated object:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation


@end