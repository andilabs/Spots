//
//  BetterSpotsUtils.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 12.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "BetterSpotsUtils.h"


@implementation BetterSpotsUtils

+(void)showAlertInfoWithTitle:(NSString *)title andMessage:(NSString *)message inContextOf:(UIViewController *) uiViewController{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [uiViewController presentViewController:alertController
                       animated:YES
                     completion:nil];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)makePhoneCall:(NSString *)phoneNumber {
    NSString *cleanedPhoneNumber = [[NSString alloc] initWithString: [NSString stringWithFormat:@"telprompt:%@",
                                                                      [phoneNumber stringByReplacingOccurrencesOfString:@" "
                                                                                                             withString:@""]]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cleanedPhoneNumber]];
}

+ (UIColor *)getSpotsLeadingColor {
    return [UIColor colorWithHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsLeadingColor]];
}

+ (NSString *)getSpotsNearbyApiUrl {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsEndpointURL];
}

+ (NSString *)getSpotsAppName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:AppName];
}
+ (NSString *)getSpotsAllEmoji {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsEmoji];
}
+ (NSString *)getSpotsMainEmoji {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsEmoji][0];
}
+ (NSString *)getSpotsLoadingViewEmoji {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsEmoji][1];
}

+ (NSArray *)getSpotsFacilities {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:SpotsFacilites];
}

+ (NSString *)getFACharForSymbol:(unichar)symbolCode {
    return [NSString stringWithFormat:@"%C", symbolCode];
}
+ (void)setUpColorsForNavigationViewController: (UINavigationController*)controller{
    // make background color of navigation bar with spot default color
    controller.navigationBar.barTintColor = [BetterSpotsUtils getSpotsLeadingColor];
    // make fonts on navigation bar white
    controller.navigationBar.barStyle = UIBarStyleBlack;
    controller.navigationBar.tintColor = [UIColor whiteColor];
}

+ (void)setupBrandingForNavigationItem: (UINavigationItem*)navigationItem {
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lobster" size:26];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = [[BetterSpotsUtils getSpotsAppName] stringByReplacingOccurrencesOfString:@"Radar" withString:@""];
    navigationItem.titleView = label;
}

@end

@implementation UIColor(MBCategory)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end
