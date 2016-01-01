//
//  SFX_Playback.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 1/1/16.
//  Copyright © 2016 Lunarpad Corporation. All rights reserved.
//

#import "SFX_Playback.h"
#import <BRYSoundEffectPlayer/BRYSoundEffectPlayer.h>


void SFX_Playback_playBundledShortSoundEffectNamed(NSString *filename,
                                                   NSString *fileExtension)
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:fileExtension];
    {
        NSCAssert(path != nil, @"path was nil");
    }
    [[BRYSoundEffectPlayer sharedInstance] playSound:path];
}