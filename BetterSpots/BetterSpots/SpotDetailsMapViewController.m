//
//  SpotDetailsMapViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotDetailsMapViewController.h"


@interface SpotDetailsMapViewController ()

@end


@implementation SpotDetailsMapViewController
@synthesize dataModel;

- (IBAction)getDirectionsToSpot:(id)sender {
    [SpotActions navigateUserToTheSpot: self.dataModel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [SpotActions getFormattedDistanceWith:[dataModel[@"distance"]doubleValue]];
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
