//
//  FavouritesSpotListViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 22.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//
#import "SpotDetailsViewController.h"
#import "FavouritesSpotListViewController.h"

#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface FavouritesSpotListViewController ()

@end

@implementation FavouritesSpotListViewController{
    MyManager *sharedManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sharedManager = [MyManager sharedManager];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) viewWillAppear:(BOOL)animated{
 // potrzebne żeby tableview się ogarnęło a nie próbowało być mądrzejsze niż jest (wyświetlanie złych spotów)
 // w sytuacji gdy usuwam elementy z ulubionych z innych miejsc niż tableview
 [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sharedManager.favouritesSpots count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavouritesSpot"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(SpotCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * favSpot  = [sharedManager.favouritesSpots objectAtIndex:indexPath.row];
    SpotCell *locationCell = (SpotCell *)cell;
    locationCell.spotNameLabel.text = [favSpot objectForKey:@"name"];
    locationCell.spotAddressLabel.text = [favSpot objectForKey:@"address_street"];
    locationCell.spotDistanceLabel.text =[SpotActions getFormattedDistanceWith:[favSpot[@"distance"]doubleValue]];
    
    if ([favSpot valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        [locationCell.spotThumbnail setImageWithURL:[NSURL URLWithString:favSpot[@"thumbnail_venue_photo"]]
                                   placeholderImage:nil
                        usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        locationCell.spotThumbnail.layer.cornerRadius = locationCell.spotThumbnail.bounds.size.width / 2.0f;
        locationCell.spotThumbnail.layer.borderWidth = 1;
        UIColor * allowanceColor = [UIColor colorWithHexString:@"#d72526"];
        if ([[favSpot valueForKey:@"is_enabled"] intValue] == 1){
            allowanceColor = [UIColor colorWithHexString:@"#3ab449"];
        }
        [locationCell.spotThumbnail.layer setBorderColor: allowanceColor.CGColor];
        locationCell.spotThumbnail.clipsToBounds = YES;
    }
    else {
        UIImage * img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-bad"] scaledToSize:CGSizeMake(150 ,150)];
        if ([[favSpot valueForKey:@"is_enabled"] intValue] == 1){
            img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-ok"] scaledToSize:CGSizeMake(150,150)];
        }
        [locationCell.spotThumbnail  setImage:img];
    }
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSpotDetailFromFavList"]) {
        SpotDetailsViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.dataModel = [sharedManager.favouritesSpots objectAtIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [sharedManager removeSpotWithPKfromFav:[sharedManager.favouritesSpots objectAtIndex:indexPath.row]];
    NSArray *indexPaths = @[indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
