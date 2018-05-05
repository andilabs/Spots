//
//  SpotDetailsMapViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotDetailsMapViewController.h"
#import "AppDelegate.h"

@interface SpotDetailsMapViewController ()

@end


@implementation SpotDetailsMapViewController{
    CLLocation * _currentLocation;
}
@synthesize dataModel;


//-(void)openActionSheet:(id)sender {
//    //give the user a choice of Apple or Google Maps
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",@"Google Maps", nil];
//    [sheet showInView:self.view];
//}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    double latitude = [self.dataModel[@"location"][@"latitude"] doubleValue];
    double longitude = [self.dataModel[@"location"][@"longitude"] doubleValue];
    
    //coordinates for the place we want to display
    CLLocationCoordinate2D rdOfficeLocation = CLLocationCoordinate2DMake(31.20691,121.477847);
    if (buttonIndex==0) {
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:rdOfficeLocation addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = @"ReignDesign Office";
        [item openInMapsWithLaunchOptions:nil];
    } else if (buttonIndex==1) {
        //Google Maps
        if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:@"comgooglemaps://"]]) {
            NSLog(@"YES WE CAN");
            
            NSURL *gMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%.6f,%.6f&center=%.6f,%.6f&zoom=15&views=traffic", latitude, longitude, latitude, longitude]];
            [[UIApplication sharedApplication] openURL: gMapsUrl];
        } else {
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?&z=15&q=%.6f+%.6f&ll=%.6f+%.6f", latitude, longitude, latitude, longitude]]];
    }
    }
}

- (IBAction)getDirectionsToSpot:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",@"Google Maps", nil];
    [sheet showInView:self.view];
//    [SpotActions navigateUserToTheSpot: self.dataModel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [SpotActions getFormattedDistanceWith:[dataModel[@"distance"]doubleValue]];

    CLLocation * spotLocation = [[CLLocation alloc] initWithLatitude:[dataModel[@"location"][@"latitude"] doubleValue] longitude:[dataModel[@"location"][@"longitude"] doubleValue]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    
    int dist = [SpotActions getDistanceInMetersFrom:spotLocation to:_currentLocation];
    self.title =[SpotActions getFormattedDistanceWith:dist/1000.0];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.dataModel[@"location"][@"latitude"] doubleValue]
                                                            longitude:[self.dataModel[@"location"][@"longitude"]doubleValue]
                                                                 zoom:17];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
    self.view = mapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
