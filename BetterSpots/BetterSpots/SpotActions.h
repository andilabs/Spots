//
//  SpotActions.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <math.h>
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>

#import "BetterSpotsCommon.h"
#import "BetterSpotsUtils.h"


@interface SpotActions : NSObject
+ (void)addNewAddresBookContactWithContentOfTheSpot:(NSDictionary *)theSpotInfoDict
                          inContextOfViewController:(UIViewController *)uiViewController;
+ (void)navigateUserToTheSpot:(NSDictionary *)theSpotInfoDict;
+ (void)shareTheSpot:(NSDictionary *)theSpotInfoDict
         inContextOf:(UIViewController *)uiViewController
          forAppName:(NSString *)appName
           withImage:(UIImage *)image;
+ (int)getDistanceInMetersFrom: (CLLocation*)locationA to: (CLLocation*)locationB;
+ (NSString *)getFormattedDistanceWith:(double)distance;
+ (NSString *)getFAStarsFormattedRating:(double)rating;
@end
