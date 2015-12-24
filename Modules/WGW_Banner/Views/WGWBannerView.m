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
        { // todo: inject this view into something
            
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

+ (void)showAndDismissAfterDelay_message:(NSString *)messageString
{
     _WGWBannerView_shared_bannerView();
//    - (void)displayAndLayoutWithText:(NSString *)text
}

+ (void)dismissImmediately_animated:(BOOL)animated
{
    
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
        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
        self.visualEffectView = view;
        {
            
        }
        [self addSubview:view];
    }
    {
        UIImageView *view = [[UIImageView alloc] init];
        view.layer.transform = CATransform3DMakeRotation(10, 0, 0, 1); // hehe…
        self.imageView = view;
        {
            
        }
        [self addSubview:view];
    }
    {
        UILabel *view = [[UILabel alloc] init];
        self.messageLabel = view;
        {
            view.text = @"Ohi";
        }
        [self addSubview:view];
    }
    [self borderSubviews];
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
    CGFloat x = [self internalPadding] + self.imageViewSide + [self internalPadding]/2; // /2 is just a visual ratio for extra padding
    
    return CGRectMake(x,
                      [self internalPadding]/2,
                      self.bounds.size.width - x - [self internalPadding],
                      self.bounds.size.height - ([self internalPadding]/2) * 2);
}

- (CGRect)_new_frame_havingSizedLabel
{
    CGRect labelFrame = self.messageLabel.frame;
    
    return CGRectMake(self.frame.origin.y,
                      self.frame.origin.y,
                      self.frame.size.width,
                      labelFrame.size.height + ([self internalPadding]/2) * 2);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)displayAndLayoutWithText:(NSString *)text
{
    self.messageLabel.text = text;
    self.messageLabel.frame = [self _new_templateFrameFor_messageLabel];
    [self.messageLabel sizeToFit];
    
    self.frame = [self _new_frame_havingSizedLabel];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageViewSide = [self imageViewSide];
    self.imageView.frame = CGRectMake(10, 10, imageViewSide, imageViewSide);
    // ^ Fixed layout… could potentially be moved

    // We already lay out the message label in the method -displayAndLayoutWithText:
    {
        self.visualEffectView.frame = self.bounds;
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation






@end
