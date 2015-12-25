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
    self.layer.masksToBounds = YES; // clip off anything exceeding the frame bounds
    
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
    return self.item.cached_goesWithIngredientKeyword;
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
    
    return CGRectMake(0, (self.frame.size.height - h)/2, self.frame.size.width, h);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Configuration

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item andBlockSize:(CGSize)blockSize
{
    self.item = item;
    self.blockSize = blockSize;
    
    self.overlayView.alpha = 0.3; // start off invisible because we're scrolling if new cells are being requested
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
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.hyphenationFactor = 1.0f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self titleLabelText]
                                                                                         attributes:@
    {
        NSParagraphStyleAttributeName : paragraphStyle
    }];
    
    self.titleLabel.attributedText = attributedString;
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
    
    self.imageView.frame = self.bounds;
    self.overlayView.frame = self.bounds;
    
//    DDLogInfo(@"layout ... self %@ img %@ overlay %@",
//              NSStringFromCGRect(self.frame),
//              NSStringFromCGRect(self.imageView.frame),
//              NSStringFromCGRect(self.overlayView.frame));
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
        if (self.overlayView.alpha > 0.3) { // already think overlay is showing but its alpha was not 1
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
        if (self.overlayView.alpha == 0.3) {
            return; // already think overlay is hidden but its alpha was 0
        }
    }
    self.isShowingOverlay = NO;
    void (^configurations)(void) = ^
    {
        self.overlayView.alpha = 0.3;
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:configurations];
    } else {
        configurations();
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class - Accessors - Block size

+ (BOOL)isWidth_divisibleByNumber:(float)number
{
    return fmodf([UIScreen mainScreen].bounds.size.width, number) == 0;
}

+ (CGFloat)blocksPerScreenWidth
{
    if ([self isWidth_divisibleByNumber:2]) {
        if (UIDevice_isPad()) {
            if ([self isWidth_divisibleByNumber:12]) { // 768
                return 12;
            } else if ([self isWidth_divisibleByNumber:16]) { // ipad   pro at 1024
                return 16;
            }
        } else if ([self isWidth_divisibleByNumber:18]) {
            return 18;
        } else {
            assert([self isWidth_divisibleByNumber:8]);
            return 8;
        }
    } else {
        if ([self isWidth_divisibleByNumber:9]) {
            return 9;
        } else if ([self isWidth_divisibleByNumber:25]) {
            return 25;
        }
    }
    assert(false);
    
    return 1;
}

+ (CGSize)principalCellBlockSize
{
    if ([self isWidth_divisibleByNumber:2]) {
        if (UIDevice_isPad()) {
            return CGSizeMake(8, 2);
        } else if ([self isWidth_divisibleByNumber:18]) {
            return CGSizeMake(18, 5);
        } else {
            return CGSizeMake(8, 3);
        }
    } else { // ipad always even - 1024x768
        if ([self isWidth_divisibleByNumber:9]) {
            return CGSizeMake(9, 3);
        } else if ([self isWidth_divisibleByNumber:15]) {
            return CGSizeMake(25, 10);
        }
    }
    return CGSizeMake(1, 1);
}

+ (CGSize)largeCellBlockSize
{
    if ([self isWidth_divisibleByNumber:2]) {
        if (UIDevice_isPad()) {
            return CGSizeMake(4, 2);
        } else if ([self isWidth_divisibleByNumber:18]) {
            return CGSizeMake(18, 4);
        } else {
            return CGSizeMake(8, 2);
        }
    } else { // ipad always even - 1024x768
        if ([self isWidth_divisibleByNumber:9]) {
            return CGSizeMake(6, 3);
        } else if ([self isWidth_divisibleByNumber:15]) {
            return CGSizeMake(25, 6);
        }
    }
    return CGSizeMake(1, 1);
}

+ (CGSize)mediumCellBlockSize
{
    if ([self isWidth_divisibleByNumber:2]) {
        if (UIDevice_isPad()) {
            return CGSizeMake(2, 2);
        } else if ([self isWidth_divisibleByNumber:18]) {
            return CGSizeMake(6, 4);
        } else {
            return CGSizeMake(4, 2);
        }

    } else { // ipad always even - 1024x768
        if ([self isWidth_divisibleByNumber:9]) {
            return CGSizeMake(3, 3);
        } else if ([self isWidth_divisibleByNumber:15]) {
            return CGSizeMake(25, 4);
        }
    }
    return CGSizeMake(1, 1);
}

+ (CGSize)smallCellBlockSize
{
    if ([self isWidth_divisibleByNumber:2]) {
        if (UIDevice_isPad()) {
            return CGSizeMake(2, 1);
        } else if ([self isWidth_divisibleByNumber:18]) {
            return CGSizeMake(6, 2);
        } else {
            return CGSizeMake(4, 1);
        }
    } else { // ipad always even - 1024x768
        if ([self isWidth_divisibleByNumber:9]) {
            return CGSizeMake(3, 1);
        } else if ([self isWidth_divisibleByNumber:15]) {
            return CGSizeMake(5, 4);
        }
    }
    return CGSizeMake(1, 1);
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
    if (UIDevice_isPad()) {
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
    } else {
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
        if (UIDevice_isPad()) {
            return [UIFont boldSystemFontOfSize:34];
        } else {
            if ([self isWidth_divisibleByNumber:15]) {
                return [UIFont boldSystemFontOfSize:26];
            } else {
                return [UIFont boldSystemFontOfSize:26];
            }
        }
    } else if ([self isLargeSquareFromBlockSize:blockSize]) {
        if (UIDevice_isPad()) {
            return [UIFont boldSystemFontOfSize:26];
        } else {
            if ([self isWidth_divisibleByNumber:15]) {
                return [UIFont boldSystemFontOfSize:21];
            } else {
                return [UIFont boldSystemFontOfSize:18];
            }
        }
    } else if ([self isMediumSquareFromBlockSize:blockSize]) {
        if (UIDevice_isPad()) {
            return [UIFont boldSystemFontOfSize:18];
        } else {
            if ([self isWidth_divisibleByNumber:15]) {
                return [UIFont boldSystemFontOfSize:15];
            } else {
                return [UIFont boldSystemFontOfSize:15];
            }
        }
    } else if ([self isSmallSquareFromBlockSize:blockSize]) {
        if (UIDevice_isPad()) {
            return [UIFont boldSystemFontOfSize:13];
        } else {
            return [UIFont boldSystemFontOfSize:13];
        }
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
