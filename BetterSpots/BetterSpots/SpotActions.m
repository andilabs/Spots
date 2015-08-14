//
//  SpotActions.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotActions.h"
@import AddressBook;

@implementation SpotActions
#pragma mark - spots actions

+ (void)addNewAddresBookContactWithContentOfTheSpot: (NSDictionary *) theSpotInfoDict inContextOfViewController: (UIViewController *) uiViewController {
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
    [uiViewController.navigationController pushViewController:controller animated:YES];
    UIImage *img = [UIImage imageNamed:@"marker-bad-kopia.png"];
    if ([[theSpotInfoDict valueForKey:@"is_enabled"] intValue] == 1){
        img = [UIImage imageNamed:@"marker-ok-kopia.png"];
    }
    
    
    NSData *dataRef = UIImagePNGRepresentation(img);
    ABPersonSetImageData(person, (__bridge CFDataRef)dataRef, nil);
    CFRelease(person);
}

+ (void)navigateUserToTheSpot: (NSDictionary *) theSpotInfoDict {
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

+ (void)shareTheSpot: (NSDictionary *) theSpotInfoDict inContextOfViewController: (UIViewController *) uiViewController forAppName: (NSString *)appName withImage:(UIImage *)image
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
    if (image) {
        [sharingItems addObject:image];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [uiViewController presentViewController:activityController animated:YES completion:nil];
}

@end
