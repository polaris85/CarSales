//
//  ResultsVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/21/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "ResultsVCPA.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "AutoResizeCellCollectionView.h"
#import "DetailNavigationController.h"

#import "ListCarWS.h"
#import "ListCar2WS.h"
#import "CarItem.h"
#import "CarView.h"

#import "Downloader.h"
#import "LoadingView.h"
#import "MBProgressHUD.h"

#import "CompanyItem.h"
#import "CatalogItem.h"
#import "BodyTypeItem.h"

#import "CDHistory.h"

#import "SortVCPA.h"
#import "SortVC.h"
#import "DetailsVCPA.h"
#import "CarOffVC.h"
#import "FilterVCPA.h"
#import "SearchVCPA.h"


static __weak ResultsVCPA *shared = nil;

@interface ResultsVCPA ()<PSUICollectionViewDataSource, PSUICollectionViewDelegate, PSUICollectionViewDelegateFlowLayout, ListCar2WSDelegate, DownloaderDelegate, UIScrollViewDelegate, SortVCPADelegate, CarOffVCDelegate, FilterVCPADelegate, UIAlertViewDelegate, DetailsVCPADelegate>
{
    __weak PSUICollectionView *_collectionView;
    __weak IBOutlet UILabel *_lbNoData;
    __weak IBOutlet UIView *_viewResults;
    
    int _count, _page, _totalCar,_offset, _indexDownLoadThumb;
    BOOL _isLoading,_isResetList;
    
    BOOL _isFiterChoice,_isLoadDataSussecc,_isResetFilter;
    
    SortType _sortType;
    
    MBProgressHUD *_loadingView;
    
    __weak UIBarButtonItem *_sortButtonItem;
    __weak UIBarButtonItem *_filterButtonItem;
    __weak UIBarButtonItem *_carOffButtonItem;
    
    UIPopoverController *_filterPopover;
    UIPopoverController *_sortPopover;
    UIPopoverController *_carOffPopover;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *commonQueryDic;

@end

@implementation ResultsVCPA

+ (ResultsVCPA *)shared
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
    
    // add barbutton
    self.navigationItem.backBarButtonItem = nil;
    
