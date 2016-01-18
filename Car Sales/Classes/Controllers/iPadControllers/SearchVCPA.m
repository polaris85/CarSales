//
//  SearchVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/21/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "SearchVCPA.h"
#import "Common.h"
#import "Define.h"
#import "AppDelegate.h"
#import "JT2ReadFileDB.h"

#import "CompanyPACell.h"
#import "BodyTypePACell.h"

#import "CompanyItem.h"
#import "BodyTypeItem.h"

#import "CatalogVCPA.h"
#import "StatesVCPA.h"
#import "ResultsVCPA.h"
#import "MasterNavigationController.h"
#import "DetailNavigationController.h"
#import "CMIndexBar.h"
static __weak SearchVCPA *shared = nil;

@interface SearchVCPA ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,CMIndexBarDelegate>
{
    __weak IBOutlet UILabel *_promptLabel;
    __weak IBOutlet UITextField *_tfSearch;
    
    __weak IBOutlet UIButton *_btnTab1;
    __weak IBOutlet UIButton *_btnTab2;
    __weak IBOutlet UIButton *_btnTab3;
    __weak IBOutlet UIButton *_btnTab4;
    
    __weak IBOutlet UITableView *_table1;
    __weak IBOutlet UITableView *_table2;
    __weak IBOutlet UITableView *_table3;
    __weak IBOutlet UITableView *_table4;
    
    __weak IBOutlet UIButton *btn4;
    __weak IBOutlet UIButton *btn3;
    __weak IBOutlet UIButton *btn2;
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UILabel *lblPrice;
    __weak IBOutlet UIButton *btnMoreApp;
    __weak IBOutlet UIImageView *_imgBgSplitView;
    __weak IBOutlet UIView *_viewTextfieldContainer;
    __weak IBOutlet UIView *_viewHeaderContainer;
    int _indexTabTable;
    
    NSMutableArray *_items1;
    
    NSMutableArray *_sections2;
    NSMutableDictionary *_items2;
    
    NSMutableArray *_items3;
    
    NSMutableArray *_items4;
    
    CMIndexBar *indexBar ;

}
- (IBAction)showMoreApp:(id)sender;

- (IBAction)selectTabTable:(id)sender;

- (IBAction)doSearch:(id)sender ;

@end

@implementation SearchVCPA

