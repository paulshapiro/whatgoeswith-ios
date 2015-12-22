//
//  WGWExploreCollectionViewController.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGWExploreCollectionViewController : UIViewController

@property (nonatomic, copy) void(^scrollViewWillBeginDragging)(void); // set this

- (void)setGoesWithAggregateItems:(NSArray *)items; // will reload and scroll to top

@end
