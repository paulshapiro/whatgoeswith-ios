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
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) UIView *overlayView;
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
    
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:1]; // for the inset border around
    self.opaque = YES;
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
    imageView.opaque = YES;
    imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupOverlayView
{
    UIView *view = [[UIView alloc] init];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
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
#pragma mark - Runtime - Accessors - Background colors

static CGFloat const WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_hidden = 0.11;
static CGFloat const WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_visible = 0.42;

- (UIColor *)_new_overlayView_backgroundColor_hidden
{
    return [UIColor colorWithWhite:0 alpha:WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_hidden];
}

- (UIColor *)_new_overlayView_backgroundColor_visible
{
    return [UIColor colorWithWhite:0 alpha:WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_visible];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Label

- (NSTextAlignment)labelTextAlignment
{
    return [self isLargeSquare] ? NSTextAlignmentCenter : NSTextAlignmentCenter;
}

- (UIFont *)titleLabelFont
{
    return [[self class] titleLabelFontForBlockSize:self.blockSize];
}

- (UIColor *)titleLabelTextColor
{
    return [UIColor whiteColor];
}

- (NSString *)titleLabelText
{
    return _item.cached_goesWithIngredientKeyword;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Layout

+ (CGFloat)cellInset
{
    return 1.0f/[UIScreen mainScreen].scale;
}

- (CGRect)titleLabelFrame
{
    CGRect frame = [[self class] labelFrameScaffoldForBlockSize:self.blockSize];
    
    return CGRectIntegral(frame);
}

- (CGRect)infoContainerViewFrame
{
    CGFloat h = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    
    return CGRectMake([[self class] cellInset], (self.frame.size.height - h)/2 - [[self class] cellInset], self.frame.size.width - 2 * [[self class] cellInset], h);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Configuration

- (void)configureWithItem:(WGWGoesWithAggregateItem *)item
{
    @autoreleasepool
    {
        {
            self.item = item;
            self.blockSize = item.cached_blockSize;
            NSAssert(CGSizeEqualToSize(_blockSize, CGSizeZero) == NO, @"");
        }
        {
            _overlayView.backgroundColor = [self _new_overlayView_backgroundColor_hidden];
            // ^ start off invisible because we're scrolling if new cells are being requested
            _isShowingOverlay = NO;
        }
        {
            [self.imageView.layer removeAllAnimations];
            self.imageView.layer.transform = CATransform3DMakeScale(1, 1, 1);

            [self.overlayView.layer removeAllAnimations];
            self.overlayView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }
//        {
//            [self borderSubviews];
//
//            self.backgroundColor = [UIColor randomColour];
//
//            self.layer.borderWidth = 1;
//            self.layer.borderColor = [UIColor greenColor].CGColor;
//        }
        {
            [self configureImageView];
            [self configureLabels];
        }
        {
            [self layoutSubviews]; // necessary for borders accessing superview frame
            [self layoutInfoContainerView];
        }
    }
}

- (void)configureImageView
{
    NSString *urlString = _item.cached_hosted_ingredientThumbnailImageURLString;
    if (urlString.length != 0) {
        _imageView.image = nil;
        [_imageView setImageWithURL:[NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
    } else {
        _imageView.image = nil;
    }
}

- (void)configureLabels
{
    _titleLabel.numberOfLines = 0;//[[self class] titleLabelMaxNumberOfLinesForBlockSize:self.blockSize]; // because it may change based on the blockSize, and set this before changing the text
    
    // because it changes based on the titleText, and set font before changing the text
    UIFont *font = [self titleLabelFont];
    UIFont *existingFont = _titleLabel.font;
    if (!existingFont
        || existingFont.pointSize != font.pointSize
        || [existingFont.familyName isEqualToString:font.familyName] == NO) {
        _titleLabel.font = font;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.hyphenationFactor = 1.0f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self titleLabelText]
                                                                                         attributes:@
    {
        NSParagraphStyleAttributeName : paragraphStyle
    }];
    
    _titleLabel.attributedText = attributedString;
}

- (void)layoutInfoContainerView
{
    _titleLabel.textAlignment = [self labelTextAlignment];
    _titleLabel.frame = [self titleLabelFrame];
    
    _infoContainerView.frame = [self infoContainerViewFrame]; // must be called last as it requires all labels to be laid out
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSAssert(self.parentCollectionView != nil, @"self.parentCollectionView was nil");
    
    BOOL isLeftmostCell = self.frame.origin.x == 0;
    BOOL isRightmostCell = self.frame.origin.x + self.frame.size.width == self.parentCollectionView.frame.size.width;
    
    CGRect newFrame = CGRectMake(
                                 isLeftmostCell == NO ? [[self class] cellInset] : 0,
                                 
                                 [[self class] cellInset],
                                 
                                 self.bounds.size.width
                                    - (isLeftmostCell == NO ? [[self class] cellInset] : 0)
                                    - (isRightmostCell == NO ? [[self class] cellInset] : 0),
                                 
                                 self.bounds.size.height - 2*[[self class] cellInset]);
    
//    DDLogInfo(@"frame %@ newframe %@ isLeftmostCell %d isRightmostCell %d", NSStringFromCGRect(self.frame), NSStringFromCGRect(newFrame), isLeftmostCell, isRightmostCell);
    
    _imageView.frame = newFrame;
    _overlayView.frame = newFrame;
    
//    DDLogInfo(@"layout ... self %@ img %@ overlay %@",
//              NSStringFromCGRect(self.frame),
//              NSStringFromCGRect(self.imageView.frame),
//              NSStringFromCGRect(self.overlayView.frame));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Ovrlay

- (void)showOverlayAtFullOpacityOverDuration:(NSTimeInterval)duration
{
    [self _showOverlayOverDuration:duration atOpacity:1];
}

- (void)_showOverlayOverDuration:(NSTimeInterval)duration atOpacity:(CGFloat)opacity
{
    {
        CGFloat currentBackgroundAlpha = CGColorGetAlpha(self.overlayView.backgroundColor.CGColor);
        {
            if (self.isShowingOverlay == YES) {
                if (currentBackgroundAlpha == WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_visible) {
                    return; // think overlay is already hidden and its alpha was also 1
                }
            }
        }
    }
    self.isShowingOverlay = YES;
    typeof(self) __weak weakSelf = self;
    void (^configurations)(void) = ^
    {
        weakSelf.overlayView.backgroundColor = [weakSelf _new_overlayView_backgroundColor_visible];
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:configurations];
    } else {
        configurations();
    }
}

- (void)hideOverlayOverDuration:(NSTimeInterval)duration
{
    {
        CGFloat currentBackgroundAlpha = CGColorGetAlpha(self.overlayView.backgroundColor.CGColor);
        {
            if (self.isShowingOverlay == NO) {
                if (currentBackgroundAlpha == WGWExploreCollectionViewCell_overlay_backgroundColorAlpha_hidden) {
                    return; // think overlay is already hidden and its alpha was also 0
                }
            }
        }
    }
    self.isShowingOverlay = NO;
    typeof(self) __weak weakSelf = self;
    void (^configurations)(void) = ^
    {
        weakSelf.overlayView.backgroundColor = [weakSelf _new_overlayView_backgroundColor_hidden];
    };
    void (^completion)(BOOL finished) = ^(BOOL finished)
    {

    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:configurations completion:completion];
    } else {
        configurations();
        completion(YES);
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
            NSAssert([self isWidth_divisibleByNumber:8], @"E");
            return 8;
        }
    } else {
        if ([self isWidth_divisibleByNumber:9]) {
            return 9;
        } else if ([self isWidth_divisibleByNumber:25]) {
            return 25;
        }
    }
    NSCAssert(false, @"E");
    
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
    CGFloat w = blockBounds.size.width - 2*padding - 2*[self cellInset];
    CGFloat h = blockBounds.size.height - 2*[self cellInset];
    
    return CGRectMake(padding + [self cellInset],
                      [self cellInset],
                      w,
                      h);
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
