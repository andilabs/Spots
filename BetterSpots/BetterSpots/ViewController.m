//
//  ViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//
#import "BetterSpotsUtils.h"
#import "ViewController.h"
#import "MyActivityIndicatorView.h"

@interface ViewController()
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation ViewController {

    NSMutableArray * currentSpots;
    NSDictionary * infoOfCurrentlySelectedSpot;

    GMSMapView *mapView_;
    CLLocationManager *_locationManager;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLLocation *_location;

    NSUserDefaults *defaults;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    // make background color of navigation bar with spot default color
    self.navigationController.navigationBar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
    // make fonts on navigation bar white
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        [BetterSpotsUtils showAlertInfoWithTitle: @"No internet connection 😢"
                                      andMessage: @"We need internet to fetch spots for you."
                       inContextOfViewController: self];
    }
    else {
        MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithFrame:CGRectMake(
                                                                                                                    0,
                                                                                                                    0,
                                                                                                                    self.view.frame.size.width,
                                                                                                                    self.view.frame.size.height
                                                                                                                    )];
        self.view = activityIndicatorView;
        [self startLocationManager];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])){
        defaults = [NSUserDefaults standardUserDefaults];
        _locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - fetching markers, drawing markers

-(NSMutableArray*)getNearbylSpotsWithLat:(float)lat andLon:(float)lon withinRadius:(int)radius
{
    NSString * locaticonBasedUrl =[NSString stringWithFormat: @"%@nearby/%.5f/%.5f/%.d",
                                   [BetterSpotsUtils getSpotsNearbyApiUrl],
                                   lat,
                                   lon,
                                   radius];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:locaticonBasedUrl]];
    if (data) {
        NSError * myErr;
        NSMutableArray * spots = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&myErr];
        return spots;
    }
    else {
        return nil;
    }

}

- (void)drawMarkersOnMap:(NSMutableArray*)spots
{
    if ([spots count] > 0){
        for (NSDictionary * spot in spots){
            GMSMarker *spotMarker = [[GMSMarker alloc] init];
            spotMarker.title = spot[@"name"];
            spotMarker.position = CLLocationCoordinate2DMake([spot[@"location"][@"latitude"] doubleValue], [spot[@"location"][@"longitude"]doubleValue]);
            spotMarker.userData = spot;
            switch ([spot[@"is_enabled"] intValue]){
                case 0:
                    spotMarker.icon = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-bad-kopia-v2"]
                                              scaledToSize:CGSizeMake(18, 45)];
                    break;
                case 1:
                    spotMarker.icon = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-ok-kopia-v2"]
                                              scaledToSize:CGSizeMake(18, 45)];
                    break;
            }
            spotMarker.groundAnchor = CGPointMake(0.5, 1.0);
            int ratingValue = roundf([spot[@"friendly_rate"]floatValue]);
//            NSString *numberString = [NSString stringWithFormat:@"%f", roundf([spot[@"friendly_rate"]floatValue])];
//            NSLog(@"%@ %d %.2f",
//                  spot[@"friendly_rate"],
//                  (int)roundf([spot[@"friendly_rate"]floatValue]),
//                  ((roundf([spot[@"friendly_rate"]floatValue])-[spot[@"friendly_rate"]floatValue]))
//                  );
//            NSLog(@"%@", numberString);
            if (ratingValue < 0){
                ratingValue = 0;
            }
            spotMarker.snippet = [NSString stringWithFormat:@"%@ %@\n%@\n\n%@ away.",
                                  spot[@"address_street"],
                                  spot[@"address_number"],
                                  [@"" stringByPaddingToLength:[@"⭐️" length]*ratingValue
                                                    withString: @"⭐️" startingAtIndex:0],
                                  [SpotActions getFormattedDistanceWith:[spot[@"distance"]doubleValue]]];
            spotMarker.map = mapView_;
            
        }
    }
}


#pragma mark - geolocation stuff

