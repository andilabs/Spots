//
//  BetterSpotsUtils.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 12.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(MBCategory)
+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;
@end


@interface BetterSpotsUtils : NSObject

+ (void)showAlertInfoWithTitle: (NSString *)title andMessage: (NSString *)message inContextOfViewController: (UIViewController *) uiViewController;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void)makePhoneCall: (NSString *) phoneNumber;

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;
@end

