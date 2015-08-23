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
    if (self = [super init]) {
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
    NSMutableArray *current_spots = [NSMutableArray arrayWithArray:favouritesSpots];
    [current_spots addObject:spot];
    [self initFav:current_spots];
}

-(void)removeSpotWithPKfromFav:(NSDictionary *)spot {
    [favouritesSpots removeObject:spot];
}
//-(void)removeSpotWithPKfromFav:(int)pk {
//    
//    NSMutableArray *notDiscardedItems = [NSMutableArray array];
//    NSDictionary *item;
//    for (item in favouritesSpots) {
//        if ([[item objectForKey:@"pk"]intValue]!=pk)
//            [notDiscardedItems addObject:item];
//    }
//    [self initFav:notDiscardedItems];
//}

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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end