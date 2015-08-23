//
//  SpotListViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotListViewController.h"


@interface SpotListViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>

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
    [BetterSpotsUtils setUpColorsForNavigationViewController:self.navigationController];
    self.navigationItem.title = @"Nearby";
    MyManager *sharedManager = [MyManager sharedManager];
    spots = sharedManager.spots;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView){
        return [spots count];
    }
    else {
        return [self.filteredSpots count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Spot"];
    [self configureCell:cell atIndexPath:indexPath withTableView: tableView];
    return cell;
}

- (void)configureCell:(SpotCell *)cell atIndexPath:(NSIndexPath *)indexPath withTableView: (UITableView *)tableView
{
    if (tableView == self.tableView) {
        spot  = [spots objectAtIndex:indexPath.row];
    }
    else {
        spot = [self.filteredSpots objectAtIndex:indexPath.row];
    }
    
    
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
    locationCell.spotThumbnail.layer.borderWidth = 1.5;

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
        NSDictionary * spot = nil;
        if (self.searchDisplayController.isActive){
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
            spot = [self.filteredSpots objectAtIndex:indexPath.row];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            spot = [spots objectAtIndex:indexPath.row];
        }
        SpotDetailsViewController *controller = segue.destinationViewController;
        controller.dataModel = spot;
    }
}

#pragma mark - searching / filtering

- (void)searchForText:(NSString *)searchText scope: (int)scopeOption {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( name CONTAINS[cd] %@)",searchText];
    
    self.filteredSpots = [spots filteredArrayUsingPredicate:predicate];

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    // here grep from controller.searchBar.selectedScopeButtonIndex -> spot type [cafe, rest etc..]
    [self searchForText:searchString scope:1];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // here grep from searchOption -> spot type [cafe, rest etc..]
    NSString * searchString = controller.searchBar.text;
    [self searchForText:searchString scope:1];
    return YES;
}
- (void) searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 78;
}

- (void)didReceiveMemoryWarning {
    self.filteredSpots = nil;
    [super didReceiveMemoryWarning];
}
@end
