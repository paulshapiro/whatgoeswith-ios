//
//  UIDevice+Expansion.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "UIDevice+Expansion.h"

BOOL __UIDevice_static_isPad(void) // assuming this isn't gonna change ... :)
{
    static BOOL isPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    });
    
    return isPad;
}

BOOL UIDevice_isPad(void)
{
    return __UIDevice_static_isPad();
}
