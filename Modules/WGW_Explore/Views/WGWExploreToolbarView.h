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

@property (nonatomic, copy) void(^searchQueryTextChanged)(NSString *queryString);

@end
