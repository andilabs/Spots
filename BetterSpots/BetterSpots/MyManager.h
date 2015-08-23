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
    NSMutableArray *favouritesSpots;
}

@property (nonatomic, retain) NSMutableArray *spots;
@property (nonatomic, retain) NSMutableArray *favouritesSpots;
@property (nonatomic, retain) NSMutableOrderedSet * favPKs;
@property (nonatomic, retain) NSMutableDictionary * favDict;
+ (id)sharedManager;
- (id)init: (NSMutableArray * )fetchedSpots;
- (id) initFav: (NSMutableArray *)favSpots;
- (void)addSpot:(NSDictionary *)spot;
- (void)saveSpots;
- (void)loadSpots;
- (void)saveFavouritesSpots;
- (void)loadFavouritesSpots;
-(void)removeSpotWithPK:(int)pk;
-(void)addSpotToFav:(NSDictionary *)spot;
-(void)removeSpotFromFavourites:(NSDictionary *)spot;

//-(void)removeSpotWithPKfromFav:(int)pk;
@end