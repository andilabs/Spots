//
//  SpotCellTableViewCell.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 21.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpotCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *spotThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *spotNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotDistanceLabel;
@end
