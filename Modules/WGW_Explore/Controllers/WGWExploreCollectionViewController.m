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
#import "WGWSearchController.h"
#import <TOWebViewController/TOWebViewController.h>


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
    UICollectionViewDelegate,
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) RFQuiltLayout *quiltLayout;

@property (nonatomic, strong, readwrite) WGWExploreCollectionView *collectionView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) BOOL shouldCellOverlaysBeVisible;

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
    self.shouldCellOverlaysBeVisible = YES; // at rest
    
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
//    collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern_background"]];
    collectionView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
    collectionView.scrollsToTop = YES;
    
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    {
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                                 action:@selector(collectionViewLongPressed:)];
        self.longPressGestureRecognizer = longPressGestureRecognizer;
        longPressGestureRecognizer.delegate = self;
        longPressGestureRecognizer.delaysTouchesBegan = NO;
        longPressGestureRecognizer.minimumPressDuration = 1;
        [collectionView addGestureRecognizer:longPressGestureRecognizer];
    }
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
    } else {
        DDLogInfo(@"Same result. Not reloading.");
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
#pragma mark - Runtime - Imperatives

- (void)_showContextualMenuForGoesWithAggregateItem:(WGWGoesWithAggregateItem *)item
{
    WGWRLMIngredient *ingredient = item.goesWithIngredient;
    NSString *ingredientName = ingredient.keyword;
//    NSString *capitalized_ingredientName = [ingredientName capitalizedString];
    NSString *urlQueryFormatted_ingredientName = [ingredientName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil//capitalized_ingredientName
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    {
        {
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Copy \"%@\"", nil), ingredientName]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         [[UIPasteboard generalPasteboard] setString:ingredientName];
                                     }];
            [controller addAction:action];
        }
        {
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Research \"%@\"", nil), ingredientName]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action)
            {
                NSString *urlString = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", urlQueryFormatted_ingredientName];
                TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
                {
                    webViewController.showUrlWhileLoading = NO;
                    webViewController.buttonTintColor = [UIColor WGWTintColor];
                    webViewController.loadingBarTintColor = [UIColor WGWTintColor];
                }
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
                [self presentViewController:navigationController animated:YES completion:nil];

            }];
            [controller addAction:action];
        }
// allrecipes and food.com both kind suck
//        {
//            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"View recipes with %@", nil), ingredientName]
//                                                             style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * _Nonnull action)
//            {
//                NSString *urlString = [NSString stringWithFormat:@"https://allrecipes.com/search/results/?sort=re&wt=%@", urlQueryFormatted_ingredientName];
//                TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
//                [self presentViewController:navigationController animated:YES completion:nil];
//            }];
//            [controller addAction:action];
//        }
        {
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
            {
            }];
            [controller addAction:action];
        }
    }
    [self.parentViewController presentViewController:controller animated:YES completion:^
    {
    }];
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
#pragma mark - Runtime - Imperatives - Cells

- (void)showCellOverlays_animated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.15 : 0;
    NSArray *visibleCells = self.collectionView.visibleCells;
    for (WGWExploreCollectionViewCell *cell in visibleCells) {
        [cell showOverlayAtFullOpacityOverDuration:duration];
    }
}

- (void)hideCellOverlays_animated:(BOOL)animated
{
    NSTimeInterval duration = (animated ? 0.15 : 0);
    for (WGWExploreCollectionViewCell *cell in self.collectionView.visibleCells) {
        [cell hideOverlayOverDuration:duration];
    }
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
    
    if (self.shouldCellOverlaysBeVisible) {
        [cell showOverlayAtFullOpacityOverDuration:0];
    } else {
        [cell hideOverlayOverDuration:0];
    }
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - RFQuiltLayoutDelegate

- (CGSize)blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.items.count) {
        DDLogWarn(@"Asking for index paths of non-existent cells!! %ld from %lu cells", (long)indexPath.row, (unsigned long)self.items.count);
    }
    switch (self.searchController.searchResultType) {
        case WGWSearchResultTypeNoSearch:
        { // it's showing 'random' choice
            return [WGWExploreCollectionViewCell largeCellBlockSize];

            break;
        }
            
        default:
        {
            if (indexPath.row == 0) {
                return [WGWExploreCollectionViewCell principalCellBlockSize];
            }
            break;
        }
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval duration = 0.1;
    WGWExploreCollectionViewCell *cell = (WGWExploreCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell showOverlayAtFullOpacityOverDuration:duration];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval duration = 0.1;
    WGWExploreCollectionViewCell *cell = (WGWExploreCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.shouldCellOverlaysBeVisible) {
        [cell showOverlayAtFullOpacityOverDuration:duration];
    } else {
        [cell hideOverlayOverDuration:duration];
    }
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

    self.shouldCellOverlaysBeVisible = NO;
    [self hideCellOverlays_animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) { // we won't be getting a -scrollViewDidEndDecelerating:
        [self _scrollViewDoneMoving];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _scrollViewDoneMoving];
}

- (void)_scrollViewDoneMoving
{
    self.shouldCellOverlaysBeVisible = YES;
    [self showCellOverlays_animated:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Gesture recognizers

- (void)collectionViewLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) { // tapping on empty space
//        DDLogWarn(@"couldn't find index path");
        return;
    }
    WGWGoesWithAggregateItem *item = (WGWGoesWithAggregateItem *)self.items[indexPath.row];
    [self _showContextualMenuForGoesWithAggregateItem:item];
}

@end
