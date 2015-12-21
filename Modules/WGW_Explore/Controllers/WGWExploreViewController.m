//
//  WGWExploreViewController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreViewController.h"
#import "WGWExploreToolbarView.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreViewController ()

@property (nonatomic, strong) WGWExploreToolbarView *toolbarView;

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

    [self _setup_views];
    
    [self startObserving];
}

- (void)_setup_views
{
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



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.toolbarView viewControllerAppeared];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Searching

- (void)_searchQueryTextChangedToString:(NSString *)queryString
{
    DDLogInfo(@"update query to '%@'", queryString);
}

@end
