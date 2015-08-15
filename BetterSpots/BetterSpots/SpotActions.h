//
//  SpotActions.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>

@interface SpotActions : NSObject
+ (void)addNewAddresBookContactWithContentOfTheSpot: (NSDictionary *) theSpotInfoDict inContextOfViewController: (UIViewController *) uiViewController;
+ (void)navigateUserToTheSpot: (NSDictionary *) theSpotInfoDict;
+ (void)shareTheSpot: (NSDictionary *) theSpotInfoDict inContextOfViewController: (UIViewController *) uiViewController forAppName: (NSString *)appName withImage:(UIImage*)image;
+ (NSString *)getFormattedDistanceWith: (double)distance;
+ (NSString *)getFAStarsFormattedRating: (double)rating;
@end
