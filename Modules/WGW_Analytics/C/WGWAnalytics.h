//
//  WGWAnalytics.h
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/22/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

void WGWAnalytics_setDateThat_appLastBecameActive(void);

extern NSString *WGWAnalytics_persistedOrNew_installationUUID(void);
extern NSString *_WGWAnalytics_shared_persistedOrCreated_timeIntervalSince1970_ofFirstEvent__NSString(void);

extern void WGWAnalytics_identifyUser(NSString *userId, NSDictionary *traits);

extern void WGWAnalytics_trackEvent(NSString *named, NSDictionary *parameters_base);