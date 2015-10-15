//
//  RadiusSettingsViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 03.10.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "RadiusSettingsViewController.h"

@interface RadiusSettingsViewController (){
    NSMutableArray * _pickerDataWhole;
    NSMutableArray * _pickerDataParts;
    NSArray * _pickerDataUnits;
    NSArray * units;
    int selectedUnits;
}

@end

@implementation RadiusSettingsViewController

- (void)viewDidLoad {


    [super viewDidLoad];

    if (!selectedUnits){
        selectedUnits = 0;
    }
    
    units = @[ @[@"kilometers", @"meters"], @[@"miles", @"yards"]];
    _pickerDataWhole = [NSMutableArray array];
    _pickerDataParts = [NSMutableArray array];

    for(int i=0; i<1001; i++) {
        [_pickerDataWhole addObject:@(i)];
    }
    for (int i=0; i<10;i++){
        [_pickerDataParts addObject:@(i*100)];
    }
    self.radiusPicker.dataSource = self;
    self.radiusPicker.delegate = self;
    [self.radiusPicker reloadAllComponents];
    [self.radiusPicker selectRow:1 inComponent:0 animated:YES];
    [self.radiusPicker selectRow:5 inComponent:1 animated:YES];

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
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        return 2;
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView
didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0){
        //units section
        selectedUnits = (int)indexPath.row;
        [self.radiusPicker reloadAllComponents];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selected = YES;
//        if (indexPath.row == 0){
//
//        }
//        else {
//        
//        }
    }
}
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
// The number of columns of data
- (NSInteger*)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// The number of rows of data
- (NSInteger*)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0){
        return _pickerDataWhole.count;
    }
    else{
        return _pickerDataParts.count;
    }

}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0){
        return [NSString stringWithFormat:@"%@ %@", [_pickerDataWhole objectAtIndex:row], units[selectedUnits][0]];
    }
    else{
        return [NSString stringWithFormat:@"%@ %@", [_pickerDataParts objectAtIndex:row], units[selectedUnits][1]];
    }

}
@end
