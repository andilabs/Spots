//
//  ViewController.m
//  DogspotEU
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
//@import CoreLocation;
NSString * const SpotsEndpointURL = @"com.andilabs.SpotsEndpointURL";
//@interface ViewController () <CLLocationManagerDelegate>
//@property (strong, nonatomic) CLLocationManager *locationManager;
//@end

@implementation ViewController {
    GMSMapView *_mapView;
    CLLocationManager *_locationManager;
    CLLocation *_location;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])){
        _locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"%@", SpotsEndpointURL);
    NSString *urlString = [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsEndpointURL];
    NSLog(@"%@", urlString);
    
//    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    [self.locationManager startUpdatingLocation];
//    _mapView.myLocationEnabled = YES;
//    self.view = _mapView;

//    // Create a GMSCameraPosition that tells the map to display the
//    // coordinate -33.86,151.20 at zoom level 6.
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
//                                                            longitude:151.20
//                                                                 zoom:16];
//    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//    _mapView.myLocationEnabled = YES;
//    NSLog(@"User's location: %@", _mapView.myLocation);
    
    self.view = _mapView;
    
    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Your current";
//    marker.snippet = @"Location";
//    marker.map = _mapView;


}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    _location = newLocation;
    
    NSLog(@"%@", [NSString stringWithFormat:
                  @"%.8f", newLocation.coordinate.latitude]);
    NSLog(@"%.8f", newLocation.coordinate.longitude);
    NSLog(@"%f", newLocation.horizontalAccuracy);
    NSLog(@"%f", newLocation.horizontalAccuracy);
//    if (_mapView.myLocation) {
//        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_mapView.myLocation.coordinate.latitude longitude:_mapView.myLocation.coordinate.longitude zoom:16];
//        _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//        _mapView.myLocationEnabled = YES;
//        self.view = _mapView;
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
