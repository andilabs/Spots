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

- (id)initFav: (NSMutableArray * )spots {
    NSLog(@"initFav");
    if (self = [super init]) {
        NSLog(@"initFav if (self = [super init])  TRUE");
        favouritesSpots = spots;
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
    NSLog(@"-(void)addSpotToFav:(NSDictionary *)spot");
    NSMutableArray *current_spots = [NSMutableArray arrayWithArray:favouritesSpots];
    [current_spots insertObject:spot atIndex:0];
    [self initFav:current_spots];
    [self saveFavouritesSpots];
}

-(void)removeSpotFromFavourites:(NSDictionary *)spot {
    [favouritesSpots removeObject:spot];
    [self saveFavouritesSpots];
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
    NSLog(@"- (void)saveFavouritesSpots");
    NSLog(@" count: %d", [favouritesSpots count]);
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
        NSLog(@"loaded: ", favouritesSpots);
        [unarchiver finishDecoding];
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end