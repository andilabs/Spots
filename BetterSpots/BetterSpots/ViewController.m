//
//  ViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "ViewController.h"
@import AddressBook;

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
    NSMutableArray * currentSpots;
    UIActionSheet *markerActionsMenu;
    NSDictionary * infoOfCurrentlySelectedSpot;
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
    markerActionsMenu = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Call", @"Add as a Contact", @"Share...", @"Navigate me there...", nil];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    urlString = [infoDictionary objectForKey:SpotsEndpointURL];
    emojiString = [infoDictionary objectForKey:SpotsEmoji];
    appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    [self startLocationManager];
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
    // Dispose of any resources that can be recreated.
}


#pragma mark - utils

-(void)showAlertInfoWithTitle: (NSString *)title andMessage: (NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
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

- (void)makePhoneCall: (NSString *) phoneNumber {
    NSString *cleanedPhoneNumber = [[NSString alloc] initWithString: [NSString stringWithFormat:@"telprompt:%@",
                                                                      [phoneNumber stringByReplacingOccurrencesOfString:@" "
                                                                                                             withString:@""]]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cleanedPhoneNumber]];
}


#pragma mark - spots actions

- (void)addNewAddresBookContactWithContentOfTheSpot: (NSDictionary *) theSpotInfoDict {
    // create person record
    ABRecordRef person = ABPersonCreate();
    // set name and other string values
    NSString * venueName=[theSpotInfoDict valueForKey:@"name"];
    NSString * venuePhone=[[theSpotInfoDict valueForKey:@"phone_number"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * venueAddress1=[theSpotInfoDict valueForKey:@"address_street"];
    NSString * venueAddress2 =[theSpotInfoDict valueForKey:@"address_number"];
    NSString * venueCity=[theSpotInfoDict valueForKey:@"address_city"];
    NSString * venueCountry=[theSpotInfoDict valueForKey:@"address_country"];
    NSString * venueUrl = [theSpotInfoDict valueForKey:@"www"];
    NSString * venueFacebook = [theSpotInfoDict valueForKey:@"facebook"];
    ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFStringRef) venueName, NULL);
    // url
    if (venueUrl)
    {
        ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(urlMultiValue, (__bridge CFStringRef) venueUrl, kABPersonHomePageLabel, NULL);
        ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, nil);
        CFRelease(urlMultiValue);
    }
    // facebook
    if (venueFacebook)
    {
        ABMultiValueRef multiSocial = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        ABMultiValueAddValueAndLabel(multiSocial, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey, venueFacebook, kABPersonSocialProfileUsernameKey,nil]), kABPersonSocialProfileServiceFacebook, NULL);
        ABRecordSetValue(person, kABPersonSocialProfileProperty, multiSocial, NULL);
        CFRelease(multiSocial);
    }
    // phone
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
    // let's show view controller
    ABUnknownPersonViewController *controller = [[ABUnknownPersonViewController alloc] init];
    controller.displayedPerson = person;
    controller.allowsAddingToAddressBook = YES;
    // current view must have a navigation controller
    [self.navigationController pushViewController:controller animated:YES];
    UIImage *img = [UIImage imageNamed:@"marker-bad-kopia.png"];
    if ([[theSpotInfoDict valueForKey:@"is_enabled"] intValue] == 1){
        img = [UIImage imageNamed:@"marker-ok-kopia.png"];
    }


    NSData *dataRef = UIImagePNGRepresentation(img);
    ABPersonSetImageData(person, (__bridge CFDataRef)dataRef, nil);
    CFRelease(person);
}

- (void)navigateUserToTheSpot: (NSDictionary *) theSpotInfoDict {
    double lat = [theSpotInfoDict[@"location"][@"latitude"] doubleValue];
    double lng = [theSpotInfoDict[@"location"][@"longitude"] doubleValue];
    NSDictionary *addressDict = @{
                                  (NSString *) kABPersonAddressStreetKey : [theSpotInfoDict valueForKey:@"address_street"],
                                  (NSString *) kABPersonAddressCityKey : [theSpotInfoDict valueForKey:@"address_city"],
                                  (NSString *) kABPersonAddressCountryCodeKey : [theSpotInfoDict valueForKey:@"address_country"]
                                  };
    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(lat, lng);
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:addressDict];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}

