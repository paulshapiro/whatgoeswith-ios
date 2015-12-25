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

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item;

- (void)showOverlayAtFullOpacityOverDuration:(NSTimeInterval)duration;
- (void)hideOverlayOverDuration:(NSTimeInterval)duration;
@property (nonatomic, readonly) BOOL isShowingOverlay;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Cell

+ (NSString *)reuseIdentifier;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Block size

+ (CGFloat)blocksPerScreenWidth;

+ (CGSize)principalCellBlockSize;
+ (CGSize)largeCellBlockSize;
+ (CGSize)mediumCellBlockSize;
+ (CGSize)smallCellBlockSize;

+ (BOOL)isBlockSize:(CGSize)blockSize1 sameAsBlockSize:(CGSize)blockSize2;

+ (CGRect)labelFrameScaffoldForBlockSize:(CGSize)blockSize; // returns a frame with origin.x and size.width set

@end
