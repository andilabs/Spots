//
//  MyActivityIndicatorView.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "MyActivityIndicatorView.h"
#import "BetterSpotsUtils.h"

@implementation MyActivityIndicatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

-(void)configureView{
    
    UIColor * spotLeadingColor = [UIColor colorWithHexString:@"#fcbd41"];
    [self setBackgroundColor: spotLeadingColor];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.center;
    [activityView startAnimating];
    [self addSubview:activityView];
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                               0,//(self.frame.size.width-s.width)/2,
                                                               self.frame.size.height/2+activityView.frame.size.height,
                                                               self.frame.size.width,
                                                               70
                                                               )];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:24.0f];
    label.numberOfLines = 2;
    
//    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"Searching nearby spots... \n🐶";
    label.textAlignment = NSTextAlignmentCenter;

    [self addSubview:label];

}
@end
