//
//  ResultsVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ResultsVC.h"
#import "DetailsVC.h"
#import "SortVC.h"
#import "FilterVC.h"
#import "Car.h"
#import "CarCell.h"
#import "ResultsCell.h"

#import "ListCarWS.h"
#import "ListCar2WS.h"
#import "AppDelegate.h"
#import "Common.h"
#import "Define.h"
#import "CarItem.h"

#import "Downloader.h"
#import "LoadingView.h"

#import "CompanyItem.h"
#import "CatalogItem.h"
#import "BodyTypeItem.h"

#import "CDHistory.h"


@interface ResultsVC () <UITableViewDataSource, UITableViewDelegate, ListCarWSDelegate,DownloaderDelegate,UIScrollViewDelegate, SortVCDelegate, FilterVCDelegate, UIAlertViewDelegate,ListCar2WSDelegate, DetailsVCDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_lbNoData;
    
    int _count, _page, _totalCar,_offset;
    BOOL _isLoading,_isResetList;
    
    BOOL _isFiterChoice,_isLoadDataSussecc;
    
    SortType _sortType;
    
    LoadingView *_loadingView;
}

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableDictionary *queryDic;

- (void)getListCarWS;

@end

@implementation ResultsVC

- (id)init
{
    self = [super init];
    if (self) {
        UIButton *btSort =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btSort setImage:[UIImage imageNamed:@"btn_navi_sort.png"] forState:UIControlStateNormal];
        [btSort addTarget:self action:@selector(showSort) forControlEvents:UIControlEventTouchUpInside];
        [btSort setFrame:CGRectMake(0, 0, 40, 30)];
        UIBarButtonItem *sortButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btSort];
        
        UIButton *btFilter =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFilter setImage:[UIImage imageNamed:@"btn_navi_filter.png"] forState:UIControlStateNormal];
        [btFilter addTarget:self action:@selector(showFilter) forControlEvents:UIControlEventTouchUpInside];
        [btFilter setFrame:CGRectMake(0, 0, 60, 30)];
        UIBarButtonItem *filterButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:btFilter];
        
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *flexible2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem,flexible, filterButtonItem, sortButtonItem,flexible2];
    }
    
    // set default value
    _count = 10;
    _page  = 1;
    _offset = 1;
    _sortType = SortTypeNoOrder;
    _items = [[NSMutableArray alloc] init];
    _queryDic = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = RESULTS_TITLE;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loadingView];
    
    _commonQueryDic = [Common user].dicQuery;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSLog(@"viewWillAppear");
    
    if (_isFiterChoice && !_isLoadDataSussecc) {
        
        NSLog(@"viewWillAppear -- if");
        CDHistory *item = [[AppDelegate shared] getLastestHistoryisData];
        if (item) {
            NSLog(@"viewWillAppear -- item");
            [self loadListForCommonQueryDic:[self coverToQueryDic:[Common dictionaryFormData:item.dicQuery]]];
        }
    }
}

#pragma mark - Others

