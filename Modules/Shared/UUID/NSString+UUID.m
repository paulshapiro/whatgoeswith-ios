//
//  NSString_UUID.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/22/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSString (UUID)

+ (NSString *)new_UUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return uuidString;
}


@end
