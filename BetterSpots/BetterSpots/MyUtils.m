//
//  MyUtils.m
//  Clean
//
//  Created by Andrzej Kostański on 09/02/15.
//  Copyright (c) 2015 Andrzej Kostanski. All rights reserved.
//

#import "MyUtils.h"

@implementation MyUtils

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end