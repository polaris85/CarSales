//
//  MoreAppsVC.m
//  Car Sales
//
//  Created by Adam on 5/29/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "MoreAppsVC.h"

@interface MoreAppsVC ()

@end

@implementation MoreAppsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    static BOOL yesno = NO;
    [super webViewDidFinishLoad:webView];
    yesno = !yesno;
    if (yesno) {
        webView.scalesPageToFit = YES;
        [webView reload];
    } else {
        NSString* js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.width = %.0f", webView.frame.size.width];
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
}

@end
