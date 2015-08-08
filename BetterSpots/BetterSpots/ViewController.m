//
//  ViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "ViewController.h"
//#import "MyUtils.h"
#import <GoogleMaps/GoogleMaps.h>

NSString * const SpotsEndpointURL = @"com.andilabs.SpotsEndpointURL";
NSString * const SpotsEmoji = @"com.andilabs.SpotsEmoji";

@implementation ViewController {
    GMSMapView *mapView_;
    CLLocationManager *_locationManager;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLLocation *_location;
    NSString *emojiString;
    NSString *appName;
    NSString *urlString;

//    NSDate *startTime;
    NSUserDefaults *defaults;
    NSMutableArray * currentMarkers;
}

-(NSMutableArray*)getLocalMarkers: (float)lat andLon: (float) lon withRadius: (int) radius
{
    NSString * locaticonBasedUrl =[NSString stringWithFormat:@"%@nearby/%.5f/%.5f/%.d",urlString, lat, lon,radius];
    NSLog(@"ADDRESS IN USE IS: %@",locaticonBasedUrl);
    NSURL * myUrl = [NSURL URLWithString:locaticonBasedUrl];
    NSData *data = [NSData dataWithContentsOfURL:myUrl];
    NSError * myErr;
    NSMutableArray *localMarkers= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&myErr];
    NSLog(@"markers: %@", localMarkers);
    return localMarkers;
}


-(void)drawMarkersOnMap:(NSMutableArray*)acctual
{
    if ([acctual count] > 0){
        for (NSDictionary * marker in acctual){
            
            GMSMarker *spotMarker = [[GMSMarker alloc] init];
            spotMarker.title = marker[@"name"];
            spotMarker.position = CLLocationCoordinate2DMake([marker[@"location"][@"latitude"] doubleValue], [marker[@"location"][@"longitude"]doubleValue]);
            spotMarker.userData = marker;
            
            
//            switch ([marker[@"is_enabled"] intValue]){
//                case 0:
//                    spotMarker.icon = [MyUtils imageWithImage:[UIImage imageNamed:@"marker-bad"] scaledToSize:CGSizeMake(20, 20)];
//                    break;
//                case 1:
//                    spotMarker.icon = [MyUtils imageWithImage:[UIImage imageNamed:@"marker-ok"] scaledToSize:CGSizeMake(20, 20)];
//                    break;
//            }
            spotMarker.snippet =[NSString stringWithFormat:@"%@ %@ \nabout %.0f meters away. \nRating: %.2f%% postive",marker[@"address_street"], marker[@"address_number"],[marker[@"distance"]doubleValue]*1000, ([marker[@"friendly_rate"]doubleValue]/5.0*100)];
            
            
            spotMarker.map = mapView_;
            
        }
    }
    else{
        NSLog(@"No results for such location");
    }
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

//    startTime = [NSDate date];
    [self startLocationManager];


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
                // Location disabled
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
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
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
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];

//    NSLog(@"horizontal acc: %f", newLocation.horizontalAccuracy);
//    NSLog(@" %@", locations);
//    NSLog(@"did Update Locations %@", newLocation);
//    NSLog(@"new location timestamp timeIntervalSinceNow: %f", [newLocation.timestamp timeIntervalSinceNow]);

    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0){
//         NSLog(@"CACHED RESULT - IGNORE");
        // If the time at which the location object was determined is too long ago (5 seconds in this case), then this is a so-called cached result. Instead of returning a new location fix, the location manager may initially give you the most recently found location under the assumption that you might not have moved much since last time (obviously this does not take into consideration people with jet packs). You’ll simply ignore these cached locations if they are too old.
        return;
    }
    if (newLocation.horizontalAccuracy < 0){
//        NSLog(@"BAD ACCURACY - IGNORE");
        // this is case of very bad accuracy meassurment which should be IGNORED
        return;
    }

    if (_location == nil || _location.horizontalAccuracy >= newLocation.horizontalAccuracy) {
//        NSLog(@"the _location was EMPTY or newLocation accuracy is BETTER (smaller) than existin _location");
        _lastLocationError = nil;
        _location = newLocation;
        
        [defaults setFloat: newLocation.coordinate.latitude forKey:@"starLatitude"];
        [defaults setFloat: newLocation.coordinate.longitude forKey:@"starLongitude"];
        [defaults synchronize];
 
        
        NSLog(@"obj for key: starLatitude, starLongitude: %@, %@",
              [defaults objectForKey:@"starLatitude"],
              [defaults objectForKey:@"starLongitude"]);
        
        
        currentMarkers = [NSMutableArray arrayWithArray:[self getLocalMarkers: [defaults floatForKey:@"starLatitude"]
                                                                       andLon: [defaults floatForKey:@"starLongitude"]
                                                                   withRadius: 8000]];
        
        NSLog(@"%@", currentMarkers);
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[defaults floatForKey:@"starLatitude"]
                                                                longitude:[defaults floatForKey:@"starLongitude"]
                                                                     zoom:13];
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView_.myLocationEnabled = YES;
        mapView_.settings.compassButton = YES;
        mapView_.settings.myLocationButton = YES;
        mapView_.settings.scrollGestures = YES;
        mapView_.settings.zoomGestures = YES;
        
        
        self.view = mapView_;
        [self drawMarkersOnMap: currentMarkers];
        
        [self stopLocationManager]; // naive version, satisfy yourself with first result

//       better version will try getting better result for certain amount of time
//        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy){
//            NSLog(@"*** Yay we're done!");
//            [self stopLocationManager];
//        }

    }

    _lastLocationError = nil;
    _location = newLocation;
}



@end
