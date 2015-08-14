//
//  InAppWebViewController.m
//  BetterSpots
//
//  Created by Andrzej Kostański on 14.08.2015.
//  Copyright (c) 2015 Andrzej Kostański. All rights reserved.
//

#import "InAppWebViewController.h"

@interface InAppWebViewController ()

@end

@implementation InAppWebViewController{
    UIWebView *webview;
}

@synthesize dataModel;
- (IBAction)openCurrentWebPageInSafari:(id)sender {
    [[UIApplication sharedApplication] openURL: webview.request.URL.absoluteURL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    NSString *url=self.dataModel[@"www"];
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    [self.view addSubview:webview];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
