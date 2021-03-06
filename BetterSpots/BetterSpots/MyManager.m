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
@synthesize favouritesSpots;
@synthesize favDict;
@synthesize favPKs;

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

- (id)initFav: (NSMutableArray * )_spots {
    if (self = [super init]) {
        favouritesSpots = _spots;
    }
    return self;
}

- (void)addSpot:(NSDictionary *)spot {
    NSMutableArray *current_spots = [NSMutableArray arrayWithArray:spots];
    [current_spots addObject:spot];
    [self init:current_spots];
}

-(void)removeSpotWithPK:(int)pk {
    NSMutableArray *current_spots = [NSMutableArray arrayWithArray:spots];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pk == %d", pk];
    NSArray *tempArray = [spots filteredArrayUsingPredicate:predicate];
    [current_spots removeObject:[tempArray objectAtIndex:0]];
    [self init:current_spots];
   
}

-(void)addSpotToFav:(NSDictionary *)spot{
    if (![self isInFavouritesSpotWithPK:[spot[@"pk"] intValue]]){
    NSMutableArray *current_spots = [NSMutableArray arrayWithArray:self.favouritesSpots];
    [current_spots insertObject:spot atIndex:0];
    [self initFav:current_spots];
    [self saveFavouritesSpots];
    }
}

-(void)removeSpotFromFavourites:(NSDictionary *)spot {
     if ([self isInFavouritesSpotWithPK:[spot[@"pk"] intValue]]){
         NSMutableArray *current_spots = [NSMutableArray arrayWithArray:self.favouritesSpots];
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pk != %d", [spot[@"pk"] intValue]];
         NSArray *tempArray = [self.favouritesSpots filteredArrayUsingPredicate:predicate];
         [self initFav:(NSMutableArray*)tempArray];
         [self saveFavouritesSpots];
    }
}

-(BOOL)isInFavouritesSpotWithPK:(int)pk {
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"pk == %d", pk];
    NSArray *temp = [self.favouritesSpots filteredArrayUsingPredicate:filterPredicate];
    return [temp count];
}


- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Spots.plist"];
}

- (NSString *)dataFilePathFavourites
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"FavouritesSpots.plist"];
}

- (void)saveSpots
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:spots forKey:@"Spots"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadSpots
{
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        spots = [unarchiver decodeObjectForKey:@"Spots"];
        [unarchiver finishDecoding];
    }
}

- (void)saveFavouritesSpots
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:favouritesSpots forKey:@"FavouritesSpots"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePathFavourites] atomically:YES];
}

- (void)loadFavouritesSpots
{
    NSLog(@"- (void)loadFavouritesSpots");
    NSString *path = [self dataFilePathFavourites];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        favouritesSpots = [unarchiver decodeObjectForKey:@"FavouritesSpots"];
        [unarchiver finishDecoding];
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end