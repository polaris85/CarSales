//
//  PAPickerVC.m
//  MovingHouse
//
//  Created by Nick Lee on 4/15/13.
//  Copyright (c) 2013 tienlp. All rights reserved.
//

#import "PAPickerVC.h"
#import "Define.h"

@interface PAPickerVC ()
{
    
    __weak IBOutlet UINavigationBar *_navigationBar;
}

@end

@implementation PAPickerVC

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
    // Do any additional setup after loading the view from its nib.
    
    // add bar button
    
    UIButton *done =  [UIButton buttonWithType:UIButtonTypeCustom];
    [done setImage:[UIImage imageNamed:@"btn_navi_done.png"] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(didChangeDone:) forControlEvents:UIControlEventTouchUpInside];
    [done setFrame:CGRectMake(0, 0, 68, 30)];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:done];
    
    UIButton *btReturn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btReturn setImage:[UIImage imageNamed:@"btn_navi_cancel.png"] forState:UIControlStateNormal];
    [btReturn addTarget:self action:@selector(didChangeCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btReturn setFrame:CGRectMake(0, 0, 68, 30)];
    
    UIBarButtonItem *cancelButtonItem= [[UIBarButtonItem alloc] initWithCustomView:btReturn];
    
    
    UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@""];
    
    topItem.leftBarButtonItem = cancelButtonItem;
    topItem.rightBarButtonItem = doneButtonItem;
    
    [_navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master.png"] forBarMetrics:UIBarMetricsDefault];
    [_navigationBar pushNavigationItem:topItem animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPicker:nil];
    _navigationBar = nil;
    [super viewDidUnload];
}

- (void)setTitlePicker:(NSString*)name{
    _navigationBar.topItem.title = name;
}

- (IBAction)didChangeCancel:(id)sender {
     [_popover dismissPopoverAnimated:YES];

    if (_delegate && [_delegate respondsToSelector:@selector(pickerSheet:dismissWithDone:)]) {
        [_delegate pickerSheet:self dismissWithDone:NO];
    }
   
}

- (IBAction)didChangeDone:(id)sender {
    [_popover dismissPopoverAnimated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(pickerSheet:dismissWithDone:)]) {
        [_delegate pickerSheet:self dismissWithDone:YES];
    }
}
@end
