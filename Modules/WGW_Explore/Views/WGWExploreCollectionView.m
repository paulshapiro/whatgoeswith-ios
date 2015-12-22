//
//  WGWExploreCollectionView.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreCollectionView.h"



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreCollectionView ()

@property (nonatomic, strong) NSMutableArray *dictionariesOfActiveTouches;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWExploreCollectionView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup

- (void)setup
{
    self.dictionariesOfActiveTouches = [NSMutableArray array];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives - Touch manipulation

- (void)removeTouches:(NSSet *)touches
{
    for (id touch in touches) {
        NSMutableArray *touchDictionariesToRemove = [NSMutableArray array];
        
        for (NSDictionary *dictionary in self.dictionariesOfActiveTouches) {
            if ([[dictionary valueForKey:@"touch"] isEqual:touch]) {
                [touchDictionariesToRemove addObject:dictionary];
            }
        }
        
        for (id touchDictionary in touchDictionariesToRemove) {
            [self.dictionariesOfActiveTouches removeObject:touchDictionary];
        }
    }
}

- (void)cancelActiveTouches
{
    for (NSDictionary *touchDictionary in self.dictionariesOfActiveTouches) {
        UITouch *touch = [touchDictionary objectForKey:@"touch"];
        UIEvent *event = [touchDictionary objectForKey:@"event"];
        
        [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    for (id touch in touches) {
        [self.dictionariesOfActiveTouches addObject:@
         {
             @"touch" : touch,
             @"event" : event
         }];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self removeTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self removeTouches:touches];
}

@end
