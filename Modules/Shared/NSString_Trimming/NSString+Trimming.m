//
//  NSString+Trimming.m
//  Producer
//
//  Created by Paul Shapiro on 5/12/15.
//  Copyright (c) 2015 Lunarpad Corporation. All rights reserved.
//

#import "NSString+Trimming.h"

@implementation NSString (Trimming)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Whitespace

- (NSString *)stringByTrimmingLeadingWhitespace
{
    NSInteger i = 0;
    while ((i < self.length) && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    
    return [self substringFromIndex:i];
}

- (NSString *)stringByTrimmingTrailingWhitespace
{
    NSInteger i = self.length - 1;
    while ((i >= 0) && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i--;
    }
    
    return [self substringToIndex:i + 1];
}

- (NSString *)stringByTrimmingWrappingWhitespace
{
    return [[self stringByTrimmingLeadingWhitespace] stringByTrimmingTrailingWhitespace];
}

@end

