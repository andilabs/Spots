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
#import "BetterSpotsUtils.h"
#import "SpotDetailsViewController.h"
#import "Reachability.h"
#import "SpotActions.h"
#import "BetterSpotsCommon.h"



@interface ViewController :  UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, UINavigationControllerDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;

-(NSMutableArray*)getNearbylSpotsWithLat:(float)lat
                                  andLon:(float)lon
                            withinRadius:(int)radius;
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker;

@end

