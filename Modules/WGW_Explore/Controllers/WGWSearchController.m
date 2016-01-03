//
//  WGWSearchController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWSearchController.h"
#import "WGWGoesWithAggregateItem.h"
#import "WGWExploreCollectionViewCell.h"


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

@property (nonatomic, strong, readwrite) NSString *currentSearchQuery_CSVString;
@property (nonatomic, strong) NSArray *currentSearchQuery_keywords;

@property (nonatomic, readwrite) WGWSearchResultType searchResultType;
@property (nonatomic, strong, readwrite) NSArray *currentSearch_didntFindKeywords;
@property (nonatomic, strong, readwrite) NSDictionary *goesWithAggregateItems_byKeyword;
@property (nonatomic, strong, readwrite) NSArray *scoreOrdered_desc_goesWithAggregateItems;

@property (atomic, readwrite) BOOL isCurrentlySearching;

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

- (NSArray *)_new_firstNItemsFrom_scoreOrdered_desc_goesWithAggregateItems
{
    NSArray *allItems = [[self.goesWithAggregateItems_byKeyword allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        WGWGoesWithAggregateItem *item1 = (WGWGoesWithAggregateItem *)obj1;
        WGWGoesWithAggregateItem *item2 = (WGWGoesWithAggregateItem *)obj2;
        
        return [@(item2.totalScore) compare:@(item1.totalScore)];
    }];
    NSArray *sliceOf_allItems;
    {
        static NSUInteger const N = 150;
        if (allItems.count > N) {
            sliceOf_allItems = [allItems objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, N)]];
        } else {
            sliceOf_allItems = allItems;
        }
    }
    
    return sliceOf_allItems;
}

