//
//  WGWExploreCollectionViewCell.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreCollectionViewCell.h"
#import "WGWGoesWithAggregateItem.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants

NSString *const reuseIdentifier = @"WGWExploreCollectionViewCell_reuseIdentifier";


////////////////////////////////////////////////////////////////////////////////
#pragma mark - C


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreCollectionViewCell ()


// model
@property (nonatomic, strong, readwrite) WGWGoesWithAggregateItem *item;
@property (nonatomic) CGSize blockSize;

// state
@property (nonatomic, readwrite) BOOL isShowingOverlay;


// UI
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *infoContainerView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWExploreCollectionViewCell


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [self teardown];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView cancelImageDownloadTask];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup

- (void)setup
{
    [self setupViews];
    [self startObserving];
}

- (void)setupViews
{
//    self.backgroundColor = [UIColor orangeColor];
    
//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self setupImageView];
    [self setupOverlayView];
    [self setupInfoContainerView];
    [self setupTitleLabel];
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupOverlayView
{
    UIView *view = [[UIView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    view.alpha = 1;
    view.userInteractionEnabled = NO;
    self.overlayView = view;
    [self.contentView addSubview:view];
}

- (void)setupInfoContainerView
{
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = NO;
    self.infoContainerView = view;
    [self.overlayView addSubview:view];
}

- (void)setupTitleLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [self titleLabelTextColor];
    label.font = [self titleLabelFont];
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.1;

    // this looks slick but unfortunately is way too slow on compositing
    // and rasterization may get too complicated for now
    
//    label.layer.shadowRadius = 2 * 1.0/[UIScreen mainScreen].scale;
//    label.layer.shadowOffset = CGSizeMake(0, 0);
//    label.layer.shadowOpacity = 0.7;
    
    
    self.titleLabel = label;
    [self.infoContainerView addSubview:label];
}

- (void)startObserving
{
    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Teardown

- (void)teardown
{
    [self stopObserving];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Transforms

- (BOOL)isLargeSquare
{
    return [[self class] isLargeSquareFromBlockSize:self.blockSize];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Factories

- (NSTextAlignment)labelTextAlignment
{
    return [self isLargeSquare] ? NSTextAlignmentCenter : NSTextAlignmentCenter;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Factories - Fonts

- (UIFont *)titleLabelFont
{
    return [[self class] titleLabelFontForBlockSize:self.blockSize];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Factories - Text Colors

- (UIColor *)titleLabelTextColor
{
    return [UIColor whiteColor];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Factories - Label Strings

- (NSString *)titleLabelText
{
    return self.item.goesWithIngredient.keyword;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Layout

- (CGRect)titleLabelFrame
{
    CGRect frame = [[self class] labelFrameScaffoldForBlockSize:self.blockSize];
    
    return CGRectIntegral(frame);
}

- (CGRect)infoContainerViewFrame
{
    CGFloat h = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    
    return CGRectIntegral(CGRectMake(0, (self.frame.size.height - h)/2, self.frame.size.width, h));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Configuration

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item andBlockSize:(CGSize)blockSize
{
    self.item = item;
    self.blockSize = blockSize;
    
    self.overlayView.alpha = 0; // start off invisible because we're scrolling if new cells are being requested
    self.isShowingOverlay = NO;

//    [self borderSubviews];
  
    self.backgroundColor = [UIColor randomColour];
    
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor greenColor].CGColor;
    
    [self configureImageView];
    [self configureLabels];
    
    [self layoutInfoContainerView];
}

- (void)configureImageView
{
    NSString *urlString = self.item.goesWithIngredient.hosted_ingredientThumbnailImageURLString;
    if (urlString.length != 0) {
        self.imageView.image = nil;
        [self.imageView setImageWithURL:[NSURL URLWithString:urlString]];
    } else {
        self.imageView.image = nil;
    }
}

- (void)configureLabels
{
    self.titleLabel.numberOfLines = 0;//[[self class] titleLabelMaxNumberOfLinesForBlockSize:self.blockSize]; // because it may change based on the blockSize, and set this before changing the text
    self.titleLabel.font = [self titleLabelFont]; // because it changes based on the titleText, and set this before changing the text
    self.titleLabel.text = [self titleLabelText];
}

- (void)layoutInfoContainerView
{
    self.titleLabel.textAlignment = [self labelTextAlignment];
    self.titleLabel.frame = [self titleLabelFrame];
    
    self.infoContainerView.frame = [self infoContainerViewFrame]; // must be called last as it requires all labels to be laid out
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
    self.overlayView.frame = self.contentView.bounds;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Ovrlay

- (void)showOverlayAtFullOpacityOverDuration:(NSTimeInterval)duration
{
    [self _showOverlayOverDuration:duration atOpacity:1 andAlsoDisplayMetaData:YES];
}

- (void)_showOverlayOverDuration:(NSTimeInterval)duration atOpacity:(CGFloat)opacity andAlsoDisplayMetaData:(BOOL)alsoDisplayMetaData
{
    if (self.isShowingOverlay) {
        if (self.overlayView.alpha > 0) { // already think overlay is showing but its alpha was not 1
            if (!alsoDisplayMetaData || self.infoContainerView.alpha == 1) { // we don't need to show the meta data
                return;
            }
        }
    }
    self.isShowingOverlay = YES;
    if (!alsoDisplayMetaData) {
        self.infoContainerView.alpha = 0.0;
    }
    CGFloat infoContainerViewAlpha = self.infoContainerView.alpha;
    CGFloat overlayViewAlpha = self.overlayView.alpha;
    void (^configurations)(void) = ^
    {
        CGFloat infoContainerViewToAlpha = alsoDisplayMetaData ? 1 : 0;
        if (infoContainerViewAlpha != infoContainerViewToAlpha) {
            self.infoContainerView.alpha = alsoDisplayMetaData ? 1.0 : 0.0;
        }
        if (overlayViewAlpha != opacity) {
            self.overlayView.alpha = opacity;
        }
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:configurations];
    } else {
        configurations();
    }
}

- (void)hideOverlayOverDuration:(NSTimeInterval)duration
{
    if (!self.isShowingOverlay) {
        if (self.overlayView.alpha == 0) {
            return; // already think overlay is hidden but its alpha was 0
        }
    }
    self.isShowingOverlay = NO;
    void (^configurations)(void) = ^
    {
        self.overlayView.alpha = 0.0;
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:configurations];
    } else {
        configurations();
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Block size

+ (CGFloat)blocksPerScreenWidth
{
    return 16;
}

+ (CGSize)principalCellBlockSize
{
    return CGSizeMake(8, 8);
}

+ (CGSize)largeCellBlockSize
{
    return CGSizeMake(8, 4);
}

+ (CGSize)mediumCellBlockSize
{
    return CGSizeMake(4, 4);
}

+ (CGSize)smallCellBlockSize
{
    return CGSizeMake(4, 2);
}

+ (CGRect)blockBoundsFromBlockSize:(CGSize)blockSize
{
    CGFloat blockUnitLength = [UIScreen mainScreen].bounds.size.width / [self blocksPerScreenWidth];
    
    return CGRectMake(0, 0, blockUnitLength * blockSize.width, blockUnitLength * blockSize.height);
}

+ (BOOL)isPrincipalSquareFromBlockSize:(CGSize)blockSize
{
    CGSize size = [self principalCellBlockSize];
    
    return [self isBlockSize:blockSize sameAsBlockSize:size];
}

+ (BOOL)isLargeSquareFromBlockSize:(CGSize)blockSize
{
    CGSize size = [self largeCellBlockSize];
    
    return [self isBlockSize:blockSize sameAsBlockSize:size];
}

+ (BOOL)isMediumSquareFromBlockSize:(CGSize)blockSize
{
    CGSize size = [self mediumCellBlockSize];
    
    return [self isBlockSize:blockSize sameAsBlockSize:size];
}

+ (BOOL)isSmallSquareFromBlockSize:(CGSize)blockSize
{
    CGSize size = [self smallCellBlockSize];
    
    return [self isBlockSize:blockSize sameAsBlockSize:size];
}

+ (BOOL)isBlockSize:(CGSize)blockSize1 sameAsBlockSize:(CGSize)blockSize2
{
    return CGSizeEqualToSize(blockSize1, blockSize2);
}

+ (CGFloat)internalPaddingSideFromBlockSize:(CGSize)blockSize
{
    if ([self isBlockSize:blockSize sameAsBlockSize:[self principalCellBlockSize]]) {
        return 16;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self largeCellBlockSize]]) {
        return 10;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self mediumCellBlockSize]]) {
        return 6;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self smallCellBlockSize]]) {
        return 4;
    }
    
    return 10;
}

+ (CGRect)labelFrameScaffoldForBlockSize:(CGSize)blockSize
{
    CGRect blockBounds = [self blockBoundsFromBlockSize:blockSize];
    CGFloat padding = [self internalPaddingSideFromBlockSize:blockSize];
    CGFloat w = blockBounds.size.width - 2*padding;
    CGFloat h = blockBounds.size.height;
    
    return CGRectMake(padding, 0, w, h);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Factories - Fonts

+ (UIFont *)titleLabelFontForBlockSize:(CGSize)blockSize
{
    if ([self isPrincipalSquareFromBlockSize:blockSize]) {
        return [UIFont systemFontOfSize:(UIDevice_isPad() ? 45 : 28)];
    } else if ([self isLargeSquareFromBlockSize:blockSize]) {
        return [UIFont boldSystemFontOfSize:(UIDevice_isPad() ? 45 : 18)];
    } else if ([self isMediumSquareFromBlockSize:blockSize]) {
        return [UIFont boldSystemFontOfSize:(UIDevice_isPad() ? 13 : 13)];
    } else if ([self isSmallSquareFromBlockSize:blockSize]) {
        return [UIFont boldSystemFontOfSize:(UIDevice_isPad() ? 12 : 11 )];
    }
    
    return [UIFont systemFontOfSize:12];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Cell

+ (NSString *)reuseIdentifier
{
    return reuseIdentifier;
}

@end