- (void)shareTheSpot: (NSDictionary *) theSpotInfoDict
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    NSString *positiveAdjective = @"";
    if ([[theSpotInfoDict valueForKey:@"is_enabled"] intValue] == 1){
        positiveAdjective = @"cool";
    }
    NSString * composeMessage = [NSString stringWithFormat:@"Hi! I found %@ spot using #%@ Check it out!",
                                 positiveAdjective,
                                 appName];
    [sharingItems addObject:composeMessage];
    [sharingItems addObject:[NSURL URLWithString:[theSpotInfoDict valueForKey: @"www_url"]]];

    if ([theSpotInfoDict valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[theSpotInfoDict valueForKey: @"thumbnail_venue_photo"]]]];
        [sharingItems addObject:image];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}


#pragma mark - fetching markers, drawing markers
-(NSMutableArray*)getNearbylSpotsWithLat:(float)lat andLon:(float)lon withinRadius:(int)radius
{
    NSString * locaticonBasedUrl =[NSString stringWithFormat: @"%@nearby/%.5f/%.5f/%.d",
                                   urlString,
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
                    spotMarker.icon = [self imageWithImage:[UIImage imageNamed:@"marker-bad-kopia"]
                                              scaledToSize:CGSizeMake(25, 25)];
                    break;
                case 1:
                    spotMarker.icon = [self imageWithImage:[UIImage imageNamed:@"marker-ok-kopia"]
                                              scaledToSize:CGSizeMake(25, 25)];
                    break;
            }
            int ratingValue = roundf([spot[@"friendly_rate"]floatValue]);
            if (ratingValue < 0){
                ratingValue = 0;
            }
            spotMarker.snippet = [NSString stringWithFormat:@"%@ %@\n%@\n\n%.0f meters away.",
                                  spot[@"address_street"],
                                  spot[@"address_number"],
                                  [@"" stringByPaddingToLength:[@"⭐️" length]*ratingValue
                                                    withString: @"⭐️" startingAtIndex:0],
                                  [spot[@"distance"]doubleValue]*1000];
            spotMarker.map = mapView_;
            
        }
    }
}


#pragma mark - geolocation stuff

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
                [self showAlertInfoWithTitle: @"We are very sad 😢" andMessage: @"But we can not geolocate you. Try again later."];
                break;
            }
        }
    } else {
        [self showAlertInfoWithTitle: @"We are very sad 😢" andMessage: @"But we can not geolocate you. Try again later."];
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
            [self showAlertInfoWithTitle: @"We are very sad 😢" andMessage: @"But we have no results for your current location"];
        }
        else {
            [self showAlertInfoWithTitle: @"We are very sad 😢" andMessage: @"But we can not fetch spots for you. Try again later."];
        }
        [self stopLocationManager]; // naive version, satisfy yourself with first result
        
//       better version will try getting better result for certain amount of time
//        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy){
//            [self stopLocationManager];
//        }

    }

    _lastLocationError = nil;
    _location = newLocation;
}

#pragma mark - user interactions with map



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * what_action = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([what_action isEqualToString:@"Call"])
    {
        [self makePhoneCall:[infoOfCurrentlySelectedSpot valueForKey:@"phone_number"]];
    }
    else if([what_action isEqualToString:@"Add as a Contact"]){
        [self addNewAddresBookContactWithContentOfTheSpot: infoOfCurrentlySelectedSpot];
    }
    else if([what_action isEqualToString:@"Share..."]){
        [self shareTheSpot: infoOfCurrentlySelectedSpot];
    }
    else if([what_action isEqualToString:@"Navigate me there..."]){
        [self navigateUserToTheSpot: infoOfCurrentlySelectedSpot];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    infoOfCurrentlySelectedSpot = marker.userData;
    [markerActionsMenu showInView:mapView_];
}

@end