    UIButton *btInfo =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btInfo setImage:[UIImage imageNamed:@"btn2_nav_mainview.png"] forState:UIControlStateNormal];
    [btInfo addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    [btInfo setFrame:CGRectMake(0, 0, 40, 30)];
    
    UIBarButtonItem *barInfo = [[UIBarButtonItem alloc] initWithCustomView:btInfo];
    
    UIButton *btHF =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btHF setImage:[UIImage imageNamed:@"btn1_nav_mainview.png"] forState:UIControlStateNormal];
    [btHF addTarget:self action:@selector(showHF) forControlEvents:UIControlEventTouchUpInside];
    [btHF setFrame:CGRectMake(0, 0, 105, 30)];
    
    UIBarButtonItem *barHF = [[UIBarButtonItem alloc] initWithCustomView:btHF];
    
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
    
    _sortButtonItem = sortButtonItem;
    _filterButtonItem = filterButtonItem;
    _carOffButtonItem = barHF;
    
    self.navigationItem.rightBarButtonItems = @[barInfo,barHF,filterButtonItem,sortButtonItem];
    
    // init view
    PSUICollectionViewFlowLayout *flowLayout = [[PSUICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(212, 310)];
    
    PSUICollectionView *collectionView = [[PSUICollectionView alloc] initWithFrame:CGRectMake(0, 0, 212*3 + 30, _viewResults.bounds.size.height) collectionViewLayout:flowLayout];
    collectionView.autoresizingMask =  UIViewAutoresizingFlexibleWidth & UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"CarView" bundle:nil] forCellWithReuseIdentifier:@"CarView"];
    
    [_viewResults addSubview:collectionView];
    _collectionView = collectionView;
    
    // init ws
    _loadingView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_loadingView];
    
    // set default value
    _count = 15;
    _page  = 1;
    _offset = 1;
    
    _sortType = SortTypeNoOrder;
    _items = [[NSMutableArray alloc] init];
    _commonQueryDic = [Common user].dicQuery;
    
    // test
    [self loadListForCommonQueryDic:nil];
    if (![Common isPortrait]) {
        CGRect rect = _collectionView.frame;
        rect.size.height = 661;
        _collectionView.frame = rect;
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

- (void) viewWillAppear:(BOOL)animated{
    CGRect rect = _collectionView.frame;
    rect.size.height = _viewResults.frame.size.height;
    _collectionView.frame = rect;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = _collectionView.frame;
    rect.size.height = _viewResults.frame.size.height;
    _collectionView.frame = rect;
    
    if (![Common isPortrait]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - Other

- (void) showInfo{
    [[DetailNavigationController shared] dismissPopover];
    [[SearchVCPA shared] dismissKeyboad];
    
    if ([_sortPopover isPopoverVisible]) {
        [_sortPopover dismissPopoverAnimated:NO];
    }
    
    if ([_filterPopover isPopoverVisible]) {
        [_filterPopover dismissPopoverAnimated:NO];
    }
    
    if ([_carOffPopover isPopoverVisible]) {
        [_carOffPopover dismissPopoverAnimated:NO];
    }
    
    [[AppDelegate shared] showLicense];
}

- (void) showHF {
    [[DetailNavigationController shared] dismissPopover];
    [[SearchVCPA shared] dismissKeyboad];
    
    if ([_filterPopover isPopoverVisible]) {
        [_filterPopover dismissPopoverAnimated:NO];
    }
    
    if ([_sortPopover isPopoverVisible]) {
        [_sortPopover dismissPopoverAnimated:NO];
    }
    
    if (_carOffPopover) {
        if ([_carOffPopover isPopoverVisible]) {
            [_carOffPopover dismissPopoverAnimated:YES];
        } else {
            [_carOffPopover presentPopoverFromBarButtonItem:_carOffButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    } else {
        CarOffVC *vc = [[CarOffVC alloc] init];
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        _carOffPopover = [[UIPopoverController alloc] initWithContentViewController:navi];
        
        vc.popover = _carOffPopover;
        
        [_carOffPopover presentPopoverFromBarButtonItem:_carOffButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) showSort {
    [[DetailNavigationController shared] dismissPopover];
    [[SearchVCPA shared] dismissKeyboad];
    
    if ([_filterPopover isPopoverVisible]) {
        [_filterPopover dismissPopoverAnimated:NO];
    }
    
    if ([_carOffPopover isPopoverVisible]) {
        [_carOffPopover dismissPopoverAnimated:NO];
    }
    
    if (_sortPopover) {
        if ([_sortPopover isPopoverVisible]) {
            [_sortPopover dismissPopoverAnimated:YES];
        } else {
            [_sortPopover presentPopoverFromBarButtonItem:_sortButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    } else {
        SortVCPA *vc = [[SortVCPA alloc] init];
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        _sortPopover = [[UIPopoverController alloc] initWithContentViewController:navi];
        vc.popover = _sortPopover;
        [_sortPopover presentPopoverFromBarButtonItem:_sortButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) showFilter {
    [[DetailNavigationController shared] dismissPopover];
    [[SearchVCPA shared] dismissKeyboad];
    
    if ([_sortPopover isPopoverVisible]) {
        [_sortPopover dismissPopoverAnimated:NO];
    }
    
    if ([_carOffPopover isPopoverVisible]) {
        [_carOffPopover dismissPopoverAnimated:NO];
    }
    
    if (_filterPopover) {
        if ([_filterPopover isPopoverVisible]) {
            [_filterPopover dismissPopoverAnimated:YES];
        } else {
            [_filterPopover presentPopoverFromBarButtonItem:_filterButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            if (_isResetFilter) {
                [[FilterVCPA shared] loadDicQuery:_commonQueryDic];
                _isResetFilter = NO;
            }
        }
    } else {
        FilterVCPA *vc = [[FilterVCPA alloc] init];

        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        _filterPopover = [[UIPopoverController alloc] initWithContentViewController:navi];
        vc.popover = _filterPopover;
        vc.delegate = self;
        [_filterPopover presentPopoverFromBarButtonItem:_filterButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [vc loadDicQuery:_commonQueryDic];
        _isResetFilter = NO;
    }
}

#pragma mark - Other

- (void)dismissPopover
{
    [_sortPopover   dismissPopoverAnimated:YES];
    [_filterPopover dismissPopoverAnimated:YES];
    [_carOffPopover dismissPopoverAnimated:YES];
    [[DetailNavigationController shared] dismissPopover];
    [[SearchVCPA shared] dismissKeyboad];
}

#pragma mark - PSUICollectionViewDataSource, PSUICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    int q = [self.items count] / 3;
    int r = [self.items count] % 3;
    if (r > 0) {
        q++;
    }
    NSLog(@"numberOfSectionsInCollectionView = %d",q);
    return q;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int q = [self.items count] / 3;
    int r = [self.items count] % 3;
    if (r > 0) {
        q++;
    }
    if (section == q-1) {
        return r!=0 ? r : 3;
    } else {
        return 3;
    }
}

- (PSUICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CarView";
    CarView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CarItem *car = self.items[3 * indexPath.section + indexPath.row];
    
    cell.titleLb.text = car.carName;
    cell.bonusLb.text = car.carGrade;
    cell.priceLb.text = car.carPrice;
    
    cell.carNew.hidden = !car.isNew;
    cell.lbDelete.hidden = !car.isDel;
    
    cell.more1.text = car.carYear;
    cell.more2.text = car.carOdd;
    cell.more3.text = car.carPref;
    
    cell.imgMultipeImg.hidden   = !car.isSmallImage;
    
    if (car.thumbImage) {
        cell.carImg.image = car.thumbImage;
    } else {
        cell.carImg.image = [UIImage imageNamed:@"img_no_image.png"];
    }
    
    return cell;
}

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[SearchVCPA shared] dismissKeyboad];
    
    CarItem *item = [_items objectAtIndex:indexPath.section*3 + indexPath.row];
    
    if (!item.isDel) {
        DetailsVCPA *vc = [[DetailsVCPA alloc] init];
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
        vc.carItem = item;
        [vc setFavoriteCar];
        [vc getDetailCarWSByID:item.carId];
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

#pragma mark - ListCar2WSDelegate

- (void)loadListForCommonQueryDic:(NSMutableDictionary*)commonQueryDic
{
    [self.navigationController popViewControllerAnimated:YES];
    _page               = 1;
    _offset             = 1;
    _commonQueryDic     = commonQueryDic;
    _isResetList        = YES;
    _sortType           = SortTypeNoOrder;
    _isResetFilter      = YES;

    [self getListCarWS2ByCommonQueryDic];
}

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
        
    [_loadingView show:YES];
}

- (void)didFailListCar2WSWithError:(Error*)error
{
    [_loadingView hide:YES];
    _lbNoData.hidden = NO;
    
    if ([error.error_msg isEqualToString:ERROR_NETWORK] || [error.error_msg isEqualToString:ERROR_TIMEOUT]) {
        _lbNoData.text = @"ネットワークを検出できませんでした。通信状態を確認 してください。";
    } else {
        _lbNoData.text = @"検索条件に該当する 情報がありませんでした。";
    }
    
    _collectionView.hidden = YES;
    [[AppDelegate shared] setIsDataHistory:NO];
    _isLoadDataSussecc = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                        message:error.error_msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    _isLoading = NO;

    if (_isResetList) {
        _indexDownLoadThumb = 0;
        [_items removeAllObjects];
        _isResetList = NO;
        [_collectionView reloadData];
    }
}

- (void)didSuccessListCar2WSWithListCar:(NSMutableArray*)listCar numCar:(int)numCar total:(int)total
{
    [_loadingView hide:YES];
    NSLog(@"totalCar = %d --- numCar = %d --- return = %d",total,numCar,[listCar count]);
    
    if ([listCar count] == 0 && _offset == 1) {
        _lbNoData.hidden = NO;
        _lbNoData.text = @"検索条件に該当する 情報がありませんでした。";
        _collectionView.hidden = YES;
        [[AppDelegate shared] setIsDataHistory:NO];
        _isLoadDataSussecc = NO;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:@"検索条件に該当する 情報がありませんでした。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        
        _isLoading = NO;
        [_loadingView hide:YES];
        
        if (_isResetList) {
            [_items removeAllObjects];
            _isResetList = NO;
            [_collectionView reloadData];
        }
    } else {
        _lbNoData.hidden = YES;
        _collectionView.hidden = NO;
        _totalCar = total;
        _offset += numCar;
        _isLoading = NO;
        
        [[AppDelegate shared] setIsDataHistory:YES];
        _isLoadDataSussecc = YES;
        
        if (_isResetList) {
            _indexDownLoadThumb = 0;
            [_items removeAllObjects];
            _isResetList = NO;
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointMake(0, 0)];
        }
        
        for (CarItem *item in listCar) {
            [_items addObject:item];
        }
        
        [_collectionView reloadData];
        [self downLoadThumb2];
    }
    
    [_loadingView hide:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _collectionView) {
        if (!decelerate) {
            [self downLoadThumb];
        }
        
        NSLog(@"%f %f %f",_collectionView.contentSize.height,  _collectionView.contentOffset.y, _viewResults.frame.size.height);
        
        int temp = 950;
        
        if (_collectionView.contentSize.height - _collectionView.contentOffset.y <= temp){
            if([_items count] < _totalCar && !_isLoading){
                [self getListCarWS2ByCommonQueryDic];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView) {
        [self downLoadThumb];
        
        NSLog(@"%f %f",_collectionView.contentSize.height - _collectionView.contentOffset.y, _viewResults.frame.size.height);

        
        int temp = 950;
        
        if (_collectionView.contentSize.height - _collectionView.contentOffset.y <= temp){
            if([_items count] < _totalCar && !_isLoading){
                [self getListCarWS2ByCommonQueryDic];
            }
        }
    }
}

#pragma mark - DownloaderDelegate

- (void) downLoadThumb2
{
    for (int i = _indexDownLoadThumb; i < [_items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i%3 inSection:i/3];
        CarItem *item = [_items objectAtIndex:i];
        CarView *cell = (CarView*) [_collectionView cellForItemAtIndexPath:indexPath];
        
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
    
    _indexDownLoadThumb = [_items count] - 1;
}

- (void) downLoadThumb
{    
    for (CarView *cell in _collectionView.visibleCells) {
        
        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
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
    
    if (indexPath.row + indexPath.section *3 < [_items count]) {
        CarView *cell = (CarView*) [_collectionView cellForItemAtIndexPath:indexPath];
        CarItem *item = [_items objectAtIndex:indexPath.row + indexPath.section *3];
        
        if (data.length > 0) {
            cell.carImg.image = [UIImage imageWithData:data];
            item.thumbImage = [UIImage imageWithData:data];
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    NSIndexPath *indexPath = (NSIndexPath*)indentifier;
    
    if (indexPath.row + indexPath.section *3 < [_items count]) {
        CarView *cell = (CarView*) [_collectionView cellForItemAtIndexPath:indexPath];
        CarItem *item = [_items objectAtIndex:indexPath.row + indexPath.section *3];
        
        item.thumbImage = [UIImage imageNamed:@"no_image_car.png"];
        cell.carImg.image = [UIImage imageNamed:@"no_image_car.png"];
    }
}

#pragma mark - SortVCPADelegate

- (void)didChangeSortWithType:(SortType)type
{
    NSLog(@"SortType = %d",type);
    _page               = 1;
    _offset             = 1;
    _sortType           = type;
    _isResetList        = YES;
    [self getListCarWS2ByCommonQueryDic];
}

#pragma mark - CarOffVCDelegate

- (void) showDetailCar:(CarItem*)carItem
{
    DetailsVCPA *vc = [[DetailsVCPA alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.carItem = carItem;
    [vc setFavoriteCar];
    [vc getDetailCarWSByID:carItem.carId];
}

- (void) loadResultDic:(NSMutableDictionary*)dic{
    _page               = 1;
    _offset             = 1;
    _commonQueryDic     = dic;
    _isResetList        = YES;
    _sortType           = SortTypeNoOrder;
    [ResultsVCPA shared].typeload = ResultsTypeLoadHistory;
    [self getListCarWS2ByCommonQueryDic];
}

#pragma mark - FilterVCPADelegate

- (void)didChangeCommonQueryDic:(NSMutableDictionary*)commonQueryDic
{
    _page               = 1;
    _offset             = 1;
    _commonQueryDic     = commonQueryDic;
    _isResetList        = YES;
    [ResultsVCPA shared].typeload = ResultsTypeLoadFilter;
    [self getListCarWS2ByCommonQueryDic];
}



- (void)viewDidUnload {
    _viewResults = nil;
    [super viewDidUnload];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_loadingView hide:YES];
    switch (_typeload) {
        case ResultsTypeLoadNone:
        {
            break;
        }
        case ResultsTypeLoadMaster:
        {
            [[DetailNavigationController shared] showPopover];
            break;
        }
        case ResultsTypeLoadFilter:
        {
            [self showFilter];
            break;
        }
        case ResultsTypeLoadHistory:
        {
            [self showHF];
            break;
        }
        default:
            break;
    }
}

#pragma mark - DetailsVCPADelegate

- (void)carNoDataWithID:(NSString*)carID
{
    for (CarItem *item in _items) {
        if ([item.carId isEqualToString:carID]) {
            item.isDel = YES;
            [_collectionView reloadData];
            break;
        }
    }
}

@end
























