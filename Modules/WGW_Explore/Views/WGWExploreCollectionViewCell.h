//
//  WGWExploreCollectionViewCell.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WGWGoesWithAggregateItem;

@interface WGWExploreCollectionViewCell : UICollectionViewCell


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item andBlockSize:(CGSize)blockSize;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Cell

+ (NSString *)reuseIdentifier;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Block size

+ (CGFloat)blocksPerScreenWidth;

+ (CGSize)largeSquareBlockSize;
+ (CGSize)wideRectangleBlockSize;
+ (CGSize)tallRectangleBlockSize;
+ (CGSize)smallSquareBlockSize;
+ (BOOL)isBlockSize:(CGSize)blockSize1 sameAsBlockSize:(CGSize)blockSize2;

+ (CGRect)labelFrameScaffoldForBlockSize:(CGSize)blockSize; // returns a frame with origin.x and size.width set

@end
