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
    GMSMapView *mapView_;
    CLLocationManager *_locationManager;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLLocation *_location;
    NSString *emojiString;
    NSString *appName;
    NSString *urlString;
    NSUserDefaults *defaults;
    NSMutableArray * currentMarkers;
    UIActionSheet *takieMenu;
    NSDictionary * infoOfCurrentlySelectedSpot;
}

-(NSMutableArray*)getLocalMarkers: (float)lat andLon: (float) lon withRadius: (int) radius
{
    NSString * locaticonBasedUrl =[NSString stringWithFormat: @"%@nearby/%.5f/%.5f/%.d",
                                   urlString,
                                   lat,
                                   lon,
                                   radius];
    NSLog(@"ADDRESS IN USE IS: %@",locaticonBasedUrl);
    NSURL * myUrl = [NSURL URLWithString:locaticonBasedUrl];
    NSData *data = [NSData dataWithContentsOfURL:myUrl];
    NSError * myErr;
    NSMutableArray *localMarkers= [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&myErr];
    NSLog(@"markers: %@", localMarkers);
    return localMarkers;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)drawMarkersOnMap:(NSMutableArray*)acctual
{
    if ([acctual count] > 0){
        for (NSDictionary * marker in acctual){
            
            GMSMarker *spotMarker = [[GMSMarker alloc] init];
            spotMarker.title = marker[@"name"];
            spotMarker.position = CLLocationCoordinate2DMake([marker[@"location"][@"latitude"] doubleValue], [marker[@"location"][@"longitude"]doubleValue]);
            spotMarker.userData = marker;
            
            
            switch ([marker[@"is_enabled"] intValue]){
                case 0:
                    spotMarker.icon = [self imageWithImage:[UIImage imageNamed:@"marker-bad-kopia"]
                                              scaledToSize:CGSizeMake(25, 25)];
                    break;
                case 1:
                    spotMarker.icon = [self imageWithImage:[UIImage imageNamed:@"marker-ok-kopia"]
                                              scaledToSize:CGSizeMake(25, 25)];
                    break;
            }
            
            int ratingValue = roundf([marker[@"friendly_rate"]floatValue]);
            if (ratingValue < 0){
                ratingValue = 0;
            }
            spotMarker.snippet = [NSString stringWithFormat:@"%@ %@\n%@\n\n%.0f meters away.",
                                  marker[@"address_street"],
                                  marker[@"address_number"],
                                  [@"" stringByPaddingToLength:[@"⭐️" length]*ratingValue
                                                    withString: @"⭐️" startingAtIndex:0],
                                  [marker[@"distance"]doubleValue]*1000
                                  ];
            spotMarker.map = mapView_;
            
        }
    }
    else{
        NSLog(@"No results for such location");
    }
}

-(void)promptUserAboutGeolocationDisabled{
    NSString * geoDisabledWarrning = [NSString  stringWithFormat:
                                      @"We ♥️%@, but we can not search spots for you, because geolocation is disabled.\n\n Please go to Settings>%@ and enable geo location",
                                      emojiString,
                                      appName];
    
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])){
        defaults = [NSUserDefaults standardUserDefaults];
        _locationManager = [[CLLocationManager alloc] init];

    }
    return self;
}

- (void)viewDidLoad {
    takieMenu = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Call",@"Add as a Contact",@"Show details...",nil];
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
 
        
//        NSLog(@"obj for key: starLatitude, starLongitude: %@, %@",
//              [defaults objectForKey:@"starLatitude"],
//              [defaults objectForKey:@"starLongitude"]);
//        
        
        currentMarkers = [NSMutableArray arrayWithArray:[self getLocalMarkers: [defaults floatForKey:@"starLatitude"]
                                                                       andLon: [defaults floatForKey:@"starLongitude"]
                                                                   withRadius: 8000]];
        
//        NSLog(@"%@", currentMarkers);
        
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * what_action = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"The %@ button was tapped.", what_action);
    if ([what_action isEqualToString:@"Call"])
    {
        NSString *phoneNumber = [[NSString alloc]
                                 initWithString:
                                 
                                 [NSString stringWithFormat:@"telprompt:%@",[[infoOfCurrentlySelectedSpot valueForKey:@"phone_number"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        NSLog(@"I am calling %@", phoneNumber);
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:phoneNumber]];
        
    }
    else if([what_action isEqualToString:@"Add as a Contact"]){
        // create person record
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                NSLog(@"Just denied");
                return;
            }
            //5
            ABRecordRef person = ABPersonCreate();
            
            // set name and other string values
            NSString * venueName=[infoOfCurrentlySelectedSpot valueForKey:@"name"];
            NSString * venuePhone=[[infoOfCurrentlySelectedSpot valueForKey:@"phone_number"] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString * venueAddress1=[infoOfCurrentlySelectedSpot valueForKey:@"address_street"];
            NSString * venueAddress2 =[infoOfCurrentlySelectedSpot valueForKey:@"address_number"];
            NSString * venueCity=[infoOfCurrentlySelectedSpot valueForKey:@"address_city"];
            NSString * venueCountry=[infoOfCurrentlySelectedSpot valueForKey:@"address_country"];
            NSString * venueUrl = [infoOfCurrentlySelectedSpot valueForKey:@"www"];
            
            
            ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFStringRef) venueName, NULL);
            
            if (venueUrl)
            {
                ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(urlMultiValue, (__bridge CFStringRef) venueUrl, kABPersonHomePageLabel, NULL);
                ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, nil);
                CFRelease(urlMultiValue);
            }
            
            if (venuePhone)
            {
                ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                NSArray *venuePhoneNumbers = [venuePhone componentsSeparatedByString:@" or "];
                for (NSString *venuePhoneNumberString in venuePhoneNumbers)
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFStringRef) venuePhoneNumberString, kABPersonPhoneMainLabel, NULL);
                ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
                CFRelease(phoneNumberMultiValue);
            }
            
            // add address
            
            ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            
            if (venueAddress1)
            {
                if (venueAddress2)
                    addressDictionary[(NSString *) kABPersonAddressStreetKey] = [NSString stringWithFormat:@"%@\n%@", venueAddress1, venueAddress2];
                else
                    addressDictionary[(NSString *) kABPersonAddressStreetKey] = venueAddress1;
            }
            if (venueCity)
                addressDictionary[(NSString *)kABPersonAddressCityKey] = venueCity;
            if (venueCountry)
                addressDictionary[(NSString *)kABPersonAddressCountryKey] = venueCountry;
            
            ABMultiValueAddValueAndLabel(multiAddress, (__bridge CFDictionaryRef) addressDictionary, kABWorkLabel, NULL);
            ABRecordSetValue(person, kABPersonAddressProperty, multiAddress, NULL);
            CFRelease(multiAddress);
            NSLog(@"we are here adding contact");
            // let's show view controller
            
            ABUnknownPersonViewController *controller = [[ABUnknownPersonViewController alloc] init];
            
            controller.displayedPerson = person;
            controller.allowsAddingToAddressBook = YES;
            
            // current view must have a navigation controller
            
            [self.navigationController pushViewController:controller animated:YES];
            
            CFRelease(person);
        });
        
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"Tapped was %@",[marker.userData valueForKey:@"name"]);
    infoOfCurrentlySelectedSpot = marker.userData;
    [takieMenu showInView:mapView_];
}




@end
