//
//  WGWExploreToolbarView.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGWExploreToolbarView : UIView

- (id)init;

- (void)viewControllerAppeared;
- (void)externalControlWasEngaged;

- (void)setQueryString:(NSString *)queryString andYield:(BOOL)yield;

@property (nonatomic, copy) void(^searchQueryTextChanged)(NSString *queryString);

@end
