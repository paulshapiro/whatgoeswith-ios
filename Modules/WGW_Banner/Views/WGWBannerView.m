//
//  WGWBannerView.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/23/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWBannerView.h"



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C

WGWBannerView *_WGWBannerView_shared_bannerView(void)
{
    static WGWBannerView *view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[WGWBannerView alloc] init];
        {
            view.alpha = 0;
        }
    });
    
    return view;
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWBannerView ()

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *messageLabel;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWBannerView


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public entrypoints

+ (void)showAndDismissAfterDelay_message:(NSString *)messageString inView:(UIView *)view atYOffset:(CGFloat)yOffset
{
    WGWBannerView *bannerView = _WGWBannerView_shared_bannerView();
    if ([view.subviews containsObject:bannerView] == NO) {
        if (bannerView.superview) {
            [bannerView removeFromSuperview];
        }
        [view addSubview:bannerView];
    }
    {
        bannerView.frame = CGRectMake(0, yOffset, view.frame.size.width, 0); // height will be handled in -displayAndLayoutWithText:
        
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:bannerView selector:@selector(autodismissAfterDelay) object:nil];
        }
        [bannerView.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.2 animations:^
        {
            bannerView.alpha = 1;
        }];
        [bannerView displayAndLayoutWithText:messageString];
    }
    { // just in case we remove the above call...
        [NSObject cancelPreviousPerformRequestsWithTarget:bannerView selector:@selector(autodismissAfterDelay) object:nil];
    }
    [bannerView performSelector:@selector(autodismissAfterDelay) withObject:nil afterDelay:3];
}

- (void)autodismissAfterDelay
{
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^
    {
        weakSelf.alpha = 0;
    }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    {
        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
        self.visualEffectView = view;
        {
            
        }
        [self addSubview:view];
    }
    {
        UIImageView *view = [[UIImageView alloc] init];
        view.image = [UIImage imageNamed:@"chef_talking"];
        self.imageView = view;
        {
            
        }
        [self addSubview:view];
    }
    {
        UILabel *view = [[UILabel alloc] init];
        view.font = [UIFont systemFontOfSize:13];
        view.textColor = [UIColor darkTextColor];
        view.textAlignment = NSTextAlignmentLeft;
        view.numberOfLines = 0;
        view.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel = view;
        [self addSubview:view];
    }
}

- (void)dealloc
{
    [self teardown];
}

- (void)teardown
{
    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors

- (CGFloat)imageViewSide
{
    return 30;
}

- (CGFloat)internalPadding
{
    return 10;
}

- (CGRect)_new_templateFrameFor_messageLabel
{
    CGFloat x = [self internalPadding] + self.imageViewSide + [self internalPadding]/2; // /2 is just a visual ratio for proximity to the icon img view padding
    CGFloat w = self.bounds.size.width - x - [self internalPadding];
    
    return CGRectMake(x,
                      [self internalPadding],
                      w,
                      self.bounds.size.height - [self internalPadding] * 2);
}

- (CGRect)_new_frame_havingSizedLabel
{
    CGRect labelFrame = self.messageLabel.frame;
    
    return CGRectMake(self.frame.origin.x,
                      self.frame.origin.y,
                      self.frame.size.width,
                      labelFrame.size.height + [self internalPadding] * 2);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)displayAndLayoutWithText:(NSString *)text
{
    self.messageLabel.text = text;
    
    CGRect original_frame = [self _new_templateFrameFor_messageLabel];
    self.messageLabel.frame = original_frame;
    [self.messageLabel sizeToFit];
    CGRect new_frame = self.messageLabel.frame;
    new_frame.origin.x = original_frame.origin.x; // just in case
    new_frame.origin.y = original_frame.origin.y; // this gets changed
    new_frame.size.width = original_frame.size.width; // this gets changed usually
    self.messageLabel.frame = new_frame;
    
    self.frame = [self _new_frame_havingSizedLabel];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageViewSide = [self imageViewSide];
    self.imageView.frame = CGRectMake([self internalPadding], [self internalPadding], imageViewSide, imageViewSide);
    // ^ Fixed layout… could potentially be moved

    // We already lay out the message label in the method -displayAndLayoutWithText:
    {
        self.visualEffectView.frame = self.bounds;
        self.visualEffectView.contentView.frame = self.bounds;
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation






@end
