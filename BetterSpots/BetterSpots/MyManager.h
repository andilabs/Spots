//
//  MyManager.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//


#import <foundation/Foundation.h>

@interface MyManager : NSObject {
    NSMutableArray *spots;
}

@property (nonatomic, retain) NSMutableArray *spots;

+ (id)sharedManager;
- (id)init: (NSMutableArray * )fetchedSpots;
@end