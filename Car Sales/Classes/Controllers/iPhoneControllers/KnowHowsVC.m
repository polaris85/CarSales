//
//  KnowHowsVC.m
//  Car Sales
//
//  Created by 荒井雅也GMOTECH on 2013/12/26.
//  Copyright (c) 2013年 Le Phuong Tien. All rights reserved.
//

#import "KnowHowsVC.h"
#import "StatesVC.h"
#import "Common.h"
#import "AppDelegate.h"
#import "Define.h"

@interface KnowHowsVC ()<UIWebViewDelegate>

@end

@implementation KnowHowsVC

- (id)init
{
    self = [super init];
    
    self.title = KNOW_HOWS_TITLE;


    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webview.delegate = self;
    
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    float tabBarHeight = [[[self tabBarController] rotatingFooterView] frame].size.height;
    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    if ([Common isIOS7]) {
        self.webview.frame = CGRectMake(0, 0, 320, screenHeight - tabBarHeight);
    }
    else
        self.webview.frame = CGRectMake(0, 0, 320, screenHeight - tabBarHeight - navBarHeight - 20);

    self.webview.scalesPageToFit = YES;
    [self.view addSubview:self.webview];
    
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"manetazations" ofType:@"html"];
	NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath  encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"htmlPath: %@", htmlPath);
    NSLog(@"htmlString: %@", htmlString);
    
	[self.webview loadHTMLString:htmlString baseURL:baseUrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebview:nil];
    [self setNav:nil];
    [self setNav:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


// リンクをクリック時、Safariを起動する為の処理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther)
    {
        NSString* scheme = [[request URL] scheme];
        if([scheme compare:@"about"] == NSOrderedSame) {
            return YES;
        }
        if([scheme compare:@"http"] == NSOrderedSame) {
            [[UIApplication sharedApplication] openURL: [request URL]];
            return NO;
        }
    }
    return YES;
}

@end
