//
//  UIDevice+Expansion.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "UIDevice+Expansion.h"

BOOL UIDevice_isPad(void)
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
