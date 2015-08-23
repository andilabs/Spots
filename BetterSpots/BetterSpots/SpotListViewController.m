//
//  SpotListViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotListViewController.h"
#import "SpotDetailsViewController.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface SpotListViewController ()

@end

@implementation SpotListViewController
@synthesize spots;

NSMutableDictionary * spot;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    MyManager *sharedManager = [MyManager sharedManager];
    spots = sharedManager.spots;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [spots count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Spot"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SpotCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    spot  = [spots objectAtIndex:indexPath.row];
    SpotCell *locationCell = (SpotCell *)cell;

    locationCell.spotNameLabel.text = [spot objectForKey:@"name"];
    locationCell.spotAddressLabel.text = [spot objectForKey:@"address_street"];
    locationCell.spotDistanceLabel.text =[SpotActions getFormattedDistanceWith:[spot[@"distance"]doubleValue]];

    if ([spot valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        [locationCell.spotThumbnail setImageWithURL:[NSURL URLWithString:spot[@"thumbnail_venue_photo"]]
                                   placeholderImage:nil
                        usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        [locationCell.spotThumbnail  setImage:nil];
    }
    locationCell.spotThumbnail.layer.cornerRadius = locationCell.spotThumbnail.bounds.size.width / 2.0f;
    locationCell.spotThumbnail.layer.borderWidth = 2;

    UIColor * allowanceColor = [UIColor colorWithHexString:@"#d72526"];
    if ([[spot valueForKey:@"is_enabled"] intValue] == 1){
        allowanceColor = [UIColor colorWithHexString:@"#3ab449"];
    }
    [locationCell.spotThumbnail.layer setBorderColor: allowanceColor.CGColor];
    locationCell.spotThumbnail.clipsToBounds = YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSpotDetailFromList"]) {
        SpotDetailsViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary * spot = [spots objectAtIndex:indexPath.row];
        controller.dataModel = spot;
    }
}


@end
