//
//  SpotListViewController.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#import "SpotCell.h"
#import "MyManager.h"
#import "SpotActions.h"
#import "BetterSpotsUtils.h"
#import "SpotDetailsViewController.h"


@interface SpotListViewController : UITableViewController
@property(strong, nonatomic) NSMutableArray* spots;
@end
