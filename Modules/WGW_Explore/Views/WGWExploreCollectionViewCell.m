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
    frame.origin.y = 6;
    
    // we're using size to fit at the moment
//    frame.size.height = [self.feedItem gridTitleStringHeightForBlockSize:self.blockSize];
    
    return CGRectIntegral(frame);
}

- (CGRect)infoContainerViewFrame
{
    CGFloat h = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 6;
    
    return CGRectIntegral(CGRectMake(0, (self.frame.size.height - h)/2, self.frame.size.width, h));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Configuration

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item andBlockSize:(CGSize)blockSize
{
    self.item = item;
    self.blockSize = blockSize;
    
    [self borderSubviews];
   
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
    CGFloat oldWidth = self.titleLabel.frame.size.width;
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    {
        frame.size.width = oldWidth;
    }
    self.titleLabel.frame = frame;
    
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

+ (CGSize)largeSquareBlockSize
{
    if (UIDevice_isPad()) {
        return CGSizeMake(4, 4);
    } else {
        return CGSizeMake(6, 6);
    }
}

+ (CGSize)wideRectangleBlockSize
{
    if (UIDevice_isPad()) {
        return CGSizeMake(4, 2);
    } else {
        return CGSizeMake(6, 3);
    }
}

+ (CGSize)tallRectangleBlockSize
{
    return CGSizeMake(2, 4);
}

+ (CGSize)smallSquareBlockSize
{
    if (UIDevice_isPad()) {
        return CGSizeMake(2, 2);
    } else {
        return CGSizeMake(3, 3);
    }
}

+ (CGFloat)blocksPerScreenWidth
{
    return 6;
}

+ (CGRect)blockBoundsFromBlockSize:(CGSize)blockSize
{
    CGFloat blockUnitLength = [UIScreen mainScreen].bounds.size.width / [self blocksPerScreenWidth];
    
    return CGRectMake(0, 0, blockUnitLength * blockSize.width, blockUnitLength * blockSize.height);
}

+ (BOOL)isLargeSquareFromBlockSize:(CGSize)blockSize
{
    CGSize largeSquareBlockSize = [self largeSquareBlockSize];
    
    return [self isBlockSize:blockSize sameAsBlockSize:largeSquareBlockSize];
}

+ (BOOL)isBlockSize:(CGSize)blockSize1 sameAsBlockSize:(CGSize)blockSize2
{
    return CGSizeEqualToSize(blockSize1, blockSize2);
}

+ (CGFloat)internalPaddingSideFromBlockSize:(CGSize)blockSize
{
    if ([self isBlockSize:blockSize sameAsBlockSize:[self largeSquareBlockSize]]) {
        return UIDevice_isPad() ? 31 : 24;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self wideRectangleBlockSize]]) {
        return UIDevice_isPad() ? 67 : 42;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self tallRectangleBlockSize]]) {
        return UIDevice_isPad() ? 31 : 24;
    } else if ([self isBlockSize:blockSize sameAsBlockSize:[self smallSquareBlockSize]]) {
        return UIDevice_isPad() ? 31 : 24;
    }
    
    return 10;
}

+ (CGRect)labelFrameScaffoldForBlockSize:(CGSize)blockSize
{
    CGFloat padding = [self internalPaddingSideFromBlockSize:blockSize];
    CGFloat blockWidth = [self blockBoundsFromBlockSize:blockSize].size.width;
    CGFloat w = blockWidth - 2*padding;
    
    return CGRectMake(padding, 0, w, 0);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Factories - Fonts

+ (UIFont *)titleLabelFontForBlockSize:(CGSize)blockSize
{
    return [self isLargeSquareFromBlockSize:blockSize]
            ? [UIFont systemFontOfSize:(UIDevice_isPad() ? 45 : 26)]
            : [UIFont systemFontOfSize:(UIDevice_isPad() ? 13 : 12)];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Cell

+ (NSString *)reuseIdentifier
{
    return reuseIdentifier;
}

@end
