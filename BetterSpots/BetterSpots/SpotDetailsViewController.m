//
//  SpotDetailsViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 11.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "SpotDetailsViewController.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>


@interface SpotDetailsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumnail;
@end

@implementation SpotDetailsViewController

@synthesize dataModel;


- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"anything happens here SpotDetailsViewController viewDidLoad");
    NSString * name = [self.dataModel objectForKey:@"name"];
    self.title = name;
    self.dateLabel.text = name;
    [self.thumnail setImage:[UIImage imageNamed:@"no_image_placeholder.png"]];
    if ([self.dataModel valueForKey: @"thumbnail_venue_photo"] != [NSNull null]) {
        [self.thumnail setImageWithURL:[NSURL URLWithString:[self.dataModel valueForKey: @"thumbnail_venue_photo"]] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    NSLog(@"prepareForSegue in  SpotDetailsVieController");
}


@end
