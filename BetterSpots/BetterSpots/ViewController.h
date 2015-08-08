//
//  ViewController.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import <GoogleMaps/GoogleMaps.h>

extern NSString * const SpotsEndpointURL;
extern NSString * const SpotsEmoji;

@interface ViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;
-(NSMutableArray*)getLocalMarkers: (float)lat andLon: (float) lon withRadius: (int) radius;

@end

