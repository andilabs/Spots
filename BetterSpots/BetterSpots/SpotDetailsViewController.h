//
//  SpotDetailsViewController.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 11.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#import "SpotDetailsMapViewController.h"
#import "BetterSpotsUtils.h"
#import "SpotActions.h"
#import "SVWebViewController.h"
#import "MyManager.h"

@interface SpotDetailsViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property(weak, nonatomic)  NSDictionary* dataModel;
@end

