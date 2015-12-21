//
//  WGWRootViewController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWRootViewController.h"
#import "WGWExploreViewController.h"



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWRootViewController ()

@property (nonatomic, strong) WGWExploreViewController *exploreViewController;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWRootViewController


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Entrypoints

- (instancetype)init
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
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _setup_views];
}

- (void)_setup_views
{
    self.exploreViewController = [[WGWExploreViewController alloc] init];
    [self.view addSubview:_exploreViewController.view];
    [self addChildViewController:_exploreViewController];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

- (void)teardown
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors

- (BOOL)prefersStatusBarHidden
{
    return NO;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation


@end
