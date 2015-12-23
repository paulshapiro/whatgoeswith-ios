//
//  WGWAnalytics.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/22/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWAnalytics.h"
#import "SEGAnalytics.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Declarations - Functions

NSString *_WGWAnalytics_segment_projectWriteKey(void);


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementations - Functions - Entrypoints

void __WGWAnalytics_once_setupAnalytics(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:_WGWAnalytics_segment_projectWriteKey()]];
    });
}

void WGWAnalytics_identifyUser(NSString *userId, NSDictionary *traits)
{
#if (DEBUG==1)
    DDLogInfo(@"Would have identified user but DEBUG==1. UserId '%@' traits %@", userId, traits);

    return;
#endif
    { // Ensure analytics are ready to go…
        __WGWAnalytics_once_setupAnalytics();
    }
    { // Now record
        [[SEGAnalytics sharedAnalytics] identify:userId traits:traits];
    }
}

void WGWAnalytics_trackEvent(NSString *named, NSDictionary *parameters_base)
{
#if (DEBUG==1)
    DDLogInfo(@"Would have tracked event '%@' but DEBUG==1. Parameters %@", named, parameters_base);
    
    return;
#endif
    { // Ensure analytics are ready to go…
        __WGWAnalytics_once_setupAnalytics();
    }
    { // Now record
        NSDictionary *finalized_properties = [parameters_base mutableCopy];
        { //
            
        }
        [[SEGAnalytics sharedAnalytics] track:named properties:finalized_properties];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementations - Functions - Accessors

NSString *WGWAnalytics_persistedOrNew_installationUUID(void)
{
    static NSString *WGWAnalytics_installationIdentifierUUID_persistence_key = @"WGWAnalytics_installationIdentifierUUID_persistence_key";
    NSString *existingUUID = [[NSUserDefaults standardUserDefaults] stringForKey:WGWAnalytics_installationIdentifierUUID_persistence_key];
    if (existingUUID == nil) {
        NSString *newlyGenerated_UUIDString = [NSString new_UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:newlyGenerated_UUIDString forKey:WGWAnalytics_installationIdentifierUUID_persistence_key];
        
        return newlyGenerated_UUIDString;
    }
    
    return existingUUID;
}

NSString *_WGWAnalytics_segment_projectWriteKey(void)
{
    static NSMutableString *string = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        string = [NSMutableString new];
        {
            // wbrXOTj99HskaHZLEXbRmMh4uJgUAs2t
            [string appendString:@"w"];
            [string appendString:@"b"];
            [string appendString:@"r"];
            [string appendString:@"X"];
            [string appendString:@"O"];
            [string appendString:@"T"];
            [string appendString:@"j"];
            [string appendString:@"9"];
            [string appendString:@"9"];
            [string appendString:@"H"];
            [string appendString:@"s"];
            [string appendString:@"k"];
            [string appendString:@"a"];
            [string appendString:@"H"];
            [string appendString:@"Z"];
            [string appendString:@"L"];
            [string appendString:@"E"];
            [string appendString:@"X"];
            [string appendString:@"b"];
            [string appendString:@"R"];
            [string appendString:@"m"];
            [string appendString:@"M"];
            [string appendString:@"h"];
            [string appendString:@"4"];
            [string appendString:@"u"];
            [string appendString:@"J"];
            [string appendString:@"g"];
            [string appendString:@"U"];
            [string appendString:@"A"];
            [string appendString:@"s"];
            [string appendString:@"2"];
            [string appendString:@"t"];
        }
    });
    
    return string;
}