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
@interface SpotDetailsViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property(weak, nonatomic)  NSDictionary* dataModel;
@end
