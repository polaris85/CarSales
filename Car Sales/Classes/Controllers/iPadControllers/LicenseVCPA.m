//
//  LicenseVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/28/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "LicenseVCPA.h"
#import "Define.h"
#import "Common.h"
#import "AppDelegate.h"

@interface LicenseVCPA ()<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *_webView;
    __weak IBOutlet UIActivityIndicatorView *_indicator;
}

@end

@implementation LicenseVCPA

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LICENSE_TITLE;
    
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://usedcarget.net/app_agree/kiyaku.html"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
    
    UIButton *btClose =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btClose setImage:[UIImage imageNamed:@"btn_close_popup.png"] forState:UIControlStateNormal];
    [btClose addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [btClose setFrame:CGRectMake(0, 0, 49, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btClose];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    _webView = nil;
    _indicator = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    _webView.hidden = YES;
    _indicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.hidden = NO;
    _indicator.hidden = YES;
        
    NSString* js =
    @"var meta = document.createElement('meta'); "
    @"meta.setAttribute( 'name', 'viewport' ); "
    @"meta.setAttribute( 'content', 'width = 540px, initial-scale = 1.0, user-scalable = yes' ); "
    @"document.getElementsByTagName('head')[0].appendChild(meta)";
    
    [_webView stringByEvaluatingJavaScriptFromString: js];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _webView.hidden = NO;
    _indicator.hidden = YES;
}

#pragma mark - Action

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