+ (SearchVCPA *)shared
{
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        shared = self;
    }
    return self;
}

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
    
    //setting
    
    //active tab 1
    _indexTabTable = 1;
    [_btnTab1 setImage:[UIImage imageNamed:@"btn1_active_segment_splitview.png"] forState:UIControlStateNormal];
    
    //table1
    _table1.delegate = self;
    _table1.dataSource = self;
    
    _items1 = [[NSMutableArray alloc] init];
    
    //table2
    _table2.delegate = self;
    _table2.dataSource = self;
    
    _items2 = [[NSMutableDictionary alloc] init];
    _sections2 = [[NSMutableArray alloc] init];
    
    //load data 1 2
    [self callReadDBCompanyWithPath:[AppDelegate shared].pathFileDB];
    
    //table3
    _table3.delegate = self;
    _table3.dataSource = self;
    
    _items3 = [[NSMutableArray alloc] init];
    
    // load data 3
    [self callReadDBBodyTypeWithPath:[AppDelegate shared].pathFileDB];
    
    //table4
    _table4.dataSource = self;
    _table4.delegate = self;
    
    _items4 = [[NSMutableArray alloc] initWithArray:@[@"~20万円",
                                                     @"20~40万円",
                                                     @"40~60万円",
                                                     @"60~80万円",
                                                     @"80~100万円",
                                                     @"100~150万円",
                                                     @"150~200万円",
                                                     @"200~250万円",
                                                     @"250~300万円",
                                                     @"300~350万円",
                                                     @"350~400万円",
                                                     @"400~450万円",
                                                     @"450~500万円",
                                                     @"500~600万円",
                                                     @"600~700万円",
                                                     @"700~800万円",
                                                     @"800~900万円",
                                                     @"900~1000万円"]];
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_table1 respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table1 setSeparatorInset:UIEdgeInsetsZero];
        [_table2 setSeparatorInset:UIEdgeInsetsZero];
        [_table3 setSeparatorInset:UIEdgeInsetsZero];
        [_table4 setSeparatorInset:UIEdgeInsetsZero];
    }

    
    if ([Common isIOS7]) {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 140.0, 80.0, self.view.frame.size.height-240)];
        indexBar.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        
        // move table view
        CGRect tmpRect = _viewHeaderContainer.frame;
        tmpRect.size.height += 20;
        _viewHeaderContainer.frame = tmpRect;
        
        // set bg
        [_imgBgSplitView setImage:[UIImage imageNamed:@"bg_nav_splitview2.png"]];
        tmpRect = _imgBgSplitView.frame;
        tmpRect.size.height += 20;
        _imgBgSplitView.frame = tmpRect;
        
        tmpRect = btnMoreApp.frame;
        tmpRect.origin.y += 20;
        btnMoreApp.frame = tmpRect;
        
        tmpRect = btn4.frame;
        tmpRect.origin.y += 20;
        btn4.frame = tmpRect;
        
        tmpRect = btn3.frame;
        tmpRect.origin.y += 20;
        btn3.frame = tmpRect;
        
        tmpRect = btn2.frame;
        tmpRect.origin.y += 20;
        btn2.frame = tmpRect;
        
        tmpRect = btn1.frame;
        tmpRect.origin.y += 20;
        btn1.frame = tmpRect;
        
        tmpRect = lblPrice.frame;
        tmpRect.origin.y += 20;
        lblPrice.frame = tmpRect;
        
        tmpRect = _viewTextfieldContainer.frame;
        tmpRect.origin.y += 20;
        _viewTextfieldContainer.frame = tmpRect;
        
        tmpRect = _table1.frame;
        tmpRect.origin.y += 20;
        _table1.frame = tmpRect;
        
        tmpRect = _table2.frame;
        tmpRect.origin.y += 20;
        _table2.frame = tmpRect;
        
        tmpRect = _table3.frame;
        tmpRect.origin.y += 20;
        _table3.frame = tmpRect;
        
        tmpRect = _table4.frame;
        tmpRect.origin.y += 20;
        _table4.frame = tmpRect;
    }
    else
    {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 120.0, 80.0, self.view.frame.size.height-200)];
    }
    
    [indexBar setIndexes:_sections2 ];
    
    indexBar.delegate = self;
    [self.view addSubview:indexBar];
    indexBar.hidden = true;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self callReadDBAllCarWithPath:[AppDelegate shared].pathFileDB];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidUnload {
    _btnTab1 = nil;
    _btnTab2 = nil;
    _btnTab3 = nil;
    _btnTab4 = nil;
    _promptLabel = nil;
    _table1 = nil;
    _table2 = nil;
    _table3 = nil;
    _table4 = nil;
    _tfSearch = nil;
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

#pragma mark - Others
- (void) dismissKeyboad
{
    [_tfSearch resignFirstResponder];
}

#pragma mark - Action

- (IBAction)doSearch:(id)sender {
    if ([[Common trimString:_tfSearch.text] isEqualToString:@""]) {
        [Common showAlert:ERROR_NO_INPUT];
    } else {
        [_tfSearch resignFirstResponder];
        
        // set Dic query
        [[Common user].dicQuery removeAllObjects];
        [[Common user].dicQuery setObject:_tfSearch.text forKey:@"Keyword"];

        [[DetailNavigationController shared] dismissPopover];
        [ResultsVCPA shared].typeload = ResultsTypeLoadMaster;
        [[ResultsVCPA shared] loadListForCommonQueryDic:[Common user].dicQuery];
        
        _tfSearch.text = @"";
    }
}

- (IBAction)showMoreApp:(id)sender {
    [[AppDelegate shared] showAds];
}

- (IBAction)selectTabTable:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    _indexTabTable = button.tag;
    
    [_btnTab1 setImage:[UIImage imageNamed:@"btn1_segment_splitview.png"] forState:UIControlStateNormal];
    [_btnTab2 setImage:[UIImage imageNamed:@"btn2_segment_splitview.png"] forState:UIControlStateNormal];
    [_btnTab3 setImage:[UIImage imageNamed:@"btn3_segment_splitview.png"] forState:UIControlStateNormal];
    [_btnTab4 setImage:[UIImage imageNamed:@"btn4_segment_splitview.png"] forState:UIControlStateNormal];
    
    CGRect rect = _table1.frame;
    
    rect.origin.x = 640.0;
    
    _table1.frame = rect;
    _table2.frame = rect;
    _table3.frame = rect;
    _table4.frame = rect;
    
    rect.origin.x = 0.0;
    
    indexBar.hidden = true;
    
    if (button.tag == 1) {
        [_btnTab1 setImage:[UIImage imageNamed:@"btn1_active_segment_splitview.png"] forState:UIControlStateNormal];
        _table1.frame = rect;
    } else if (button.tag == 2) {
        [_btnTab2 setImage:[UIImage imageNamed:@"btn2_active_segment_splitview.png"] forState:UIControlStateNormal];
        _table2.frame = rect;
        indexBar.hidden = false;
    } else if (button.tag == 3) {
        [_btnTab3 setImage:[UIImage imageNamed:@"btn3_active_segment_splitview.png"] forState:UIControlStateNormal];
        _table3.frame = rect;
    } else if (button.tag == 4) {
        [_btnTab4 setImage:[UIImage imageNamed:@"btn4_active_segment_splitview.png"] forState:UIControlStateNormal];
        _table4.frame = rect;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[Common trimString:_tfSearch.text] isEqualToString:@""]) {
        [Common showAlert:ERROR_NO_INPUT];
    } else {
        [_tfSearch resignFirstResponder];
        
        // set Dic query
        [[Common user].dicQuery removeAllObjects];
        [[Common user].dicQuery setObject:_tfSearch.text forKey:@"Keyword"];
        
        [[DetailNavigationController shared] dismissPopover];
        [ResultsVCPA shared].typeload = ResultsTypeLoadMaster;
        [[ResultsVCPA shared] loadListForCommonQueryDic:[Common user].dicQuery];
        
        _tfSearch.text = @"";
    }
    return YES;
}

