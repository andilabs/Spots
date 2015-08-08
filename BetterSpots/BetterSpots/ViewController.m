//
//  ViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

NSString * const SpotsEndpointURL = @"com.andilabs.SpotsEndpointURL";
NSString * const SpotsEmoji = @"com.andilabs.SpotsEmoji";

@implementation ViewController {
    CLLocationManager *_locationManager;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLLocation *_location;
    NSString *emojiString;
    NSString *appName;
    NSString *urlString;
    NSDate *startTime;
    NSUserDefaults *defaults;
}


-(void)promptUserAboutGeolocationDisabled{
    NSString * geoDisabledWarrning = [NSString  stringWithFormat:@"We ♥️%@, but we can not search spots for you, because geolocation is disabled.\n\n Please go to Settings>%@ and enable geo location", emojiString, appName];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Geolocation disabled!"
                                          message:geoDisabledWarrning
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK, take me there!"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action){
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                               }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])){
        defaults = [NSUserDefaults standardUserDefaults];
        _locationManager = [[CLLocationManager alloc] init];

    }
    return self;
}

- (void)viewDidLoad {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    urlString = [infoDictionary objectForKey:SpotsEndpointURL];
    emojiString = [infoDictionary objectForKey:SpotsEmoji];
    appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];

    startTime = [NSDate date];
    [self startLocationManager];

    if (_locationManager.location.coordinate.latitude){
        NSLog(@"I have some location");
        NSLog(@"%f,%f, %f, %@",
              _locationManager.location.coordinate.latitude,
              _locationManager.location.coordinate.longitude,
              _locationManager.location.horizontalAccuracy,
              _location);
    }
    NSLog(@"%@",[defaults objectForKey:@"starLatitude"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
    NSLog(@"did Fail With Error: domain: %@ code: %ld", error.domain, (long)error.code);

    if ([error domain] == kCLErrorDomain) {

        switch ([error code]) {
            case kCLErrorDenied: {
                [self promptUserAboutGeolocationDisabled];
                break;
            }
            case kCLErrorLocationUnknown: {
                //location manager was unable to obtain a location right now,
                // but that doesn’t mean all is lost. It might just need another
                // second or so to get an uplink to the GPS satellite
                // keep trying
                NSLog(@" another shit happens, but keep trying");
                return;
            }
            default: {
                //...
                break;
            }
        }
    } else {
        // We handle all non-CoreLocation errors here
    }

    [self stopLocationManager];
    _lastLocationError = error;
    
}

- (void)startLocationManager
{
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }

    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"starting updating location....");
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;


        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
    }

}

- (void)stopLocationManager
{
    if (_updatingLocation) {
        NSLog(@"stoping update of loc");
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

// Location Manager Delegate Methods
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"menopauza?");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Time: %f", -[startTime timeIntervalSinceNow]);

    
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"horizontal acc: %f", newLocation.horizontalAccuracy);
    NSLog(@" %@", locations);
    NSLog(@"did Update Locations %@", newLocation);
    NSLog(@"new location timestamp timeIntervalSinceNow: %f", [newLocation.timestamp timeIntervalSinceNow]);
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0){
         NSLog(@"CACHED RESULT - IGNORE");
        // If the time at which the location object was determined is too long ago (5 seconds in this case), then this is a so-called cached result. Instead of returning a new location fix, the location manager may initially give you the most recently found location under the assumption that you might not have moved much since last time (obviously this does not take into consideration people with jet packs). You’ll simply ignore these cached locations if they are too old.
        return;
    }
    if (newLocation.horizontalAccuracy < 0){
        NSLog(@"BAD ACCURACY - IGNORE");
        // this is case of very bad accuracy meassurment which should be IGNORED
        return;
    }

    if (_location == nil || _location.horizontalAccuracy >= newLocation.horizontalAccuracy) {
        NSLog(@"the _location was nil (EMPTY) or the current _location accuracy was WORSE than newLocation");
        _lastLocationError = nil;
        _location = newLocation;
        
        [defaults setDouble: newLocation.coordinate.latitude forKey:@"starLatitude"];
        [defaults setDouble: newLocation.coordinate.longitude forKey:@"starLongitude"];
        [defaults synchronize];
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy){
            NSLog(@"*** Yay we're done!");
            NSLog(@"horizontal acc: %f", newLocation.horizontalAccuracy);
            [self stopLocationManager];
        }
    }
    else if (_location != nil && _location.horizontalAccuracy == newLocation.horizontalAccuracy){

        NSLog(@"the _location NOT nil, but the current _location accuracy SAME as newLocation");
    }
    else if (_location != nil && _location.horizontalAccuracy < newLocation.horizontalAccuracy){

        NSLog(@"the _location NOT nil, but the current _location accuracy BETTER as newLocation");
    }

    _lastLocationError = nil;
    _location = newLocation;

}



@end
