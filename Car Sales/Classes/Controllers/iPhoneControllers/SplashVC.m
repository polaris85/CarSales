//
//  SplashVC.m
//  Car Sales
//
//  Created by Le Phuong Tien on 6/3/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "SplashVC.h"
#import "PrefWS.h"
#import "Common.h"
#import "Define.h"

@interface SplashVC (){
    
    __weak IBOutlet UIImageView *_imageView;
}

@end

@implementation SplashVC

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
    
    
    if ([Common user].isIPhone5Screen) {
//        _imageView.image = [UIImage imageNamed:@"splash2.png"];
    } else {
        _imageView.image = [UIImage imageNamed:@"Default.png"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}




- (void)viewDidUnload {
    _imageView = nil;
    [super viewDidUnload];
}
@end