-(void)promptUserAboutGeolocationDisabled{
    NSString * geoDisabledWarrning = [NSString  stringWithFormat:
                                      @"We ♥️%@, but we can not search spots for you, because geolocation is disabled.\n\n Please go to Settings>%@ and enable geo location",
                                      [BetterSpotsUtils getSpotsMainEmoji],
                                      [BetterSpotsUtils getSpotsAppName]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Geolocation disabled!"
                                                                             message:geoDisabledWarrning
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK, take me there!"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action){
                                                         [[UIApplication sharedApplication] openURL:
                                                          [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
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
                return;
            }
            default: {
                [BetterSpotsUtils showAlertInfoWithTitle: @"We are very sad 😢"
                                              andMessage: @"But we can not geolocate you. Try again later."
                               inContextOfViewController: self];
                break;
            }
        }
    } else {
        [BetterSpotsUtils showAlertInfoWithTitle: @"We are very sad 😢"
                                      andMessage: @"But we can not geolocate you. Try again later."
                       inContextOfViewController: self];
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

    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0){
        // If the time at which the location object was determined is too long ago (5 seconds in this case), then this is a so-called cached result. Instead of returning a new location fix, the location manager may initially give you the most recently found location under the assumption that you might not have moved much since last time (obviously this does not take into consideration people with jet packs). You’ll simply ignore these cached locations if they are too old.
        return;
    }
    if (newLocation.horizontalAccuracy < 0){
        // this is case of very bad accuracy meassurment which should be IGNORED
        return;
    }

    if (_location == nil || _location.horizontalAccuracy >= newLocation.horizontalAccuracy) {

        _lastLocationError = nil;
        _location = newLocation;
        [defaults setFloat: newLocation.coordinate.latitude forKey:@"starLatitude"];
        [defaults setFloat: newLocation.coordinate.longitude forKey:@"starLongitude"];
        [defaults synchronize];

        currentSpots = [NSMutableArray arrayWithArray:[self getNearbylSpotsWithLat:[defaults floatForKey:@"starLatitude"]
                                                                       andLon:[defaults floatForKey:@"starLongitude"]
                                                                   withinRadius:8000]];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[defaults floatForKey:@"starLatitude"]
                                                                longitude:[defaults floatForKey:@"starLongitude"]
                                                                     zoom:13];
        mapView_ = [GMSMapView mapWithFrame:CGRectZero
                                     camera:camera];
        mapView_.myLocationEnabled = YES;
        mapView_.settings.compassButton = YES;
        mapView_.settings.myLocationButton = YES;
        mapView_.settings.scrollGestures = YES;
        mapView_.settings.zoomGestures = YES;
        mapView_.settings.rotateGestures = NO;
        mapView_.settings.tiltGestures = NO;
        
        self.view = mapView_;
        mapView_.delegate = self;
        if (currentSpots && [currentSpots count] > 0){
            [self drawMarkersOnMap: currentSpots];
        }
        else if (currentSpots && [currentSpots count] == 0){
            [BetterSpotsUtils showAlertInfoWithTitle: @"We are very sad 😢"
                                          andMessage: @"But we have no results for your current location"
                           inContextOfViewController: self];
        }
        else {
            [BetterSpotsUtils showAlertInfoWithTitle: @"We are very sad 😢"
                                          andMessage: @"But we can not fetch spots for you. Try again later."
                           inContextOfViewController: self];
        }
        [self stopLocationManager];
        // naive version, satisfy yourself with first result
        // better version will try getting better result for certain amount of time
        // and checking newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy

    }

    _lastLocationError = nil;
    _location = newLocation;
}

#pragma mark - user interactions with map

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSpotDetail"]) {
        NSLog(@"prepareForSegue in ViewController");
        UINavigationController *navigationController = segue.destinationViewController;
        SpotDetailsViewController *controller = (SpotDetailsViewController *)navigationController.topViewController;
                controller.dataModel = infoOfCurrentlySelectedSpot;

    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    infoOfCurrentlySelectedSpot = marker.userData;
    [self performSegueWithIdentifier:@"ShowSpotDetail" sender:self];
}


@end
