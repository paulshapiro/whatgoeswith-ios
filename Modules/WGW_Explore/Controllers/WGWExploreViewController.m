//
//  WGWExploreViewController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreViewController.h"
#import "WGWExploreToolbarView.h"
#import "WGWSearchController.h"
#import "WGWGoesWithAggregateItem.h"
#import "WGWExploreCollectionViewController.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreViewController ()

@property (nonatomic, strong) WGWSearchController *searchController;

@property (nonatomic, strong) WGWExploreToolbarView *toolbarView;

@property (nonatomic, strong) WGWExploreCollectionViewController *exploreCollectionViewController;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWExploreViewController


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
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];

    [self _setup_runtime];
    [self _setup_views];
    
    [self startObserving];
}

- (void)_setup_runtime
{
    self.searchController = [[WGWSearchController alloc] init];
}

- (void)_setup_views
{
    {
        WGWExploreCollectionViewController *controller = [[WGWExploreCollectionViewController alloc] init];
        {
            controller.searchController = self.searchController;
            
            typeof(self) __weak weakSelf = self;
            controller.scrollViewWillBeginDragging = ^
            {
                [weakSelf.toolbarView externalControlWasEngaged];
            };
            controller.didSelectItemAtIndex = ^(NSUInteger index)
            {
                [weakSelf.toolbarView externalControlWasEngaged];

                NSString *newQueryString = [weakSelf.searchController new_searchQueryStringByAppendingIngredientAtIndex:index];
                [weakSelf.toolbarView setQueryString:newQueryString andYield:YES]; // cause the search to refresh
            };
        }
        self.exploreCollectionViewController = controller;
        [self.view addSubview:controller.view];
        [self addChildViewController:controller];
    }
    {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 65);
        WGWExploreToolbarView *view = [[WGWExploreToolbarView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.toolbarView = view;
        [self.view addSubview:view];
        
        typeof(self) __weak weakSelf = self;
        view.searchQueryTextChanged = ^(NSString *queryString)
        {
            [weakSelf _searchQueryTextChangedToString:queryString];
        };
    }
}

- (void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(WGWSearch_notification_resultUpdated)
                                                 name:WGWSearch_notification_resultUpdated
                                               object:self.searchController];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

- (void)teardown
{
    [self stopObserving];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.toolbarView viewControllerAppeared];
    [self.searchController loadRandomIngredients];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Searching

- (void)_searchQueryTextChangedToString:(NSString *)queryString
{
    [self.searchController setCurrentSearchQueryString:queryString];
}

- (void)WGWSearch_notification_resultUpdated
{
    NSMutableString *resultsString = [NSMutableString new];
    {
        {
            switch (self.searchController.searchResultType) {
                case WGWSearchResultTypeNoSearch:
                {
                    [resultsString appendFormat:@"Start typing to find ingredient pairings."];
                    break;
                }
                case WGWSearchResultTypeNoIngredientsFound:
                {
//                    DDLogComplete(@"No ingredients found");
//                    [resultsString appendFormat:@"No matches"];
                    break;
                }
                case WGWSearchResultTypeIngredientsAndGoesWithsFound:
                {
//                    DDLogComplete(@"Ingredients and goes withs found.");
                    break;
                }
                case WGWSearchResultTypeIngredientsFoundButNoGoesWiths:
                {
                    // todo: log this as an analytic
                    // also, log searches in general
                    
//                    [resultsString appendFormat:@"No pairings found"];

                    break;
                }
                    
                default:
                    assert(false);
                    break;
            }
        }
//        NSArray *currentSearch_didntFindKeywords = self.searchController.currentSearch_didntFindKeywords;
//        NSUInteger numberOf_currentSearch_didntFindKeywords = currentSearch_didntFindKeywords.count;
//        if (numberOf_currentSearch_didntFindKeywords == 1) {
//            [resultsString appendFormat:@"No results for %@.\n\n", currentSearch_didntFindKeywords[0]];
//        } else if (numberOf_currentSearch_didntFindKeywords > 1) {
//            [resultsString appendFormat:@"No results for %@.\n\n", [currentSearch_didntFindKeywords componentsJoinedByString:@", "]];
//        }
    }
    {
        NSArray *goesWithAggregateItems = self.searchController.scoreOrdered_desc_goesWithAggregateItems;
        {
            if (goesWithAggregateItems.count > 0) {
                [resultsString appendFormat:@"… goes with: "];
                NSUInteger i = 0;
                for (WGWGoesWithAggregateItem *goesWith in goesWithAggregateItems) {
                    NSString *keyword = goesWith.goesWithIngredient.keyword;
                    [resultsString appendFormat:@"%@%@", i == 0 ? @"" : @", ", keyword];
                    i++;
                }
            } else {
                [resultsString appendFormat:@"No pairings found"];
            }
        }
        [self.exploreCollectionViewController setGoesWithAggregateItems:goesWithAggregateItems ?: @[]];
    }
}


@end
