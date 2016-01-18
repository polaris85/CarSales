//
//  LicenseVC.m
//  Car Sales
//
//  Created by Adam on 5/18/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "LicenseVC.h"
#import "Strings.h"

@interface LicenseVC ()
{
    __weak IBOutlet UIWebView *_webView;
    IBOutlet UIActivityIndicatorView *_indicator;
}

@end

@implementation LicenseVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = LICENSE_TITLE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = LICENSE_TITLE;
    
    self.navigationItem.rightBarButtonItem = nil;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://usedcarget.net/app_agree/kiyaku.html"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _webView.hidden = YES;
    _indicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.hidden = NO;
    _indicator.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _webView.hidden = NO;
    _indicator.hidden = YES;
}

@end
