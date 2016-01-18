//
//  SplashVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/21/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "SplashVCPA.h"
#import "Common.h"


@interface SplashVCPA (){
    
    __weak IBOutlet UIImageView *_image;
}

@end

@implementation SplashVCPA

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
    
    if ([Common isPortrait]) {
        _image.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
    } else {
        _image.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([Common isPortrait]) {
        _image.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
    } else {
        _image.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
    }
}

- (void)viewDidUnload {
    _image = nil;
    [super viewDidUnload];
}
@end
