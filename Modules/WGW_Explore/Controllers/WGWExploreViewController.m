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
#import "WGWBannerView.h"


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

@property (nonatomic, strong) UIToolbar *bottomToolbar;

@property (nonatomic) BOOL hasAppeared;

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
    self.view.opaque = YES;
    
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
        view.exportButtonTapped = ^
        {
            [weakSelf _exportButtonTapped];
        };
    }
    {
        UIToolbar *view = [[UIToolbar alloc] init];
        {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        {
            NSMutableArray *items = [NSMutableArray new];
            { // space
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                [items addObject:item];
            }
            { // feedback
                UIImage *templateImage = [[UIImage imageNamed:@"Chat_25"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:templateImage
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(feedbackButtonPressed)];
                [items addObject:item];
            }
            {
                
            }
            [view setItems:items animated:NO];
        }
        self.bottomToolbar = view;
        [self.view addSubview:view];
        {
            NSDictionary *views = NSDictionaryOfVariableBindings(view);
            NSArray *w = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:0 metrics:nil views:views];
            [self.view addConstraints:w];
            
            NSString *verticalConstraintVFLString = [NSString stringWithFormat:@"V:|-(>=1)-[view(==%d)]-(0)-|", (int)44];
            NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalConstraintVFLString options:0 metrics:nil views:views];
            [self.view addConstraints:vConstraints];

        }
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
#pragma mark - Runtime - Delegation - View

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.toolbarView viewControllerAppeared];
    if (self.hasAppeared == NO) {
        self.hasAppeared = YES;
        [self.searchController loadRandomIngredients];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Searching

- (void)_searchQueryTextChangedToString:(NSString *)queryString
{
    [self.searchController setCurrentSearchQueryString:queryString];
}

- (void)WGWSearch_notification_resultUpdated
{
    NSTimeInterval showAfterDelay = 0;
    NSTimeInterval hideAfterDuration = 5; // default
    
    NSMutableString *resultsString = [NSMutableString new];
    {
        {
            switch (self.searchController.searchResultType) {
                case WGWSearchResultTypeNoSearch:
                {
                    {
                        static NSString *const WGWSearch_v1_hasShownOnboardingMessageToTapSuggestedMatches = @"WGWSearch_v1_hasShownOnboardingMessageToTapSuggestedMatches";
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:WGWSearch_v1_hasShownOnboardingMessageToTapSuggestedMatches] == YES) { // nothing to do
//                            DDLogInfo(@"already showed it.");
                        } else {
                            // append it
                            
                            showAfterDelay = 1.5;
                            hideAfterDuration = 10.0; // give plenty of time to read
                            
                            [resultsString appendFormat:NSLocalizedString(@"Start typing ingredients and I'll find you something\u00A0special.", nil)];
                            [resultsString appendFormat:NSLocalizedString(@"\n\n", nil)];
                            [resultsString appendFormat:NSLocalizedString(@"Tap suggested pairings to expand your\u00A0recipe.", nil)];
                            
                            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                                    forKey:WGWSearch_v1_hasShownOnboardingMessageToTapSuggestedMatches];
                        }
                    }
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
                    NSAssert(false, @"");
                    break;
            }
        }
        NSArray *currentSearch_didntFindKeywords = self.searchController.currentSearch_didntFindKeywords;
        NSUInteger numberOf_currentSearch_didntFindKeywords = currentSearch_didntFindKeywords.count;
        if (numberOf_currentSearch_didntFindKeywords >= 1) {
            {
                if (resultsString.length > 0) {
                    [resultsString appendFormat:@"\n\n"];
                }
            }
            [resultsString appendFormat:NSLocalizedString(@"No matches for \"%@\".", nil),
             [[currentSearch_didntFindKeywords componentsJoinedByString:@", "] lowercaseString]];
        } else if (self.searchController.searchResultType == WGWSearchResultTypeIngredientsFoundButNoGoesWiths) {
            {
                if (resultsString.length > 0) {
                    [resultsString appendFormat:@"\n\n"];
                }
            }
            [resultsString appendFormat:NSLocalizedString(@"I've heard of \"%@\", but I don't know any pairings for it\u00A0yet.", nil),
             [self.searchController.currentSearchQuery_CSVString lowercaseString]
             ];
        }
        
    }
    {
        NSArray *goesWithAggregateItems = self.searchController.scoreOrdered_desc_goesWithAggregateItems;
        [self.exploreCollectionViewController setGoesWithAggregateItems:goesWithAggregateItems ?: @[]];
    }
    {
        if (resultsString.length > 0) {
            [WGWBannerView showAndDismissAfterDelay_message:resultsString
                                                     inView:self.view
                                                  atYOffset:self.toolbarView.frame.size.height
                                             showAfterDelay:showAfterDelay
                                       andHideAfterDuration:hideAfterDuration];
        } else {
            [WGWBannerView dismissImmediately];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        BOOL wasRandomSearch = NO;
        if (self.searchController.searchResultType == WGWSearchResultTypeNoSearch) {
            wasRandomSearch = YES;
            [self.toolbarView externalControlWasEngaged];
            [self.searchController loadRandomIngredients];
        } else {
            [self.searchController regenerateExistingOrderingAndYield];
        }
        {
            WGWAnalytics_trackEvent(@"device shaken", @
            {
                @"was random search" : @(wasRandomSearch)
            });
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Exporting

- (void)_exportButtonTapped
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    {
        [sharingItems addObject:self.searchController.currentSearchQuery_CSVString];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems
                                                                                     applicationActivities:nil];
    activityController.completionWithItemsHandler = ^(NSString * __nullable activityType,
                                                      BOOL completed,
                                                      NSArray * __nullable returnedItems,
                                                      NSError * __nullable activityError)
    {
        WGWAnalytics_trackEvent(@"export result", @
        {
            @"search csv" : self.searchController.currentSearchQuery_CSVString ?: @"nil",
            @"activity type" : activityType ?: @"nil",
            @"activity err" : activityError ?: @"nil",
            @"did export" : @(completed)
        });
        
        DDLogInfo(@"type %@ completed %d returned %@ error %@", activityType, completed, returnedItems, activityError);
        if (completed == YES) {
            if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard] == NO) {
                return; // do we want to bug them while they have something on their clipboard?
            }
        }
    };
    {
        if ([activityController respondsToSelector:@selector(popoverPresentationController)]) { // iOS8/ipad
            UIView *sourceView = self.toolbarView.exportButton;
            activityController.popoverPresentationController.sourceView = sourceView;
            activityController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            activityController.popoverPresentationController.sourceRect = CGRectMake(sourceView.frame.size.width/2,
                                                                                     sourceView.frame.size.height,
                                                                                     0, 0);
        }
    }
    [self presentViewController:activityController animated:YES completion:nil];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Bottom toolbar buttons

- (void)feedbackButtonPressed
{
    NSString *title = NSLocalizedString(@"Suggestion Box", nil);
    NSString *message = NSLocalizedString(@"We always enjoy to hearing your ingredient suggestions and app feature\u00A0requests.\n\nLeave your contact info in case we feature your\u00A0idea!", nil);
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    {
        [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
        {
            textField.placeholder = NSLocalizedString(@"What's on your mind?", nil);
        }];
    }
    {
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
        {
            NSString *text = [controller.textFields[0] text];
            WGWAnalytics_trackEvent(@"canceled suggestion box", @
            {
                @"suggestion text" : text.length != 0 ? text : @"--",
                @"current search" : _searchController.currentSearchQuery_CSVString.length != 0 ?
                                    _searchController.currentSearchQuery_CSVString :
                                    @""
            });
        }]];
    }
    {
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            NSString *text = [controller.textFields[0] text];
            WGWAnalytics_trackEvent(@"sent suggestion box", @
            {
                @"suggestion text" : text.length != 0 ? text : @"--",
                @"current search" : _searchController.currentSearchQuery_CSVString.length != 0 ?
                                    _searchController.currentSearchQuery_CSVString :
                                    @""
            });
        }]];
    }
    [self presentViewController:controller animated:YES completion:^
    {
        
    }];
}

@end
