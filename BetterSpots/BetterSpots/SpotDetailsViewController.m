//
//  SpotDetailsViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 11.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//


#import "SpotDetailsViewController.h"
#import "SVWebViewController.h"
#import "MyManager.h"

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
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIButton *favouritesAddRemoveButton;



@end

@implementation SpotDetailsViewController{
    GMSMapView * mapViewAsCellBackground;
    MyManager * sharedManager;
}
@synthesize dataModel;


- (IBAction)shareSpot:(id)sender{
    [SpotActions shareTheSpot: self.dataModel inContextOf: self forAppName: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] withImage: ((UIImageView*)self.spotThumbnailCell.backgroundView).image];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // call
    if (indexPath.section == 0 && indexPath.row == 4)
    {
        [BetterSpotsUtils makePhoneCall:[self.dataModel valueForKey:@"phone_number"]];
    }

    // open facebook url in vebview
    if (indexPath.section == 0 && indexPath.row == 5)
    {
        NSURL *URL = [NSURL URLWithString: [NSString stringWithFormat:@"http://facebook.com/%@", self.dataModel[@"facebook"]]];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        
        // make background color of navigation bar with spot default color
        webViewController.navigationBar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
        // make fonts on navigation bar white
        webViewController.navigationBar.barStyle = UIBarStyleBlack;
        webViewController.navigationBar.tintColor = [UIColor whiteColor];
        webViewController.toolbar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
   
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        
    }
    
    // open www  url in vebview
    if (indexPath.section == 0 && indexPath.row == 6)
    {
        NSURL *URL = [NSURL URLWithString:self.dataModel[@"www"]];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        
        // make background color of navigation bar with spot default color
        webViewController.navigationBar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
        // make fonts on navigation bar white
        webViewController.navigationBar.barStyle = UIBarStyleBlack;
        webViewController.navigationBar.tintColor = [UIColor whiteColor];
        
        webViewController.navigationBar.backgroundColor = [UIColor whiteColor];
        webViewController.navigationBar.tintColor = [UIColor whiteColor];
        webViewController.navigationBar.translucent = NO;
        
        
//        webViewController.toolbar.barStyle = UIBarStyleBlack;
        webViewController.toolbar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
        webViewController.toolbar.tintColor = [UIColor whiteColor];

        [self presentViewController:webViewController animated:YES completion:NULL];
        
    }
    
    // send email
    if (indexPath.section == 0 && indexPath.row == 7)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            [mail setToRecipients:@[self.dataModel[@"email"]]];
            [self presentViewController:mail animated:YES completion:NULL];
        }
        else
        {
            [BetterSpotsUtils showAlertInfoWithTitle: @"We are very sad 😢"
                                          andMessage: @"But you have not configured email client"
                                         inContextOf: self];
        }
    }

    // add new contact to addressbook
    if (indexPath.section == 0 && indexPath.row == 8)
    {
        [SpotActions  addNewAddresBookContactWithContentOfTheSpot: self.dataModel inContextOfViewController:self];
    }
    
    // add to OR remove from favourites

    if (indexPath.section == 0 && indexPath.row == 9)
    {
        if ([sharedManager.favouritesSpots containsObject:self.dataModel]){
            [sharedManager removeSpotFromFavourites:self.dataModel];

//            [sharedManager removeSpotWithPKfromFav:[[self.dataModel valueForKey:@"pk"] intValue]];
            [self.favouritesAddRemoveButton setTitle:@"Add to favourites" forState:UIControlStateNormal];
            self.favouritesAddRemoveButton.tintColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        }
        else {
            [sharedManager addSpotToFav:self.dataModel];
            [self.favouritesAddRemoveButton setTitle:@"Remove from favourites" forState:UIControlStateNormal];
            self.favouritesAddRemoveButton.tintColor = [UIColor redColor];

        }
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    sharedManager = [MyManager sharedManager];

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
    
    //set ratings
    self.ratingLabel.text = [SpotActions getFAStarsFormattedRating:[self.dataModel[@"friendly_rate"]doubleValue]];
    
    // set facilities
    NSMutableString * facilitiesListing = [[NSMutableString alloc]initWithString:@""];
    for (NSString * facility in [BetterSpotsUtils getSpotsFacilities]){
        [facilitiesListing appendString:[NSString stringWithFormat:@"\u2022 %@\n", facility]];
    }
    self.facilitiesLabel.text = facilitiesListing;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.facilitiesLabel.attributedText];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"#D8D8D8"]
                 range:NSMakeRange(0, [self.facilitiesLabel.text length])];
    
    for (NSString* facility in self.dataModel[@"facilities"]) {
        if ([self.dataModel[@"facilities"][facility] boolValue]){
            [text addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithHexString:@"#3fb350"]
                         range:[self.facilitiesLabel.text rangeOfString: facility]];
        }
    }
    [self.facilitiesLabel setAttributedText: text];

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
    
    // configure layout of AddRemoveButton
    if ([sharedManager.favouritesSpots containsObject:self.dataModel]){
        [self.favouritesAddRemoveButton setTitle:@"Remove from favourites" forState:UIControlStateNormal];
        self.favouritesAddRemoveButton.tintColor = [UIColor redColor];
//
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// Hide table cells for which we dont have data by setting its height to 0
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (cell == self.spotThumbnailCell && [self.dataModel valueForKey: @"thumbnail_venue_photo"] == [NSNull null]) {
        return 0;
    }
    
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
        UINavigationController *navigationController = segue.destinationViewController;
        SpotDetailsMapViewController *controller = (SpotDetailsMapViewController *)navigationController.topViewController;
        controller.dataModel = self.dataModel;
    }
}

@end
