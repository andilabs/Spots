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
@synthesize filteredSpots;
@synthesize spotsSearchBar;

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
    
    // Don't show the scope bar or cancel button until editing begins
    [spotsSearchBar setShowsScopeBar:NO];
    [spotsSearchBar sizeToFit];
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + spotsSearchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
    filteredSpots = [NSMutableArray arrayWithCapacity:[spots count]];
    
    // Reload the table
    [[self tableView] reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredSpots count];
    }
    else
    {
        return [spots count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Spot"];
    [self configureCell:cell atIndexPath:indexPath withinTableView:tableView];
    
    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withinTableView: (UITableView*)tableView
{
    SpotCell *locationCell = (SpotCell *)cell;
//    NSDictionary *spot = [spots objectAtIndex:indexPath.row];
  
    NSDictionary * spot = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
       spot = [filteredSpots objectAtIndex:indexPath.row];
    }
    else
    {
        spot  = [spots objectAtIndex:indexPath.row];
    }
    
    locationCell.spotNameLabel.text = [spot objectForKey:@"name"];

    locationCell.spotAddressLabel.text = [spot objectForKey:@"address_street"];
    locationCell.spotDistanceLabel.text =[SpotActions getFormattedDistanceWith:[spot[@"distance"]doubleValue]];

    if ([spot valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        
        [locationCell.spotThumbnail setImageWithURL:[NSURL URLWithString:spot[@"thumbnail_venue_photo"]]
                  placeholderImage:nil
       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        locationCell.spotThumbnail.layer.cornerRadius = locationCell.spotThumbnail.bounds.size.width / 2.0f;
        locationCell.spotThumbnail.layer.borderWidth = 1;
        UIColor * allowanceColor = [UIColor colorWithHexString:@"#d72526"];
        NSLog(@"%d", [[spot valueForKey:@"is_enabled"] intValue]);
        if ([[spot valueForKey:@"is_enabled"] intValue] == 1){
            allowanceColor = [UIColor colorWithHexString:@"#3ab449"];
        }
        [locationCell.spotThumbnail.layer setBorderColor: allowanceColor.CGColor];
        locationCell.spotThumbnail.clipsToBounds = YES;
    }
    else {
        UIImage * img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-bad"] scaledToSize:CGSizeMake(150 ,150)];
        if ([[spot valueForKey:@"is_enabled"] intValue] == 1){
            img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-ok"] scaledToSize:CGSizeMake(150,150)];
           
        }
        [locationCell.spotThumbnail  setImage:img];
        
    }
    
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSpotDetailFromList"]) {
        NSLog(@"prepareForSegue in SpotDetailsViewController");

        SpotDetailsViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary * spot = [spots objectAtIndex:indexPath.row];
        NSLog(@"spot %@", spot);
        controller.dataModel = spot;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    
    // Remove all objects from the filtered search array
    [self.filteredSpots removeAllObjects];
    
    // Filter the array using NSPredicate
    NSLog(@"%@", searchText);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( name == %@)",searchText];
    NSArray *tempArray = [spots filteredArrayUsingPredicate:predicate];
    
//    if(![scope isEqualToString:@"All"]) {
//        // Further filter the array with the scope
//        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
//        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
//    }
    
    filteredSpots = [NSMutableArray arrayWithArray:tempArray];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"%@", searchString);
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}

#pragma mark - Search Button

- (IBAction)goToSearch:(id)sender
{
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // Note that if you didn't hide your search bar, you should probably not include this, as it would be redundant
    [spotsSearchBar becomeFirstResponder];
}

@end
