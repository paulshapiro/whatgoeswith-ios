//
//  WGWBannerView.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/23/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGWBannerView : UIView

+ (void)showAndDismissAfterDelay_message:(NSString *)messageString;
+ (void)dismissImmediately_animated:(BOOL)animated;

@end
