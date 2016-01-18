//
//  VehiclesVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "VehiclesVC.h"
#import "StatesVC.h"
#import "ResultsVC.h"

#import "VehiclesCell.h"

#import "JT2ReadFileDB.h"

#import "Common.h"
#import "Define.h"
#import "CompanyItem.h"
#import "CatalogItem.h"
#import "Downloader.h"
#import "CMIndexBar.h"

@interface VehiclesVC () <UITableViewDataSource, UITableViewDelegate, DownloaderDelegate,CMIndexBarDelegate>
{
    __weak IBOutlet UITableView     *_tableView;
    __weak IBOutlet VehiclesCell    *_vehiclesCell;
    
    NSMutableArray *_sections;
    NSMutableDictionary *_items;
    
    BOOL _isLoadWithCompany;
}

@property(nonatomic,strong) CompanyItem *companyItem;
@property(nonatomic,strong) BodyTypeItem *bodyTypeItem;

@end

@implementation VehiclesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title  = VEHICLES_TITLE;
        _sections   = [[NSMutableArray alloc] init];
        _items      = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    self.trackedViewName = VEHICLES_TITLE;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    CMIndexBar *indexBar ;
    
    if ([Common isIOS7]) {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 80, 40.0, self.view.frame.size.height + 48)];
        indexBar.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    else
    {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 20.0, 40.0, self.view.frame.size.height -40)];
    }
    
    [indexBar setIndexes:_sections ];
    
    indexBar.delegate = self;
    [self.view addSubview:indexBar];

}

- (void)viewDidUnload
{
    for (NSMutableArray *array in _items) {
        [array removeAllObjects];
    }
    
    [_sections removeAllObjects];
    [_items removeAllObjects];
    
    
    
    _tableView = nil;
    _vehiclesCell = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self downLoadThumb];
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
    VehiclesCell *cellR = [tableView dequeueReusableCellWithIdentifier:@"VehiclesCell"];
    if (cellR == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"VehiclesCell" owner:self options:nil];
        cellR = _vehiclesCell;
        _vehiclesCell = nil;
        
    }
    
    NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:indexPath.section]];
    CatalogItem *item = [tempArray objectAtIndex:indexPath.row];
    
    cellR.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.model,item.carNum];
    
    if (item.image) {
        cellR.imgCell.image = item.image;
    } else {
        cellR.imgCell.image = [UIImage imageNamed:@"img_no_image.png"];
    }
    
    return cellR;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
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
    CatalogItem *item = [tempArray objectAtIndex:indexPath.row];
    
    [[Common user].dicQuery removeObjectForKey:@"PrefItem"];
    [[Common user].dicQuery removeObjectForKey:@"CatalogItem"];
    [[Common user].dicQuery setObject:item forKey:@"CatalogItem"];
    
    if ([item.carNum intValue] >= 100) {
        
        StatesVC *vc = [[StatesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        vc.catalogItem = item;
        NSLog(@"StatesVC");
    } else {
        ResultsVC *vc = [[ResultsVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        NSLog(@"ResultsVC");
//        NSMutableDictionary *dicQuery = [[NSMutableDictionary alloc] init];
        
//        if (_isLoadWithCompany) {
//            [dicQuery setObject:item.companyCode forKey:PRA_MAKER];
//        } else {
//            [dicQuery setObject:item.bodyCode forKey:PRA_BODY];
//        }
//
//        [dicQuery setObject:item.model forKey:PRA_SHASHU];
        
        
//        [dicQuery setObject:item.grade forKey:PRA_GRADE];
//        [vc loadListForDic:nil];
        
        [vc loadListForCommonQueryDic:[Common user].dicQuery];
    }
    
    
}

#pragma mark - Sqlite

- (void) loadDataWith:(CompanyItem*) companyItem
{
    _isLoadWithCompany = YES;
    self.companyItem = companyItem;
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
}

- (void) loadDataWithBodyItem:(BodyTypeItem*) bodyItem
{
    _isLoadWithCompany = NO;
    self.bodyTypeItem = bodyItem;
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
}

//read data from file DB
- (void)callReadDBWithPath:(NSString *)pathDB {
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:CATALOG_MASTER_DB];
    NSString *tableDB    = CATALOG_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:CATALOG_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSLog(@"count array ===> %d",array.count);
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *newArray = [array sortedArrayUsingDescriptors:sortDescriptors];
           
            NSString *temp = @"~";
            NSString *checkCode = _isLoadWithCompany ? _companyItem.companyCode : _bodyTypeItem.bodyCode;
            NSString *testCode  = _isLoadWithCompany ? @"company_code" : @"body_code";

            for (NSDictionary *item in newArray) {

                if([[item objectForKey:testCode] isEqual:checkCode] &&
                   ![[item objectForKey:@"car_num"] isEqual:@"0"]){
                    CatalogItem *catalogItem = [[CatalogItem alloc] init];
                    
                    catalogItem.catalogId   = [item objectForKey:@"id"];
                    catalogItem.model       = [item objectForKey:@"model"];
                    catalogItem.grade       = [item objectForKey:@"grade"];
                    catalogItem.companyCode = [item objectForKey:@"company_code"];
                    catalogItem.bodyCode    = [item objectForKey:@"body_code"];
                    catalogItem.photo       = [item objectForKey:@"photo"];
                    catalogItem.carNum      = [item objectForKey:@"car_num"];

                    if (![[catalogItem.model substringToIndex:1] isEqualToString:temp]) {
                        [_sections addObject:[catalogItem.model substringToIndex:1]];
                        temp = [catalogItem.model substringToIndex:1];
                    }
                    
                    NSMutableArray *arrayTemp = [_items objectForKey:temp];
                    if (arrayTemp) {
                        [arrayTemp addObject:catalogItem];
                    } else {
                        arrayTemp = [[NSMutableArray alloc] init];
                        [arrayTemp addObject:catalogItem];
                    }
                    
                    [_items setObject:arrayTemp forKey:temp];
                    
                    arrayTemp = nil;
                }
            }
            
            [_tableView reloadData];
            [self downLoadThumb];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        if (!decelerate) {
            [self downLoadThumb];
        }
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self downLoadThumb];
    }
}

#pragma mark - DownloaderDelegate

- (void) downLoadThumb
{
    for (VehiclesCell *cell in _tableView.visibleCells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:indexPath.section]];
        CatalogItem *item = [tempArray objectAtIndex:indexPath.row];
        
        if (!item.image) {
            if (![item.photo isEqualToString:@""]) {
                Downloader *down = [[Downloader alloc] init];
                down.delegate = self;
                down.identifier = indexPath;
                [down get:[NSURL URLWithString:item.photo]];
            } else {
                item.image = [UIImage imageNamed:@"no_image_car.png"];
                cell.imgCell.image = [UIImage imageNamed:@"no_image_car.png"];
            }
        } else {
            
        }
    }
}

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    NSIndexPath *indexPath = (NSIndexPath*)identifier;
    if (indexPath.row < [_items count]) {
        VehiclesCell *cell = (VehiclesCell*) [_tableView cellForRowAtIndexPath:indexPath];
        
        NSMutableArray *tempArray = [_items objectForKey:[_sections objectAtIndex:indexPath.section]];
        CatalogItem *item = [tempArray objectAtIndex:indexPath.row];
        
        if (data.length > 0) {
            cell.imgCell.image = [UIImage imageWithData:data];
            item.image = [UIImage imageWithData:data];
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    
}

#pragma mark - Others

- (BOOL) checkDataListCatalog
{
    return !([_sections count] == 0 && [_items count] == 0);
}

@end
