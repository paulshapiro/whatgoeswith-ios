//
//  WGWAnalytics.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/22/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *WGWAnalytics_persistedOrNew_installationUUID(void);

extern void WGWAnalytics_identifyUser(NSString *userId, NSDictionary *traits);

extern void WGWAnalytics_trackEvent(NSString *named, NSDictionary *parameters_base);