#pragma mark - CMIndexBarDelegate

- (void)indexSelectionDidChange:(CMIndexBar *)indexBar index:(NSInteger)index title:(NSString*)title
{
    NSLog(@" %@ %d ",title,index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [_table2 scrollToRowAtIndexPath:indexPath
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _table1) {
        return 1;
    } else if(tableView == _table2){
        return [_sections2 count];
    } else if(tableView == _table3){
        return 1;
    } else if(tableView == _table4){
        return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _table1) {
        return nil;
    } else if (tableView == _table2){
        return _sections2[section];
    } else if (tableView == _table3){
        return nil;
    } else if(tableView == _table4){
        return nil;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _table1 || tableView == _table3 || tableView == _table4) {
        return 0;
    }
    
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _table1) {
        return nil;
    } else if (tableView == _table2){
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
        
        UIImageView *imgBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_section_02.png"]];
        imgBG.frame = viewHeader.frame;
        [viewHeader addSubview:imgBG];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 23)];
        title.text = _sections2[section];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:12.0];
        title.textColor = [UIColor whiteColor];
        title.shadowOffset = CGSizeMake(1.0, 1.0);
        title.shadowColor = [UIColor grayColor];
        [viewHeader addSubview:title];
        
        return viewHeader;
    } else if (tableView == _table3){
        return nil;
    } else if(tableView == _table4){
        return nil;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _table1) {
        return [_items1 count];
    } else if(tableView == _table2){
        NSMutableArray *tempArray = [_items2 objectForKey:[_sections2 objectAtIndex:section]];
        return [tempArray count];
    } else if(tableView == _table3){
        return [_items3 count];
    } else if(tableView == _table4){
        return [_items4 count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _table1) {
        CompanyPACell *cellR = [tableView dequeueReusableCellWithIdentifier:@"CompanyPACell"];
        if (cellR == nil) {
            cellR = [[[NSBundle mainBundle] loadNibNamed:@"CompanyPACell" owner:self options:nil] lastObject];
        }
        
        CompanyItem *item  = [_items1 objectAtIndex:indexPath.row];
        
        cellR.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.companyName,item.useCarNum];
        cellR.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",item.companyImage]];
        
        return cellR;
    } else if (tableView == _table2){
        CompanyPACell *cellR = [tableView dequeueReusableCellWithIdentifier:@"CompanyPACell"];
        if (cellR == nil) {
            cellR = [[[NSBundle mainBundle] loadNibNamed:@"CompanyPACell" owner:self options:nil] lastObject];
            cellR.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSMutableArray *tempArray = [_items2 objectForKey:[_sections2 objectAtIndex:indexPath.section]];
        CompanyItem *item  = [tempArray objectAtIndex:indexPath.row];
        
        cellR.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.companyName,item.useCarNum];
        cellR.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",item.companyImage]];
        
        return cellR;
    } else if (tableView == _table3){
        BodyTypePACell *cell = [tableView dequeueReusableCellWithIdentifier:@"BodyTypePACell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BodyTypePACell" owner:self options:nil] lastObject];
        }
        
        BodyTypeItem *item = _items3[indexPath.row];
        cell.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.bodyName, item.bodyAllNum];
        cell.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",item.bodyImage]];
        
        return cell;
    } else if(tableView == _table4){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = _items4[indexPath.row];
        return cell;
    }
    
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _table1) {
        return nil;
    } else if (tableView == _table2) {
        //return _sections2;
    } else if (tableView == _table3) {
        return nil;
    } else if(tableView == _table4){
        return nil;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView != _table2) {
        return index;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    // set Dic query
    [[Common user].dicQuery removeAllObjects];
    
//
    
    if (tableView == _table1) {
        CompanyItem *item  = [_items1 objectAtIndex:indexPath.row];
        [[Common user].dicQuery setObject:item forKey:@"CompanyItem"];
        
        CatalogVCPA *vc = [[CatalogVCPA alloc] init];
        [vc loadDataWith:item];
        
        if ([vc checkDataListCatalog]) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            StatesVCPA *vc = [[StatesVCPA alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            vc.companyItem = item;
        }

        
    } else if (tableView == _table2) {
        NSMutableArray *tempArray = [_items2 objectForKey:[_sections2 objectAtIndex:indexPath.section]];
        CompanyItem *item  = [tempArray objectAtIndex:indexPath.row];

        [[Common user].dicQuery setObject:item forKey:@"CompanyItem"];
        
        CatalogVCPA *vc = [[CatalogVCPA alloc] init];
        [vc loadDataWith:item];
        
        if ([vc checkDataListCatalog]) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            StatesVCPA *vc = [[StatesVCPA alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            vc.companyItem = item;
        }
        
    } else if (tableView == _table3) {
        
        BodyTypeItem *item = [_items3 objectAtIndex:indexPath.row];
        
        // set Dic query
        [[Common user].dicQuery setObject:item forKey:@"BodyTypeItem"];
        
        CatalogVCPA *vc = [[CatalogVCPA alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc loadDataWithBodyItem:item];
        
    } else if (tableView == _table4) {
        NSMutableDictionary *priceItem = [[NSMutableDictionary alloc] init];
        
        NSArray *array = [[_items4 objectAtIndex:indexPath.row] componentsSeparatedByString:@"~"] ;
        [priceItem setObject:array[0] forKey:@"priceNameMin"];
        NSString *priceMin = [NSString stringWithFormat:@"%@0000",array[0]];
        array = [array[1] componentsSeparatedByString:@"万円"];
        [priceItem setObject:array[0] forKey:@"priceNameMax"];
        NSString *priceMax = [NSString stringWithFormat:@"%@0000",array[0]];;
        
        // set Dic query
        [[Common user].dicQuery setObject:priceItem forKey:@"PriceItem"];
        
        NSLog(@"Min: %@ --> Max: %@",priceMin,priceMax);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        StatesVCPA *vc = [[StatesVCPA alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc loadPrefPrefWithPriceMin:priceMin priceMax:priceMax];
    }
}

#pragma mark - SQL

- (void)callReadDBAllCarWithPath:(NSString *)pathDB {
    
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

- (void)callReadDBCompanyWithPath:(NSString *)pathDB {
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:COMPANY_MASTER_DB];
    NSString *tableDB    = COMPANY_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:COMPANY_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSLog(@"count array ===> %d",array.count);
            
            NSString *temp = @"~";
            
            for (NSDictionary *item in array) {
                
                if ([[item objectForKey:@"status"] isEqual:@"1"]) {
                    CompanyItem *companyItem    = [[CompanyItem alloc] init];
                    
                    companyItem.companyID       = [item objectForKey:@"id"];
                    companyItem.companyCode     = [item objectForKey:@"company_code"];
                    companyItem.companyName     = [item objectForKey:@"company_name"];
                    companyItem.companyImage    = [item objectForKey:@"company_image"];
                    companyItem.countryCode     = [item objectForKey:@"country_code"];
                    companyItem.countryName     = [item objectForKey:@"country_name"];
                    companyItem.useCarNum       = [item objectForKey:@"use_car_num"];
                    companyItem.status          = [item objectForKey:@"status"];
                    companyItem.viewNum         = [item objectForKey:@"view_num"];

                    if ([companyItem.countryCode isEqualToString:@"JPN"]) {
                        // add to items1
                        [_items1 addObject:companyItem];
                    } else {
                        // add to items2
                        if (![[item objectForKey:@"country_name"] isEqualToString:temp]) {
                            [_sections2 addObject:[item objectForKey:@"country_name"]];
                            temp = [item objectForKey:@"country_name"];
                        }
                        
                        NSMutableArray *arrayTemp = [_items2 objectForKey:temp];
                        if (arrayTemp) {
                            [arrayTemp addObject:companyItem];
                        } else {
                            arrayTemp = [[NSMutableArray alloc] init];
                            [arrayTemp addObject:companyItem];
                        }
                        
                        [_items2 setObject:arrayTemp forKey:temp];
                        
                        arrayTemp = nil;
                    }    
                }
            }
            
            [_table1 reloadData];
            [_table2 reloadData];
        }
    }];
}

- (void)callReadDBBodyTypeWithPath:(NSString *)pathDB {
    NSLog(@"BodyType --> callReadDBWithPath");
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:BODY_MASTER_DB];
    NSString *tableDB    = BODY_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:BODY_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *item in array) {
                
                BodyTypeItem *bodyTypeItem = [[BodyTypeItem alloc] init];
                
                bodyTypeItem.bodyTypeId     = [item objectForKey:@"id"];
                bodyTypeItem.bodyCode       = [item objectForKey:@"body_code"];
                bodyTypeItem.bodyName       = [item objectForKey:@"body_name"];
                bodyTypeItem.bodyImage      = [item objectForKey:@"body_image"];
                bodyTypeItem.bodyAllNum     = [item objectForKey:@"body_all_num"];
                bodyTypeItem.bodyViewNum    = [item objectForKey:@"body_view_num"];
                
                [tempArray addObject:bodyTypeItem];
                
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bodyViewNum" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            _items3 = [NSMutableArray arrayWithArray:[tempArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            [_table3 reloadData];
        }
    }];
}

@end
