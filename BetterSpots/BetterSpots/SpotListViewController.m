//
//  SpotListViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotListViewController.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface SpotListViewController ()

@end

@implementation SpotListViewController
@synthesize spots;


- (void)viewDidLoad {
    
    MyManager *sharedManager = [MyManager sharedManager];
    spots = sharedManager.spots;
    NSLog(@"%@",spots);
    [super viewDidLoad];
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
    return [self.spots count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Spot"];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SpotCell *locationCell = (SpotCell *)cell;
    NSDictionary *spot = [spots objectAtIndex:indexPath.row];
    
    locationCell.spotNameLabel.text = [spot objectForKey:@"name"];

    locationCell.spotAddressLabel.text = [spot objectForKey:@"address_street"];
    locationCell.spotDistanceLabel.text =[SpotActions getFormattedDistanceWith:[spot[@"distance"]doubleValue]];

    if ([spot valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        
        [locationCell.spotThumbnail setImageWithURL:[NSURL URLWithString:spot[@"thumbnail_venue_photo"]]
                  placeholderImage:nil
       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        locationCell.spotThumbnail.layer.cornerRadius = locationCell.spotThumbnail.bounds.size.width / 2.0f;
        locationCell.spotThumbnail.clipsToBounds = YES;
    }
    else {
        UIImage * img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-bad"] scaledToSize:CGSizeMake(150 ,150)];
        if ([[spot valueForKey:@"is_enabled"] intValue] == 1){
            img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-ok"] scaledToSize:CGSizeMake(150,150)];
        }
        [locationCell.spotThumbnail  setImage:img];
    }
    
//    if (image == nil) {
//        image = [UIImage imageNamed:@"No Photo"];
//    }
    
//

    
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

@end
