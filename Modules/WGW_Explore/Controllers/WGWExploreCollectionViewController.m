//
//  WGWExploreCollectionViewController.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreCollectionViewController.h"
#import "WGWExploreCollectionView.h"
#import "WGWExploreCollectionViewCell.h"
#import "RFQuiltLayout.h"
#import "WGWGoesWithAggregateItem.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreCollectionViewController ()
<
    RFQuiltLayoutDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) RFQuiltLayout *quiltLayout;

@property (nonatomic, strong, readwrite) WGWExploreCollectionView *collectionView;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWExploreCollectionViewController


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup

- (void)setup
{
    [self setupModel];
    // no -setupViews here as that's called in -viewDidLoad
}

- (void)setupModel
{
}

- (void)setupViews
{
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    WGWExploreCollectionView *collectionView = [[WGWExploreCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[self newQuiltLayout]];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.allowsMultipleSelection = NO;
    [collectionView registerClass:[WGWExploreCollectionViewCell class] forCellWithReuseIdentifier:[WGWExploreCollectionViewCell reuseIdentifier]];

    collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    // this might be nice
//    collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern_vinyl_background"]];
    collectionView.contentInset = UIEdgeInsetsMake(66, 0, 0, 0);
    collectionView.scrollsToTop = YES;
    
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (RFQuiltLayout *)newQuiltLayout
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat blockSide = screenWidth/[WGWExploreCollectionViewCell blocksPerScreenWidth];
    RFQuiltLayout *quiltLayout = [[RFQuiltLayout alloc] init];
    quiltLayout.delegate = self;
    quiltLayout.direction = UICollectionViewScrollDirectionVertical;
    quiltLayout.blockPixels = CGSizeMake(blockSide, blockSide);
    
    return quiltLayout;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Reload

- (void)setGoesWithAggregateItems:(NSArray *)items
{
    if (!self.items || ![self.items isEqual:items]) {
        self.items = items;
        [self reloadCollectionView];
        
        [self scrollToTop];
    }
}

- (void)reloadCollectionView
{
    [self deselectAndDehighlightAllCells];
    [self.collectionView cancelActiveTouches];
    [self.collectionView reloadData];
}

- (void)deselectAndDehighlightAllCells
{
    for (NSInteger i = 0; i < [self.items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        WGWExploreCollectionViewCell *cell = (WGWExploreCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        // Deselect
        if ([cell isSelected]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
        }
        
        // Dehighlight
        if ([cell isHighlighted]) {
            [cell setHighlighted:NO];
            [self collectionView:self.collectionView didUnhighlightItemAtIndexPath:indexPath];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Interface

- (void)scrollToTop
{
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,
                                                      -self.collectionView.contentInset.top)
                                 animated:YES];  // scroll to top, accounting to content offsets per iOS 7
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Cell - Selection

- (void)displaySelectionIndicatorForCellOfItemAtIndexPath:(NSIndexPath *)indexPath fn:(void(^)(void))fn
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Modes

- (void)disableInteractivity
{
    self.collectionView.scrollEnabled = NO;
}

- (void)enableInteractivity
{
    self.collectionView.scrollEnabled = YES;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView != self.collectionView) {
        DDLogWarn(@"For some reason, collectionView passed into %@ is not the same as self.collectionView. WTF!", NSStringFromSelector(_cmd));
    }
    WGWExploreCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[WGWExploreCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    WGWGoesWithAggregateItem *item = [self.items objectAtIndex:indexPath.row];
    CGSize blockSize = [self blockSizeForItemAtIndexPath:indexPath];
    [cell configureWithItem:item andBlockSize:blockSize];
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - RFQuiltLayoutDelegate

- (CGSize)blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.items.count) {
        DDLogWarn(@"Asking for index paths of non-existent cells!! %ld from %lu cells", (long)indexPath.row, (unsigned long)self.items.count);
    }
    if (indexPath.row == 0) {
        return [WGWExploreCollectionViewCell principalCellBlockSize];
    }
    if (self.items.count < 2) {
        return [WGWExploreCollectionViewCell largeCellBlockSize];
    }
    WGWGoesWithAggregateItem *firstItem = (WGWGoesWithAggregateItem *)[self.items firstObject];
    WGWGoesWithAggregateItem *lastItem = (WGWGoesWithAggregateItem *)[self.items lastObject];
    assert([firstItem isEqual:lastItem] == NO);
    // ^ this can be cached at '-setGoesWithAggregateItems' for optimization
    CGFloat topScore = firstItem.totalScore;
    CGFloat bottomScore = lastItem.totalScore;
    CGFloat scoreRange = topScore - bottomScore;
    
    WGWGoesWithAggregateItem *thisItem = (WGWGoesWithAggregateItem *)self.items[indexPath.row];
    CGFloat thisItemScore = thisItem.totalScore;
    CGFloat normalizedScore = thisItemScore / (bottomScore + scoreRange);
    assert(normalizedScore >= 0 && normalizedScore <= 1);
    
    if (normalizedScore == 1) {
        return [WGWExploreCollectionViewCell largeCellBlockSize];
    } else if (normalizedScore == 0) {
        return [WGWExploreCollectionViewCell smallCellBlockSize];
    } else if (normalizedScore < 0.4) {
        return [WGWExploreCollectionViewCell smallCellBlockSize];
    } else if (normalizedScore < 0.7) {
        return [WGWExploreCollectionViewCell mediumCellBlockSize];
    } else {
        return [WGWExploreCollectionViewCell largeCellBlockSize];
    }
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - Collection View

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self displaySelectionIndicatorForCellOfItemAtIndexPath:indexPath fn:^{}];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES]; // this deselection is important - it tells the collectionView that its indexPathsForSelectedItems have been updated
    
    typeof(self) __weak weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
//    {
        weakSelf.didSelectItemAtIndex(indexPath.row);
//    });
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.collectionView.scrollEnabled) { // we definitely don't want to notify observers of programmatic scroll events, such as what happens in -disableInteractivity
        return;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollViewWillBeginDragging();
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

@end
