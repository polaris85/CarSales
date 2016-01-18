//
//  ViewShopVC.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/10/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ViewShopVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"

@interface ViewShopVC ()
{
    
    __weak IBOutlet UIActivityIndicatorView *_indicator;
    __weak IBOutlet UIWebView *_webView;
}

@end

@implementation ViewShopVC

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
    
    self.title = @"お問い合わせ";
    
    UIButton *btBack =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btBack setImage:[UIImage imageNamed:@"navi_bt_back2.png"] forState:UIControlStateNormal];
    [btBack addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [btBack setFrame:CGRectMake(0, 0, 60, 30)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btBack];
    if ([Common isIOS7] && ![Common user].isIPhone) {
        [self loadWebCarByID:_urlAddress];
    }
    else
        [self loadWebCarByID:_carID];
}

- (void)viewDidUnload {
    _webView = nil;
    _indicator = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return ![Common user].isIPhone;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ![Common user].isIPhone;
}

#pragma mark - Others

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadWebCarByID:(NSString*)carID
{
    // load webView
    NSString *urlAddress = @"";
    
    if ([Common user].isIPhone) {
        urlAddress = [NSString stringWithFormat:@"https://www.carsensor.net/smph/ex_multi_inquiry_mm.php?STID=SMPH2400&vos=smph201305071&BKKN=%@",carID];
    } else {
        urlAddress = carID;
    }
    
    NSLog(@"url : %@",urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        return NO;
    }
    
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
