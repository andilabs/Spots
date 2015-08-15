//
//  SpotDetailsViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 11.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//


#import "SpotDetailsViewController.h"
#import "InAppWebViewController.h"
#import "SpotDetailsMapViewController.h"
#import "BetterSpotsUtils.h"
#import "SpotActions.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>


@interface SpotDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *spotThumbnailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotAddressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotPhoneNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotFacebookCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotWebpageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spotEmailCell;

@property (weak, nonatomic) IBOutlet UILabel *spotPhoneIcon;
@property (weak, nonatomic) IBOutlet UILabel *spotFacebookIcon;
@property (weak, nonatomic) IBOutlet UILabel *spotWebpageIcon;
@property (weak, nonatomic) IBOutlet UILabel *spotEmailIcon;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *enablenceIcon;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookFanpageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *webpageLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *facilitiesLabel;


@end

@implementation SpotDetailsViewController{
    GMSMapView * mapViewAsCellBackground;
}
@synthesize dataModel;


- (IBAction)shareSpot:(id)sender{
    [SpotActions shareTheSpot: self.dataModel inContextOfViewController: self forAppName: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] withImage: ((UIImageView*)self.spotThumbnailCell.backgroundView).image];
    NSLog(@"somebody wants share something");
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section %ld row %ld", (long)indexPath.section, (long)indexPath.row);
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        NSLog(@"go to spotMapDetailView !");
//        /[self performSegueWithIdentifier:@"ShowSpotDetailMap" sender:self];
    }
    if (indexPath.section == 0 && indexPath.row == 4)
    {
        [BetterSpotsUtils makePhoneCall:[self.dataModel valueForKey:@"phone_number"]];
    }
    if (indexPath.section == 0 && indexPath.row == 8)
    {
        [SpotActions  addNewAddresBookContactWithContentOfTheSpot: self.dataModel inContextOfViewController:self];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.facilitiesLabel.text = @"\u2022 fresh water served\n\u2022 snacks for dogs\n\u2022 dedicated dogs menu";
    
    // this lines removes empty header above first tableview section
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    //set title of detail view in navigation bar
    self.title = self.dataModel[@"name"];
    
    //set name of spot
    self.nameLabel.text = self.dataModel[@"name"];
    
    //set thumbnail
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    if ([self.dataModel valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        [imageView setImageWithURL:[NSURL URLWithString:self.dataModel[@"thumbnail_venue_photo"]]
                  placeholderImage:nil
       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
       self.spotThumbnailCell.backgroundView = imageView;
    }
    
    // set allowance icon
    UIImage * img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-bad"] scaledToSize:CGSizeMake(150 ,150)];
    if ([[self.dataModel valueForKey:@"is_enabled"] intValue] == 1){
        img = [BetterSpotsUtils imageWithImage:[UIImage imageNamed:@"marker-ok"] scaledToSize:CGSizeMake(150,150)];
    }
    [self.enablenceIcon setImage:img];

    // set address
    NSString * address = [[NSString alloc]  initWithString: [NSString stringWithFormat:@"%@ %@\n%@, %@",
                                                             [self.dataModel objectForKey:@"address_street"],
                                                             [self.dataModel objectForKey:@"address_number"],
                                                             [self.dataModel objectForKey:@"address_city"],
                                                             [self.dataModel objectForKey:@"address_country"]]];
    self.addressLabel.text = address;
    
    // set contact details row if values recived from API
    if (![self.dataModel[@"phone_number"]  isEqual: @""]) {
        self.phoneLabel.text = self.dataModel[@"phone_number"];
        self.spotPhoneIcon.text = [NSString stringWithFormat:@"%C", 0xf095];
    }
    if (![self.dataModel[@"www"]  isEqual: @""]) {
        self.webpageLabel.text = self.dataModel[@"www"];
        self.spotWebpageIcon.text = [NSString stringWithFormat:@"%C", 0xf0ac];
    }
    
    if (![self.dataModel[@"facebook"]  isEqual: @""]) {
        self.facebookFanpageNameLabel.text = [NSString stringWithFormat:@"/%@", self.dataModel[@"facebook"]];
        self.spotFacebookIcon.text = [NSString stringWithFormat:@"%C", 0xf09a];
    }

    if (![self.dataModel[@"email"]  isEqual: @""]) {
        self.emailLabel.text = self.dataModel[@"email"];
        self.spotEmailIcon.text = [NSString stringWithFormat:@"%C", 0xf003];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (cell == self.spotPhoneNumberCell && [self.dataModel[@"phone_number"]  isEqual: @""]){
        return 0;
    }
    if (cell == self.spotFacebookCell && [self.dataModel[@"facebook"]  isEqual: @""]){
        return 0;
    }
    if (cell == self.spotWebpageCell && [self.dataModel[@"www"]  isEqual: @""]){
        return 0;
    }
    if (cell == self.spotEmailCell && [self.dataModel[@"email"] isEqual: @""]){
        return 0;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSpotDetailMap"]) {
        NSLog(@"prepareForSegue in SpotDetailsViewController");
        UINavigationController *navigationController = segue.destinationViewController;
        SpotDetailsMapViewController *controller = (SpotDetailsMapViewController *)navigationController.topViewController;
        controller.dataModel = self.dataModel;
    }
    
    if ([segue.identifier isEqualToString:@"showWebViewForUrl"]) {
        NSLog(@"prepareForSegue in SpotDetailsViewController");
        UINavigationController *navigationController = segue.destinationViewController;
        InAppWebViewController *controller = (InAppWebViewController *)navigationController.topViewController;
        controller.dataModel = self.dataModel;
    }


}

@end
