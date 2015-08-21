//
//  MyManager.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "MyManager.h"

@implementation MyManager

@synthesize spots;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init: (NSMutableArray * )fetchedSpots {
    if (self = [super init]) {
        spots = fetchedSpots;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end