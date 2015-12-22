//
//  WGWExploreCollectionView.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGWExploreCollectionView : UICollectionView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

- (void)cancelActiveTouches;

@end
