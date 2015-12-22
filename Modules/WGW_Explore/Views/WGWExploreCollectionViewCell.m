//
//  WGWExploreCollectionViewCell.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreCollectionViewCell.h"
#import "WGWGoesWithAggregateItem.h"


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

// UI
//@property (nonatomic, strong) P4KNetworkedImageView *imageView;
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
    
//    [self setupImageView];
    [self setupOverlayView];
    [self setupInfoContainerView];
    [self setupTitleLabel];
}

//- (void)setupImageView
//{
//    P4KNetworkedImageView *imageView = [[P4KNetworkedImageView alloc] init];
//    imageView.clipsToBounds = YES;
//    imageView.delegate = self;
//    self.imageView = imageView;
//    [self.contentView addSubview:imageView];
//}

- (void)setupOverlayView
{
    UIView *view = [[UIView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
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
//    self.imageView.delegate = nil;
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

//- (NSURL *)new_imageRequestURL
//{
//    return [self.feedItem imageURLThatFitsBlockSize:self.blockSize];
//}


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
//    [self.imageView loadImageAtURL:[self imageRequestURL]]; // should auto-handle nil imageRequestURLs via delegation pattern
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
    
//    self.imageView.frame = self.contentView.bounds;
    
    self.overlayView.frame = self.contentView.bounds;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Block size

+ (CGFloat)blocksPerScreenWidth
{
    return 16;
}

+ (CGSize)principalCellBlockSize
{
    return CGSizeMake(16, 4);
}

+ (CGSize)largeCellBlockSize
{
    return CGSizeMake(10, 4);
}

+ (CGSize)mediumCellBlockSize
{
    return CGSizeMake(6, 2);
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
        return 24;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self largeCellBlockSize]]) {
        return 20;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self mediumCellBlockSize]]) {
        return 12;
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
        return [UIFont boldSystemFontOfSize:(UIDevice_isPad() ? 12 : 11)];
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
