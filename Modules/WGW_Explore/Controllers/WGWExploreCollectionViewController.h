//
//  WGWExploreCollectionViewController.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WGWSearchController;

@interface WGWExploreCollectionViewController : UIViewController

@property (nonatomic, copy) void(^scrollViewWillBeginDragging)(void); // set this
@property (nonatomic, copy) void(^didSelectItemAtIndex)(NSUInteger index);

- (void)setGoesWithAggregateItems:(NSArray *)items; // will reload and scroll to top

@property (nonatomic, weak) WGWSearchController *searchController;

@end
