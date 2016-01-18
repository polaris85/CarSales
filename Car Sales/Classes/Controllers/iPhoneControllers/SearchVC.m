//
//  FirstViewController.m
//  Car Sales
//
//  Created by Adam on 5/14/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "SearchVC.h"

#import "ManufacturesVC.h"
#import "BodyTypesVC.h"
#import "PriceRangesVC.h"
#import "KnowHowsVC.h"

#import "MultiLineButton.h"

#import "SearchCell.h"
#import "ResultsVC.h"

#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "JT2ReadFileDB.h"


@interface SearchVC () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UILabel *_promptLabel;
    __weak IBOutlet UILabel *_tableHeader;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UITextField *_tfSearch;
    
    __weak IBOutlet UIImageView *_imgLogo;
    __weak IBOutlet UIView *_searchViewContainter;
    __weak IBOutlet UIView *_topViewContainter;
    __weak IBOutlet SearchCell *_searchCell;
    
    NSArray *_items;
}

- (IBAction)showADS:(id)sender;
- (IBAction)showMenu:(id)sender;
- (IBAction)doSearch:(id)sender;


@end

@implementation SearchVC

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = nil;
        _items = @[SEARCH_MANUFACTURES, SEARCH_BODY_TYPES, SEARCH_PRICE_RANGES, SEARCH_TEST  ];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = SEARCH_TITLE;
    
    self.navigationController.navigationBarHidden = YES;
    
//    _promptLabel.text = SEARCH_PROMT;
    
    self.searchDisplayController.searchBar.placeholder = SEARCH;
    
    if ([Common isIOS7]) {
        CGRect tmpRect = _topViewContainter.frame;
        tmpRect.origin.y = 0;
        tmpRect.size.height += 20;
        _topViewContainter.frame = tmpRect;
        
        tmpRect = _promptLabel.frame;
        tmpRect.origin.y += 6;
        _promptLabel.frame = tmpRect;
        
        tmpRect = _imgLogo.frame;
        tmpRect.origin.y += 10;
        _imgLogo.frame = tmpRect;
        
        tmpRect = _searchViewContainter.frame;
        tmpRect.origin.y -= 20;
        _searchViewContainter.frame = tmpRect;
        
        tmpRect = _tableView.frame;
        tmpRect.origin.y -= 20;
        _tableView.frame = tmpRect;
    }

    
    
    _tableHeader.text = SEARCH_TABLE_HEADER;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    _tfSearch = nil;
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_tfSearch resignFirstResponder];
    [[AppDelegate shared] showHideMenuBarWithIsTouch:YES];
}

// ios 7 light content
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Action

- (IBAction)showADS:(id)sender {
    [_tfSearch resignFirstResponder];
    [[AppDelegate shared] showAds];
}

- (IBAction)showMenu:(id)sender {
    [_tfSearch resignFirstResponder];
    [[AppDelegate shared] showHideMenuBar];
}

- (IBAction)doSearch:(id)sender {
    if ([[Common trimString:_tfSearch.text] isEqualToString:@""]) {
        [Common showAlert:ERROR_NO_INPUT];
    } else {
        [_tfSearch resignFirstResponder];
        
        // set Dic query
        [[Common user].dicQuery removeAllObjects];
        [[Common user].dicQuery setObject:_tfSearch.text forKey:@"Keyword"];
        
        ResultsVC *vc = [[ResultsVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
        
        [vc loadListForSearchByKeyword:[Common trimString:_tfSearch.text]];
    
        _tfSearch.text = @"";
    }
}

#pragma mark - UISearchBarDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [[AppDelegate shared] setMenuBarHidden:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cellR = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (cellR == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
        cellR = _searchCell;
        _searchCell = nil;
        
    }
    
    cellR.lbCell.text = _items[indexPath.row];
    cellR.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_cell_img_0%d.png",indexPath.row+1]];
    
    return cellR;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _tableView) {
        UIViewController *vc;
        if (indexPath.row == 0) {
            vc = [[ManufacturesVC alloc] init];
        } else if (indexPath.row == 1) {
            vc = [[BodyTypesVC alloc] init];
        } else if (indexPath.row == 2) {
            vc = [[PriceRangesVC alloc] init];
        } else if (indexPath.row == 3) {
            vc = [[KnowHowsVC alloc] init];
        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

- (void)callReadDBWithPath:(NSString *)pathDB {

    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:ALL_CAR_NUM_DB];
    NSString *tableDB    = ALL_CAR_NUM_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:ALL_CAR_NUM_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {            
            for (NSDictionary *item in array) {
                NSString *all_num = @"";
                
                long allLong = [[item objectForKey:@"num"] longLongValue];
                BOOL ok = YES;
                int i = 1000;
                while (ok) {                    
                    if ([all_num isEqualToString:@""]) {
                        all_num = [NSString stringWithFormat:@"%ld",allLong%i];
                    } else {
                        all_num = [NSString stringWithFormat:@"%ld,%@",allLong%i,all_num];
                    }
                    
                    allLong /= i;
                    
                    if (allLong > 0) {
                        
                    } else {
                        ok = NO;
                    }
                }
                
                _promptLabel.text = [NSString stringWithFormat:@"登録台数 %@ 台",all_num] ;
            }

        }
    }];
}

@end