- (NSString *)new_searchQueryStringByAppendingIngredientAtIndex:(NSUInteger)index
{
    NSUInteger numberOf_scoreOrdered_desc_goesWithAggregateItems = _scoreOrdered_desc_goesWithAggregateItems.count;
    if (index >= numberOf_scoreOrdered_desc_goesWithAggregateItems) {
        NSCAssert(false, @"");
        
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
        self.isCurrentlySearching = NO;
        
        return;
    }
    {
        if (self.isCurrentlySearching) {
            DDLogWarn(@"Already currently searching when new request came in.");
        }
        self.isCurrentlySearching = YES;
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
            self.isCurrentlySearching = NO; // essential as this is an early bail
            
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
        [self loadRandomIngredients]; // this will yield, setting self.isCurrentlySearching to NO
        
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
        [self _markFinishedSearchingAnd_yieldThat_searchResultUpdated];
        
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
                WGWGoesWithAggregateItem *goesWithItem = goesWithAggregateItems_byKeyword[goesWithOtherIngredient.keyword];
                { // lazy
                    if (goesWithItem == nil) {
                        goesWithItem = [[WGWGoesWithAggregateItem alloc] init];
                        {
                            goesWithItem.goesWithIngredient = goesWithOtherIngredient;
                            goesWithItem.cached_goesWithIngredientKeyword = goesWithOtherIngredient.keyword;
                            goesWithItem.cached_hosted_ingredientThumbnailImageURLString = goesWithOtherIngredient.optimized_hosted_ingredientThumbnailImageURLString; // important to use the optimized one here
                            goesWithItem.totalScore = 0;
                            // we generate the block size below after obtaining the spread of items
                        }
                        goesWithAggregateItems_byKeyword[goesWithOtherIngredient.keyword] = goesWithItem;
                    } else { // already there
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

    self.scoreOrdered_desc_goesWithAggregateItems = [self _new_firstNItemsFrom_scoreOrdered_desc_goesWithAggregateItems];
    { // Now that we have the ordering, we must go through and compute the block sizes for the goesWithItems we generated above
        NSUInteger i = 0;
        NSUInteger numberOf_scoreOrdered_desc_goesWithAggregateItems = _scoreOrdered_desc_goesWithAggregateItems.count;
        if (numberOf_scoreOrdered_desc_goesWithAggregateItems > 0) {
            WGWGoesWithAggregateItem *firstItem = (WGWGoesWithAggregateItem *)[_scoreOrdered_desc_goesWithAggregateItems firstObject];
            WGWGoesWithAggregateItem *lastItem = (WGWGoesWithAggregateItem *)[_scoreOrdered_desc_goesWithAggregateItems lastObject];
            CGFloat topScore = firstItem.totalScore;
            CGFloat bottomScore = lastItem.totalScore;
            CGFloat scoreRange = topScore - bottomScore;
//            DDLogInfo(@"scoreRange %f", scoreRange);
            {
                for (WGWGoesWithAggregateItem *thisItem in _scoreOrdered_desc_goesWithAggregateItems) {
                    CGSize blockSize;
                    {
                        if (i == 0) {
                            blockSize = [WGWExploreCollectionViewCell principalCellBlockSize];
                        } else if (numberOf_scoreOrdered_desc_goesWithAggregateItems < 2) {
                            blockSize = [WGWExploreCollectionViewCell largeCellBlockSize];
                        } else {
                            NSAssert([firstItem isEqual:lastItem] == NO, @"");
                            
                            CGFloat thisItemScore = thisItem.totalScore;
                            CGFloat normalizedScore = thisItemScore / (bottomScore + scoreRange);
                            {
                                NSAssert(normalizedScore < 1.1, @"Normalized score over 1.1"); // i mean, really, it should always be extremely close to 1 if over it
                                normalizedScore = fminf(normalizedScore, 1.0); // so we'll chop it to 1.0
                            }
                            {
                                NSAssert(normalizedScore >= 0 && normalizedScore <= 1, @"Chopped normalized score not in legal range");
                            }
                            
                            if (normalizedScore == 1) { // it seems possible to get values like 1.0000000000000002
                                blockSize = [WGWExploreCollectionViewCell largeCellBlockSize];
                            } else if (normalizedScore == 0) {
                                blockSize = [WGWExploreCollectionViewCell smallCellBlockSize];
                            } else if (normalizedScore < 0.4) {
                                blockSize = [WGWExploreCollectionViewCell smallCellBlockSize];
                            } else if (normalizedScore < 0.7) {
                                blockSize = [WGWExploreCollectionViewCell mediumCellBlockSize];
                            } else {
                                blockSize = [WGWExploreCollectionViewCell largeCellBlockSize];
                            }
                        }
                    }
                    thisItem.cached_blockSize = blockSize;
                    {
                        i++;
                    }
                }
            }
        }
    }
    [self _markFinishedSearchingAnd_yieldThat_searchResultUpdated];
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
                goesWithItem.cached_goesWithIngredientKeyword = ingredient.keyword;
                goesWithItem.cached_hosted_ingredientThumbnailImageURLString = ingredient.optimized_hosted_ingredientThumbnailImageURLString; // important to use the optimized one here
                goesWithItem.totalScore = latestScore;
                goesWithItem.cached_blockSize = [WGWExploreCollectionViewCell largeCellBlockSize];
                
                latestScore -= scoreStep;
            }
            [items addObject:goesWithItem];
        }
    }
    
    self.scoreOrdered_desc_goesWithAggregateItems = items;
    [self _markFinishedSearchingAnd_yieldThat_searchResultUpdated];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Shake to reload with active search

- (void)regenerateExistingOrderingAndYield
{
    [self _refreshQueryResults];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Yield

- (void)_markFinishedSearchingAnd_yieldThat_searchResultUpdated
{
    self.isCurrentlySearching = NO;
    {
        WGWAnalytics_trackEvent(@"search result updated", @
        {
            @"search query csv string" : self.currentSearchQuery_CSVString ?: @"",
            @"num search terms" : self.currentSearchQuery_CSVString ? @([self.currentSearchQuery_CSVString componentsSeparatedByString:@","].count) : @0,
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