- (NSMutableDictionary*) coverToQueryDic:(NSDictionary*)dicCommon
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in dicCommon.allKeys) {
        if ([key isEqualToString:@"CompanyItem"]) {
            
            [dic setObject:[CompanyItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else if ([key isEqualToString:@"BodyTypeItem"]) {
            
            [dic setObject:[BodyTypeItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else if ([key isEqualToString:@"CatalogItem"]) {
            
            [dic setObject:[CatalogItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else {
            [dic setObject:[dicCommon objectForKey:key] forKey:key];
        }
    }
    
    return dic;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 93;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultsCell" owner:self options:nil] lastObject];
    }
    
    CarItem *car = self.items[indexPath.row];
    //    cell.carImg.image = [UIImage imageNamed:car.icon];
    
    cell.titleLb.text = car.carName;
    cell.bonusLb.text = car.carGrade;
    cell.priceLb.text = car.carPrice;
    
    cell.carNew.hidden = !car.isNew;
    cell.lbDelete.hidden = !car.isDel;
    
    cell.more1.text = car.carYear;
    cell.more2.text = car.carOdd;
    cell.more3.text = car.carPref;
    
    cell.multipeImg.hidden      = !car.isSmallImage;
    cell.imgMultipeImg.hidden   = !car.isSmallImage;
    
    if (car.thumbImage) {
        cell.carImg.image = car.thumbImage;
    } else {
        cell.carImg.image = [UIImage imageNamed:@"img_no_image.png"];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CarItem *item = [_items objectAtIndex:indexPath.row];
    
    if (!item.isDel) {
        DetailsVC *vc = [[DetailsVC alloc] init];
        vc.delegate = self;
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        
        
        vc.carItem = item;
        if(![Common isIOS7]){

        [vc setFavoriteCar];
        [vc getDetailCarWSByID:item.carId];
        }
    }
        
    
}

#pragma mark - Action

- (void)showSort
{
    SortVC *vc = [[SortVC alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFilter
{
    _isFiterChoice = YES;
    FilterVC *vc = [[FilterVC alloc] init];
    vc.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
    [vc loadDicQuery:_commonQueryDic];
}

#pragma mark - ListCarWSDelegate

- (void)loadListForSearchByKeyword:(NSString*)keyWord
{
    _isResetList = YES;
    _offset      = 1;
    _page        = 1;
    //    [self getListCarWSByCommonQueryDic];
    [self getListCarWS2ByCommonQueryDic];
}

- (void)loadListForDic:(NSMutableDictionary*)dicQuery
{
    _isResetList = YES;
    [self getListCarWS2ByCommonQueryDic];
}

- (void)loadListForCommonQueryDic:(NSMutableDictionary*)commonQueryDic
{
    _page               = 1;
    _offset             = 1;
    _commonQueryDic     = commonQueryDic;
    _isResetList        = YES;
    
    //    [self getListCarWSByCommonQueryDic];
    [self getListCarWS2ByCommonQueryDic];
    
    
}

- (void)getListCarWSByCommonQueryDic
{
    _isLoading = YES;
    NSString *queryStr = @"";
    NSString *nameQueryCoreData = @"";
    BOOL _isMaker = NO;
    
    // query string
    
    // add Sort
    if (!(_sortType == SortTypeNone || _sortType == SortTypeNoOrder)) {
        queryStr = [queryStr stringByAppendingFormat:@"&order=%d",_sortType];
    }
    
    // add Query String
    // 0
    if ([_commonQueryDic objectForKey:@"CompanyItem"]) {
        _isMaker = YES;
        CompanyItem *_companyItem = [_commonQueryDic objectForKey:@"CompanyItem"];
        queryStr = [queryStr stringByAppendingFormat:@"&maker=%@",_companyItem.companyCode];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingString:_companyItem.companyName];
    }
    
    // 1
    if ([_commonQueryDic objectForKey:@"CatalogItem"]) {
        CatalogItem *_catalogItem = [_commonQueryDic objectForKey:@"CatalogItem"];
        
        NSString *shashu = [[AppDelegate shared] getShashuCodeName:_catalogItem.model companyCode:_catalogItem.companyCode];
        
        if (shashu) {
            queryStr = [queryStr stringByAppendingFormat:@"&shashu=%@",shashu];
            if (!_isMaker) {
                queryStr = [queryStr stringByAppendingFormat:@"&maker=%@",_catalogItem.companyCode];
            }
        } else {
            queryStr = [queryStr stringByAppendingFormat:@"&grade=%@",_catalogItem.grade];
        }
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_catalogItem.model];
    }
    
    // 2
    if ([_commonQueryDic objectForKey:@"PrefItem"]) {
        NSMutableDictionary *_dicPref = [_commonQueryDic objectForKey:@"PrefItem"];
        NSString *temp = @"";
        
        for (int i = 0; i < [_dicPref.allValues count]; i++) {
            temp = [temp stringByAppendingString:_dicPref.allValues[i]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_dicPref.allKeys[i]];
            
            if (i < [_dicPref.allValues count] - 1) {
                temp = [temp stringByAppendingString:@","];
            }
        }
        
        queryStr = [queryStr stringByAppendingFormat:@"&pref=%@",temp];
    }
    
    // 3
    if ([_commonQueryDic objectForKey:@"PriceItem"]) {
        NSMutableDictionary *price = [_commonQueryDic objectForKey:@"PriceItem"];
        
        if (![[price objectForKey:@"priceNameMin"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&price_min=%@",[NSString stringWithFormat:@"%@0000",[price objectForKey:@"priceNameMin"]]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMin"]]];
        }
        
        if (![[price objectForKey:@"priceNameMax"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&price_max=%@",[NSString stringWithFormat:@"%@0000",[price objectForKey:@"priceNameMax"]]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",[NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMax"]]];
        }
        
    }
    
    // 4
    if ([_commonQueryDic objectForKey:@"YearItem"]) {
        NSMutableDictionary *year = [_commonQueryDic objectForKey:@"YearItem"];
        
        if (![[year objectForKey:@"yearMin"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&year_min=%@",[year objectForKey:@"yearMin"]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMin"]]];
        }
        
        if (![[year objectForKey:@"yearMax"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&year_max=%@",[year objectForKey:@"yearMax"]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",[NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMax"]]];
        }
    }
    
    // 5
    if ([_commonQueryDic objectForKey:@"OddItem"]) {
        NSMutableDictionary *oddItem = [_commonQueryDic objectForKey:@"OddItem"];
        
        NSString *temp = @"";
        
        if (![[oddItem objectForKey:@"oddMin"] isEqualToString:TEXT_DONT_SET]) {
            temp = [oddItem objectForKey:@"oddMin"];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",temp];
            
            temp = [temp stringByReplacingOccurrencesOfString:@"km" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"万" withString:@"0000"];
            queryStr = [queryStr stringByAppendingFormat:@"&odd_min=%@",temp];
        }
        
        if (![[oddItem objectForKey:@"oddMax"] isEqualToString:TEXT_DONT_SET]) {
            temp = [oddItem objectForKey:@"oddMax"];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",temp];
            
            temp = [temp stringByReplacingOccurrencesOfString:@"km" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"万" withString:@"0000"];
            queryStr = [queryStr stringByAppendingFormat:@"&odd_max=%@",temp];
        }
        
    }
    
    // 6
    if ([_commonQueryDic objectForKey:@"ColorItem"]) {
        NSMutableDictionary *_dicColor = [_commonQueryDic objectForKey:@"ColorItem"];
        
        NSString *temp = @"";
        for (int i = 0; i < [_dicColor.allValues count]; i++) {
            temp = [temp stringByAppendingString:_dicColor.allValues[i]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_dicColor.allKeys[i]];
            
            if (i < [_dicColor.allValues count] - 1) {
                temp = [temp stringByAppendingString:@","];
            }
        }
        
        queryStr = [queryStr stringByAppendingFormat:@"&color=%@",temp];
    }
    
    // 7
    if ([_commonQueryDic objectForKey:@"BodyTypeItem"]) {
        BodyTypeItem *_bodyTypeItem = [_commonQueryDic objectForKey:@"BodyTypeItem"];
        
        queryStr = [queryStr stringByAppendingFormat:@"&body=%@",_bodyTypeItem.bodyCode];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_bodyTypeItem.bodyName];
    }
    
    // 8
    if ([_commonQueryDic objectForKey:@"MissionItem"]) {
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[_commonQueryDic objectForKey:@"MissionItem"]];
        
        if ([[_commonQueryDic objectForKey:@"MissionItem"] isEqualToString:@"AT"]) {
            queryStr = [queryStr stringByAppendingString:@"&mission=1"];
        } else if ([[_commonQueryDic objectForKey:@"MissionItem"] isEqualToString:@"MT"]) {
            queryStr = [queryStr stringByAppendingString:@"&mission=2"];
        }
    }
    
    //9
    if ([_commonQueryDic objectForKey:@"Keyword"]) {
        queryStr = [queryStr stringByAppendingFormat:@"&keyword=%@",[_commonQueryDic objectForKey:@"Keyword"]];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[_commonQueryDic objectForKey:@"Keyword"]];
    }
    
    // coredata
    if ([nameQueryCoreData isEqualToString:@""]) {
        nameQueryCoreData = @"すべての車";
    }
    [[AppDelegate shared] addHistoryWithName:nameQueryCoreData strQuery:queryStr dicQuery:[self coverDicToSaveCoreData:_commonQueryDic]];
    
    // call WS
    ListCarWS *listCarWS = [[ListCarWS alloc] init];
    listCarWS.delegate = self;
    [listCarWS getListCarWithQueryString:queryStr count:_count page:_page];
    [_loadingView show];
}

- (NSDictionary*)coverDicToSaveCoreData:(NSMutableDictionary*)dicCommon
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in dicCommon.allKeys) {
        if ([key isEqualToString:@"CompanyItem"]) {
            
            CompanyItem *item = [dicCommon objectForKey:key];
            [dic setObject:[item itemToDic] forKey:key];
            
        } else if ([key isEqualToString:@"BodyTypeItem"]) {
            
            BodyTypeItem *item = [dicCommon objectForKey:key];
            [dic setObject:[item itemToDic] forKey:key];
            
        } else if ([key isEqualToString:@"CatalogItem"]) {
            
            CatalogItem *item = [dicCommon objectForKey:key];
            [dic setObject:[item itemToDic] forKey:key];
            
        } else {
            [dic setObject:[dicCommon objectForKey:key] forKey:key];
        }
    }
    
    return dic;
}

- (void)getListCarWSByQuery
{
    _isLoading = YES;
    NSString *queryStr = @"";
    
    // query string
    
    // add Sort
    if (!(_sortType == SortTypeNone || _sortType == SortTypeNoOrder)) {
        queryStr = [queryStr stringByAppendingFormat:@"&order=%d",_sortType];
    }
    
    // add Query String
    NSArray *keys    = _queryDic.allKeys;
    
    for (NSString *key  in keys) {
        if ([key isEqualToString:PRA_KEYWORD]) {
            queryStr = [queryStr stringByAppendingFormat:@"&keyword=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_MAKER]){
            queryStr = [queryStr stringByAppendingFormat:@"&maker=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_BODY]){
            queryStr = [queryStr stringByAppendingFormat:@"&body=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_SHASHU]){
            queryStr = [queryStr stringByAppendingFormat:@"&shashu=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_GRADE]){
            queryStr = [queryStr stringByAppendingFormat:@"&grade=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_PREF]){
            queryStr = [queryStr stringByAppendingFormat:@"&pref=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_PRICE_MIN]){
            queryStr = [queryStr stringByAppendingFormat:@"&price_min=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_PRICE_MAX]){
            queryStr = [queryStr stringByAppendingFormat:@"&price_max=%@",[_queryDic objectForKey:key]];
        } else if ([key isEqualToString:PRA_MAKER]){
            queryStr = [queryStr stringByAppendingFormat:@"&maker=%@",[_queryDic objectForKey:key]];
        }
        
        
    }
    
    ListCarWS *listCarWS = [[ListCarWS alloc] init];
    listCarWS.delegate = self;
    [listCarWS getListCarWithQueryString:queryStr count:_count page:_page];
    [_loadingView show];
}

- (void)getListCarWS
{
    _isLoading = YES;
    ListCarWS *listCarWS = [[ListCarWS alloc] init];
    listCarWS.delegate = self;
    [listCarWS getTotalCarWithCount:_count page:_page];
    [_loadingView show];
}

- (void)didFailWithError:(Error*)error
{
    //    [Common showAlert:error.error_msg];
    _lbNoData.hidden = NO;
    _tableView.hidden = YES;
    [[AppDelegate shared] setIsDataHistory:NO];
    _isLoadDataSussecc = NO;
    
    NSLog(@"error code : %d - %@",error.error_id,error.error_msg);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                        message:@"検索条件に該当する 情報がありませんでした。"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    _isLoading = NO;
    [_loadingView hide];
    
    if (_isResetList) {
        [_items removeAllObjects];
        _isResetList = NO;
        [_tableView reloadData];
    }
    
}

- (void)didSuccessWithListCar:(NSMutableArray*)listCar totalCar:(int)totalCar offset:(int)offset
{
    NSLog(@"totalCar = %d --- offset = %d --- return = %d",totalCar,offset,[listCar count]);
    _lbNoData.hidden = YES;
    _tableView.hidden = NO;
    _totalCar = totalCar;
    _page ++;
    _isLoading = NO;
    
    [[AppDelegate shared] setIsDataHistory:YES];
    _isLoadDataSussecc = YES;
    
    if (_isResetList) {
        [_items removeAllObjects];
        _isResetList = NO;
    }
    
    for (CarItem *item in listCar) {
        [_items addObject:item];
    }
    
    [_tableView reloadData];
    [self downLoadThumb];
    [_loadingView hide];
}

#pragma mark - ListCar2WSDelegate

- (void)getListCarWS2ByCommonQueryDic
{
    _isLoading = YES;
    NSString *queryStr = @"";
    NSString *nameQueryCoreData = @"";
    BOOL _isMaker = NO;
    
    // query string
    
    // add Sort
    if (!(_sortType == SortTypeNone || _sortType == SortTypeNoOrder)) {
        queryStr = [queryStr stringByAppendingFormat:@"&order=%d",_sortType];
    }
    
    // add Query String
    // 0
    if ([_commonQueryDic objectForKey:@"CompanyItem"]) {
        _isMaker = YES;
        CompanyItem *_companyItem = [_commonQueryDic objectForKey:@"CompanyItem"];
        queryStr = [queryStr stringByAppendingFormat:@"&brand=%@",_companyItem.companyCode];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingString:_companyItem.companyName];
    }
    
    // 1
    if ([_commonQueryDic objectForKey:@"CatalogItem"]) {
        CatalogItem *_catalogItem = [_commonQueryDic objectForKey:@"CatalogItem"];
        queryStr = [queryStr stringByAppendingFormat:@"&model=%@",_catalogItem.model];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_catalogItem.model];
    }
    
    // 2
    if ([_commonQueryDic objectForKey:@"PrefItem"]) {
        NSMutableDictionary *_dicPref = [_commonQueryDic objectForKey:@"PrefItem"];
        NSString *temp = @"";
        
        for (int i = 0; i < [_dicPref.allValues count]; i++) {
            temp = [temp stringByAppendingString:_dicPref.allValues[i]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_dicPref.allKeys[i]];
            
            if (i < [_dicPref.allValues count] - 1) {
                temp = [temp stringByAppendingString:@","];
            }
        }
        
        queryStr = [queryStr stringByAppendingFormat:@"&pref=%@",temp];
    } else {
        queryStr = [queryStr stringByAppendingString:@"&large_area=1,2,3,4,5,6,7,8,9"];
    }
    
    // 3
    if ([_commonQueryDic objectForKey:@"PriceItem"]) {
        NSMutableDictionary *price = [_commonQueryDic objectForKey:@"PriceItem"];
        
        if (![[price objectForKey:@"priceNameMin"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&price_min=%@",[NSString stringWithFormat:@"%@0000",[price objectForKey:@"priceNameMin"]]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMin"]]];
        }
        
        if (![[price objectForKey:@"priceNameMax"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&price_max=%@",[NSString stringWithFormat:@"%@0000",[price objectForKey:@"priceNameMax"]]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",[NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMax"]]];
        }
        
    }
    
    // 4
    if ([_commonQueryDic objectForKey:@"YearItem"]) {
        NSMutableDictionary *year = [_commonQueryDic objectForKey:@"YearItem"];
        
        if (![[year objectForKey:@"yearMin"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&year_min=%@",[year objectForKey:@"yearMin"]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMin"]]];
        }
        
        if (![[year objectForKey:@"yearMax"] isEqualToString:TEXT_DONT_SET]) {
            queryStr = [queryStr stringByAppendingFormat:@"&year_max=%@",[year objectForKey:@"yearMax"]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",[NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMax"]]];
        }
    }
    
    // 5
    if ([_commonQueryDic objectForKey:@"OddItem"]) {
        NSMutableDictionary *oddItem = [_commonQueryDic objectForKey:@"OddItem"];
        
        NSString *temp = @"";
        
        if (![[oddItem objectForKey:@"oddMin"] isEqualToString:TEXT_DONT_SET]) {
            temp = [oddItem objectForKey:@"oddMin"];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",temp];
            
            temp = [temp stringByReplacingOccurrencesOfString:@"km" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"万" withString:@"0000"];
            queryStr = [queryStr stringByAppendingFormat:@"&odd_min=%@",temp];
        }
        
        if (![[oddItem objectForKey:@"oddMax"] isEqualToString:TEXT_DONT_SET]) {
            temp = [oddItem objectForKey:@"oddMax"];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@"~%@",temp];
            
            temp = [temp stringByReplacingOccurrencesOfString:@"km" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"万" withString:@"0000"];
            queryStr = [queryStr stringByAppendingFormat:@"&odd_max=%@",temp];
        }
        
    }
    
    // 6
    if ([_commonQueryDic objectForKey:@"ColorItem"]) {
        NSMutableDictionary *_dicColor = [_commonQueryDic objectForKey:@"ColorItem"];
        
        NSString *temp = @"";
        for (int i = 0; i < [_dicColor.allValues count]; i++) {
            temp = [temp stringByAppendingString:_dicColor.allValues[i]];
            
            nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_dicColor.allKeys[i]];
            
            if (i < [_dicColor.allValues count] - 1) {
                temp = [temp stringByAppendingString:@","];
            }
        }
        
        queryStr = [queryStr stringByAppendingFormat:@"&color=%@",temp];
    }
    
    // 7
    if ([_commonQueryDic objectForKey:@"BodyTypeItem"]) {
        BodyTypeItem *_bodyTypeItem = [_commonQueryDic objectForKey:@"BodyTypeItem"];
        
        queryStr = [queryStr stringByAppendingFormat:@"&body=%@",_bodyTypeItem.bodyCode];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",_bodyTypeItem.bodyName];
    }
    
    // 8
    if ([_commonQueryDic objectForKey:@"MissionItem"]) {
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[_commonQueryDic objectForKey:@"MissionItem"]];
        
        if ([[_commonQueryDic objectForKey:@"MissionItem"] isEqualToString:@"AT"]) {
            queryStr = [queryStr stringByAppendingString:@"&mission=1"];
        } else if ([[_commonQueryDic objectForKey:@"MissionItem"] isEqualToString:@"MT"]) {
            queryStr = [queryStr stringByAppendingString:@"&mission=2"];
        }
    }
    
    //9
    if ([_commonQueryDic objectForKey:@"Keyword"]) {
        queryStr = [queryStr stringByAppendingFormat:@"&keyword=%@",[_commonQueryDic objectForKey:@"Keyword"]];
        
        nameQueryCoreData = [nameQueryCoreData stringByAppendingFormat:@" %@",[_commonQueryDic objectForKey:@"Keyword"]];
    }
    
    // coredata
    if ([nameQueryCoreData isEqualToString:@""]) {
        nameQueryCoreData = @"すべての車";
    }
    [[AppDelegate shared] addHistoryWithName:nameQueryCoreData strQuery:queryStr dicQuery:[self coverDicToSaveCoreData:_commonQueryDic]];
    
    // call WS 2
    ListCar2WS *listCarWS2 = [[ListCar2WS alloc] init];
    listCarWS2.delegate = self;
    [listCarWS2 getListCarWithQueryString:queryStr count:_count offset:_offset];
    [_loadingView show];
}

- (void)didFailListCar2WSWithError:(Error*)error
{
    [_loadingView hide];
    _lbNoData.hidden = NO;
    
    if ([error.error_msg isEqualToString:ERROR_NETWORK] || [error.error_msg isEqualToString:ERROR_TIMEOUT]) {
        _lbNoData.text = @"ネットワークを検出できませんでした。通信状態を確認 してください。";
    } else {
        _lbNoData.text = @"検索条件に該当する 情報がありませんでした。";
    }
    
    _tableView.hidden = YES;
    [[AppDelegate shared] setIsDataHistory:NO];
    _isLoadDataSussecc = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                        message:error.error_msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    _isLoading = NO;
    [_loadingView hide];
    
    if (_isResetList) {
        [_items removeAllObjects];
        _isResetList = NO;
        [_tableView reloadData];
    }
}

- (void)didSuccessListCar2WSWithListCar:(NSMutableArray*)listCar numCar:(int)numCar total:(int)total
{
    [_loadingView hide];
    NSLog(@"totalCar = %d --- numCar = %d --- return = %d",total,numCar,[listCar count]);
    
    if ([listCar count] == 0 && _offset == 1) {
        _lbNoData.hidden = NO;
        _lbNoData.text = @"検索条件に該当する 情報がありませんでした。";
        _tableView.hidden = YES;
        [[AppDelegate shared] setIsDataHistory:NO];
        _isLoadDataSussecc = NO;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:@"検索条件に該当する 情報がありませんでした。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        
        _isLoading = NO;
        [_loadingView hide];
        
        if (_isResetList) {
            [_items removeAllObjects];
            _isResetList = NO;
            [_tableView reloadData];
        }
    } else {
        _lbNoData.hidden = YES;
        _tableView.hidden = NO;
        _totalCar = total;
        _offset += numCar;
        _isLoading = NO;
        
        [[AppDelegate shared] setIsDataHistory:YES];
        _isLoadDataSussecc = YES;
        
        if (_isResetList) {
            [_items removeAllObjects];
            _isResetList = NO;
            [_tableView reloadData];
        }
        
        for (CarItem *item in listCar) {
            [_items addObject:item];
        }
        
        [_tableView reloadData];
        [self downLoadThumb];
    }
    
    [_loadingView hide];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_isFiterChoice) {
        [self showFilter];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        if (!decelerate) {
            [self downLoadThumb];
        }
        
        if (_tableView.contentSize.height - _tableView.contentOffset.y <= self.view.frame.size.height){
            if([_items count] < _totalCar && !_isLoading){
                //    [self getListCarWSByCommonQueryDic];
                [self getListCarWS2ByCommonQueryDic];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self downLoadThumb];
        
        if (_tableView.contentSize.height - _tableView.contentOffset.y <= self.view.frame.size.height){
            if([_items count] < _totalCar && !_isLoading){
                //    [self getListCarWSByCommonQueryDic];
                [self getListCarWS2ByCommonQueryDic];
            }
        }
    }
}

#pragma mark - DownloaderDelegate

- (void) downLoadThumb
{
    for (ResultsCell *cell in _tableView.visibleCells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        CarItem *item = [_items objectAtIndex:indexPath.row];
        
        if (!item.thumbImage) {
            if (![item.thumd isEqualToString:@""]) {
                Downloader *down = [[Downloader alloc] init];
                down.delegate = self;
                down.identifier = indexPath;
                [down get:[NSURL URLWithString:item.thumd]];
            } else {
                item.thumbImage = [UIImage imageNamed:@"no_image_car.png"];
                cell.carImg.image = [UIImage imageNamed:@"no_image_car.png"];
            }
        } else {
            
        }
    }
}

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    NSIndexPath *indexPath = (NSIndexPath*)identifier;
    if (indexPath.row < [_items count]) {
        ResultsCell *cell = (ResultsCell*) [_tableView cellForRowAtIndexPath:indexPath];
        CarItem *item = [_items objectAtIndex:indexPath.row];
        
        if (data.length > 0) {
            cell.carImg.image = [UIImage imageWithData:data];
            item.thumbImage = [UIImage imageWithData:data];
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    
}

#pragma mark - SortVCDelegate

- (void)didChangeSortWithType:(SortType)type
{
    NSLog(@"SortType = %d",type);
    _page               = 1;
    _offset             = 1;
    _sortType           = type;
    _isResetList        = YES;
    //    [self getListCarWSByCommonQueryDic];
    [self getListCarWS2ByCommonQueryDic];
}

#pragma mark - FilterVCDelegate
- (void)didChangeCommonQueryDic:(NSMutableDictionary*)commonQueryDic
{
    _page               = 1;
    _offset             = 1;
    _commonQueryDic     = commonQueryDic;
    _isResetList        = YES;
    
    //    [self getListCarWSByCommonQueryDic];
    [self getListCarWS2ByCommonQueryDic];
}

#pragma mark - DetailsVCDelegate

- (void)carNoDataWithID:(NSString*)carID
{
    for (CarItem *item in _items) {
        if ([item.carId isEqualToString:carID]) {
            item.isDel = YES;
            [_tableView reloadData];
            break;
        }
    }
}

@end
