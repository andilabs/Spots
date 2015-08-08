//
//  ViewController.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const SpotsEndpointURL;
extern NSString * const SpotsEmoji;

@interface ViewController : UIViewController //<CLLocationManagerDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;
@end

