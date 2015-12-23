//
//  WGWAnalytics.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/22/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWAnalytics.h"
#import "SEGAnalytics.h"
#import "SEGAnalyticsUtils.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Declarations - Functions

NSString *_WGWAnalytics_segment_projectWriteKey(void);
NSString *_WGWAnalytics_shared_persistedOrCreated_timeIntervalSince1970_ofFirstEvent__NSString(void);
double _WGWAnalytics_timeIntervalSince1970_ofFirstEvent(void);


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementations - Functions - Entrypoints

static NSString *WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSString = @"WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSString";

NSNumber *WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber__orNilIfNone(void)
{
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSString];
    NSNumber *number = @(string.doubleValue);

    return number;
}

void WGWAnalytics_setDateThat_appLastBecameActive(void)
{
    NSDate *date = [NSDate date];
    NSTimeInterval timeIntervalSince1970 = date.timeIntervalSince1970;
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", timeIntervalSince1970]
                                                  forKey:WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

void __WGWAnalytics_once_setupAnalytics(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
//        SEGSetShowDebugLogs(YES);
        
        [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:_WGWAnalytics_segment_projectWriteKey()]];
    });
}

void WGWAnalytics_identifyUser(NSString *userId, NSDictionary *traits)
{
#if (ANALYTICS_OFF==1)
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
    NSMutableDictionary *finalized_properties = [parameters_base mutableCopy];
    { // Finalize parameters
        NSTimeInterval timeIntervalSince1970_ofFirstEvent = _WGWAnalytics_timeIntervalSince1970_ofFirstEvent();
        NSDate *date = [NSDate new];
        NSTimeInterval timeIntervalSince1970 = [date timeIntervalSince1970];
        finalized_properties[@"timeIntervalSince1970_ofFirstEvent"] = @(timeIntervalSince1970_ofFirstEvent);
        finalized_properties[@"timeIntervalSince1970_ofThisEvent"] = @(timeIntervalSince1970);
        finalized_properties[@"timeIntervalSinceFirstEvent"] = @(timeIntervalSince1970 - timeIntervalSince1970_ofFirstEvent);
        
        double timeIntervalSinceLastEvent;
        {
            static NSString *WGWAnalytics_timeIntervalSince1970_ofLastEvent_persistence_key__NSString = @"WGWAnalytics_timeIntervalSince1970_ofLastEvent_persistence_key__NSString";
            NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:WGWAnalytics_timeIntervalSince1970_ofLastEvent_persistence_key__NSString];
            if (string == nil) {
                timeIntervalSinceLastEvent = -1;
            } else {
                timeIntervalSinceLastEvent = timeIntervalSince1970 - [string doubleValue];
            }
            {
                finalized_properties[@"timeIntervalSinceLastEvent"] = @(timeIntervalSinceLastEvent);
            }
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", timeIntervalSince1970]
                                                          forKey:WGWAnalytics_timeIntervalSince1970_ofLastEvent_persistence_key__NSString];
                
                // we call -synchronize below
            }
        }
        
        int numberOfEventsInThisInstallationSoFar;
        {
            static NSString *WGWAnalytics_numberOfEventsInThisInstallationSoFar_persistence_key__NSString = @"WGWAnalytics_numberOfEventsInThisInstallationSoFar_persistence_key__NSString";
            NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:WGWAnalytics_numberOfEventsInThisInstallationSoFar_persistence_key__NSString];
            if (string == nil) {
                numberOfEventsInThisInstallationSoFar = 1;
            } else {
                numberOfEventsInThisInstallationSoFar = 1 + [string intValue];
            }
            {
                finalized_properties[@"numberOfEventsInThisInstallationSoFar"] = @(numberOfEventsInThisInstallationSoFar);
            }
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberOfEventsInThisInstallationSoFar]
                                                          forKey:WGWAnalytics_numberOfEventsInThisInstallationSoFar_persistence_key__NSString];
            }
        }
        
        NSNumber *timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber = WGWAnalytics_timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber__orNilIfNone();
        {
            if (timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber == nil) {
                timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber = @(0);
            }
            {
                finalized_properties[@"timeIntervalSince_appLastBecameActive"] = @(timeIntervalSince1970 - timeIntervalSince1970_dateThat_appLastBecameActive_NSNumber.doubleValue);
            }
        }
    }
    { // No matter what, we're doing saves, so call once here
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#if (ANALYTICS_OFF==1)
        DDLogInfo(@"Would have tracked event '%@' but DEBUG==1. Parameters %@", named, finalized_properties);
        
        return;
#endif
    { // Ensure analytics are ready to go…
        __WGWAnalytics_once_setupAnalytics();
    }
    { // Now record
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
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return newlyGenerated_UUIDString;
    }
    
    return existingUUID;
}

NSString *_WGWAnalytics_shared_persistedOrCreated_timeIntervalSince1970_ofFirstEvent__NSString(void)
{
    static NSString *string = nil;
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            static NSString *WGWAnalytics_timeIntervalSince1970_ofFirstEvent_persistence_key__NSString = @"WGWAnalytics_timeIntervalSince1970_ofFirstEvent_persistence_key__NSString";
            string = [[NSUserDefaults standardUserDefaults] stringForKey:WGWAnalytics_timeIntervalSince1970_ofFirstEvent_persistence_key__NSString];
            if (string == nil) {
                string = [NSString stringWithFormat:@"%f", [[NSDate new] timeIntervalSince1970]];
                [[NSUserDefaults standardUserDefaults] setObject:string forKey:WGWAnalytics_timeIntervalSince1970_ofFirstEvent_persistence_key__NSString];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }
    assert(string != nil);
    
    return string;
}

double _WGWAnalytics_timeIntervalSince1970_ofFirstEvent(void)
{
    return [_WGWAnalytics_shared_persistedOrCreated_timeIntervalSince1970_ofFirstEvent__NSString() doubleValue];
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