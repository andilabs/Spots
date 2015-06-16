//
//  ViewController.h
//  DogspotEU
//
//  Created by Andrzej Kostański on 08.06.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const SpotsEndpointURL;

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@end

