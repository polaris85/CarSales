//
//  ManufacturesVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ManufacturesVC.h"
#import "VehiclesVC.h"
#import "StatesVC.h"

#import "ManufacturesCell.h"

#import "JT2ReadFileDB.h"

#import "Common.h"
#import "Define.h"
#import "CompanyItem.h"
#import "CMIndexBar.h"

@interface ManufacturesVC () <UITableViewDataSource, UITableViewDelegate,CMIndexBarDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet ManufacturesCell *manufacturesCell;
    
    NSMutableArray *_sections;
    NSMutableDictionary *_items;
}

@end

@implementation ManufacturesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title  = MANUFACTURES_TITLE;
        _sections   = [[NSMutableArray alloc] init];
        _items      = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    
    self.trackedViewName = MANUFACTURES_TITLE;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    // get list
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
    CMIndexBar *indexBar ;
    
    if ([Common isIOS7]) {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 110.0, 80.0, self.view.frame.size.height)];
        indexBar.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    else
    {
         indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 20.0, 80.0, self.view.frame.size.height-20)];

    }

    [indexBar setIndexes:_sections ];

    indexBar.delegate = self;
    [self.view addSubview:indexBar];

}

- (void)viewDidUnload
{
    [_sections removeAllObjects];
    [_items removeAllObjects];
    manufacturesCell = nil;
    _tableView = nil;
    [super viewDidUnload];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CMIndexBarDelegate

- (void)indexSelectionDidChange:(CMIndexBar *)indexBar index:(NSInteger)index title:(NSString*)title
{
    NSLog(@" %@ %d ",title,index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [_tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];

}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
    
    UIImageView *imgBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_section_02.png"]];
    imgBG.frame = viewHeader.frame;
    [viewHeader addSubview:imgBG];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 23)];
    title.text = _sections[section];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:12.0];
    title.textColor = [UIColor whiteColor];
    title.shadowOffset = CGSizeMake(1.0, 1.0);
    title.shadowColor = [UIColor grayColor];
    [viewHeader addSubview:title];
    
    return viewHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:section]];
    return [tempArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManufacturesCell *cellR = [tableView dequeueReusableCellWithIdentifier:@"ManufacturesCell"];
    if (cellR == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ManufacturesCell" owner:self options:nil];
        cellR = manufacturesCell;
        manufacturesCell = nil;
        
    }

    NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:indexPath.section]];
    CompanyItem *item  = [tempArray objectAtIndex:indexPath.row];
    
    cellR.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.companyName,item.useCarNum];
    cellR.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",item.companyImage]];
    
    return cellR;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSLog(@"%@",_sections);
//    return _sections;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return index;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:indexPath.section]];
    CompanyItem *item  = [tempArray objectAtIndex:indexPath.row];
    
    // set Dic query
    [[Common user].dicQuery removeAllObjects];
    [[Common user].dicQuery setObject:item forKey:@"CompanyItem"];
    
    VehiclesVC *vc = [[VehiclesVC alloc] init];
    [vc loadDataWith:item];
    
    if ([vc checkDataListCatalog]) {
      [self.navigationController pushViewController:vc animated:YES];  
    } else {
        StatesVC *vc = [[StatesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        vc.companyItem = item;
    }
}



#pragma mark - SQLite

//read data from file DB
- (void)callReadDBWithPath:(NSString *)pathDB {
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
                    
                    
                    if (![[item objectForKey:@"country_name"] isEqualToString:temp]) {
                        [_sections addObject:[item objectForKey:@"country_name"]];
                        temp = [item objectForKey:@"country_name"];
                    }
                    
                    NSMutableArray *arrayTemp = [_items objectForKey:temp];
                    if (arrayTemp) {
                        [arrayTemp addObject:companyItem];
                    } else {
                        arrayTemp = [[NSMutableArray alloc] init];
                        [arrayTemp addObject:companyItem];
                    }
                    
                    [_items setObject:arrayTemp forKey:temp];
                    
                    arrayTemp = nil;
                }
            }
            
            [_tableView reloadData];
        }
    }];
}

@end
