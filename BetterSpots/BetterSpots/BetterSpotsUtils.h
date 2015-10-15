//
//  BetterSpotsUtils.h
//  BetterSpots
//
//  Created by Andrzej Kostański on 12.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BetterSpotsCommon.h"

@interface UIColor(MBCategory)
+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;
@end


@interface BetterSpotsUtils : NSObject
/*! Helper method for showing simple alert messages to the user in context of given UIViewController
 */
+ (void)showAlertInfoWithTitle:(NSString *)title
                    andMessage:(NSString *)message
                   inContextOf:(UIViewController *)uiViewController;
/*! Helper method for scaling images
 */
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize;
+ (void)makePhoneCall:(NSString *)phoneNumber;
+ (UIColor *)getSpotsLeadingColor;
+ (NSString *)getSpotsNearbyApiUrl;
+ (NSString *)getSpotsAppName;
+ (NSString *)getSpotsAllEmoji;
+ (NSString *)getSpotsMainEmoji;
+ (NSString *)getSpotsLoadingViewEmoji;

/*! Returns target specific facilities from definitions in target's plist file
 \returns list of strings e.g [@"fresh water", @"special menu for dogs"]
 */
+ (NSArray *)getSpotsFacilities;

/*! For given unichar representing icon in Font-Awesome font returns string with this icon
 \param symbolCode e.g 0xf005 representing star
 \returns string with FA icon e.g star icon ready to use
 */
+ (NSString *)getFACharForSymbol:(unichar)symbolCode;
+ (void)setUpColorsForNavigationViewController: (UINavigationController*)controller;
+ (void)setupBrandingForNavigationItem: (UINavigationItem*)navigationItem;

@end

