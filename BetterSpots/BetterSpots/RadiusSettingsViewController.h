//
//  RadiusSettingsViewController.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 03.10.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadiusSettingsViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *radiusPicker;

@end
