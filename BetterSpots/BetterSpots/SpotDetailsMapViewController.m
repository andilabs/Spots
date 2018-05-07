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


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    
    //coordinates for the place we want to display
    if (buttonIndex==0) {
        [SpotActions navigateUserToTheSpot: self.dataModel];
    } else if (buttonIndex==1) {
        double latitude = [self.dataModel[@"location"][@"latitude"] doubleValue];
        double longitude = [self.dataModel[@"location"][@"longitude"] doubleValue];

        //Google Maps native
        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps://"]]) {
            NSURL *gMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%.6f,%.6f&center=%.6f,%.6f&zoom=15&views=traffic", latitude, longitude, latitude, longitude]];
            [[UIApplication sharedApplication] openURL: gMapsUrl];
        } else {
        // Google Maps web
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?&z=15&q=%.6f+%.6f&ll=%.6f+%.6f", latitude, longitude, latitude, longitude]]];
    }
    }
}

- (IBAction)getDirectionsToSpot:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",@"Google Maps", nil];
    [sheet showInView:self.view];
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
