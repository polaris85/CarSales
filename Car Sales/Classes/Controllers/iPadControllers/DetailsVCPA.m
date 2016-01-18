//
//  DetailsVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "DetailsVCPA.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "OuterShadowView.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

#import "CarDetailWS.h"
#import "ShopDetailWS.h"
#import "PhotoItem.h"
#import "Downloader.h"
#import "LoadingView.h"
#import "MBProgressHUD.h"

#import "CDFavorites.h"

#import "JT2PopupAlertView.h"
#import "DetailsPACell.h"
#import "DetailCell2.h"
#import "DetailsHeaderView.h"
#import "ViewShopVC.h"


@interface DetailsVCPA ()<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, CarDetailWSDelegate, DownloaderDelegate, ShopDetailWSDelegate,UIAlertViewDelegate>
{
     MBProgressHUD *_loadingView;
    
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIView *_viewInfoCar;
    __weak IBOutlet UIButton *_btOpenViewInfo;
    
    __weak IBOutlet UIView *_viewToast;
    __weak IBOutlet UILabel *_lbToast;
    
    __weak IBOutlet UIScrollView *_imageScroll;
    __weak IBOutlet UIView *_viewHeader;
    __weak IBOutlet UILabel *_lbTitleCar;
    __weak IBOutlet UIView *_viewThumbs;
    
    __weak IBOutlet UILabel *_lbPriceDisp;
    __weak IBOutlet UILabel *_lbTotalPrice;
    
    __weak IBOutlet UILabel *_lbDescription;
    __weak IBOutlet UIButton *_btNextScrollImage;
    __weak IBOutlet UIButton *_btBackScrollImage;
    __weak IBOutlet UITextView *_tvDes;
    
    NSMutableArray *_items;
    
    NSMutableArray *_sessions;
    
    NSMutableArray *_keys;
    NSMutableArray *_values;
    
    NSMutableArray *_images;
    
    MFMailComposeViewController *_mailComposeViewController;
    BOOL _isShowEmail, _isHidenViewInfoCar, _isCloseViewInfoCar;
    int _imageIndex;
}

@property(nonatomic,strong) NSString *carId;
@property(nonatomic,strong) NSMutableDictionary *userCar;

- (IBAction)showAds:(id)sender;
- (IBAction)showEmail:(id)sender;
- (IBAction)backScrollImage:(id)sender;
- (IBAction)nextScrollImage:(id)sender;


// view info
@property (nonatomic, weak) IBOutlet UILabel *titleLb;
@property (nonatomic, weak) IBOutlet UILabel *bonusLb;
@property (nonatomic, weak) IBOutlet UILabel *priceLb;
@property (nonatomic, weak) IBOutlet UILabel *more1;
@property (nonatomic, weak) IBOutlet UILabel *more2;
@property (nonatomic, weak) IBOutlet UILabel *more3;
@property (nonatomic, weak) IBOutlet UILabel *multipeImg;
@property (nonatomic, weak) IBOutlet UIImageView *carImg;

- (IBAction)closeViewInfoCar:(id)sender;
- (IBAction)openViewInfoCar:(id)sender;


@end

@implementation DetailsVCPA

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
    UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btFavirote setImage:[UIImage imageNamed:@"btn_iPad_add_favorite.png"] forState:UIControlStateNormal];
    [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
    [btFavirote setFrame:CGRectMake(0, 0, 105, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btFavirote];
    
    _loadingView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_loadingView];
    
    _items = [[NSMutableArray alloc] init];
    
    _sessions = [[NSMutableArray alloc] init];
    _keys = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] init];
    
    _images = [[NSMutableArray alloc] init];
    
    // set up Recognizer with tag
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    imageTapRecognizer.numberOfTapsRequired = 1;
    imageTapRecognizer.numberOfTouchesRequired = 1;
    [_viewThumbs addGestureRecognizer:imageTapRecognizer];
    
    _isHidenViewInfoCar = YES;
    _viewInfoCar.alpha = 0;
    _btOpenViewInfo.hidden = YES;
    
    _viewToast.alpha = 0.0;
    [_viewToast.layer setCornerRadius:10.0f];
    [_viewToast.layer setMasksToBounds:YES];
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    _lbTitleCar = nil;
    _lbPriceDisp = nil;
    _lbTotalPrice = nil;
    _lbDescription = nil;
    _tvDes = nil;
    _viewHeader = nil;
    _btNextScrollImage = nil;
    _btBackScrollImage = nil;
    _viewThumbs = nil;
    _viewToast = nil;
    _lbToast = nil;
    [super viewDidUnload];
}

#pragma mark - Others

- (void) backVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addToFavorites
{
    UIButton *btDeleteFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btDeleteFavirote setImage:[UIImage imageNamed:@"btn_iPad_del_favorite.png"] forState:UIControlStateNormal];
    [btDeleteFavirote addTarget:self action:@selector(deleteToFavorites) forControlEvents:UIControlEventTouchUpInside];
    [btDeleteFavirote setFrame:CGRectMake(0, 0, 105, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btDeleteFavirote];
    
    // add coredata
    AppDelegate *appDelegate = [AppDelegate shared];
    CDFavorites *cdFavorites = (CDFavorites *)[NSEntityDescription insertNewObjectForEntityForName:@"CDFavorites"
                                                                            inManagedObjectContext:appDelegate.managedObjectContext];
    cdFavorites.carId = _carItem.carId;
    cdFavorites.carName = _carItem.carName;
    cdFavorites.carGrade = _carItem.carGrade;
    cdFavorites.carPrice = _carItem.carPrice;
    cdFavorites.carYear = _carItem.carYear;
    cdFavorites.carOdd = _carItem.carOdd;
    cdFavorites.carPref = _carItem.carPref;
    cdFavorites.thumd = _carItem.thumd;
    cdFavorites.isNew = _carItem.isNew;
    cdFavorites.isSmallImage = _carItem.isSmallImage;
    
    cdFavorites.created = [[NSDate date] timeIntervalSince1970];
    
    [appDelegate saveContext];
    
    [self showToast:@"お気に入りに登録しました。" delay:2.0];
//    [JT2PopupAlertView showPopupAlertViewWithString:@"お気に入りに登録しました。" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
}

- (void)deleteToFavorites
{
    AppDelegate *appDelegate = [AppDelegate shared];
    if ([appDelegate deleteCarFavoritesWithID:_carItem.carId]) {
        [self showToast:@"お気に入りから削除しました。" delay:2.0];
//        [JT2PopupAlertView showPopupAlertViewWithString:@"お気に入りから削除しました。" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
        
        UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFavirote setImage:[UIImage imageNamed:@"btn_iPad_add_favorite.png"] forState:UIControlStateNormal];
        [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btFavirote setFrame:CGRectMake(0, 0, 105, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btFavirote];
    } else {
        [self showToast:@"Can't delete car in favorite" delay:2.0];
//        [JT2PopupAlertView showPopupAlertViewWithString:@"Can't delete car in favorite" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
    }
}

- (void)showToast:(NSString*)message delay:(float)delay
{
    _lbToast.text = message;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    _viewToast.alpha = 1.0;
    
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(dismissToast)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)dismissToast{
    _lbToast.text = @"";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    _viewToast.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void) setFavoriteCar
{
    if ([[AppDelegate shared] isExitsCarFavoritesWithID:_carItem.carId]) {
        UIButton *btDeleteFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btDeleteFavirote setImage:[UIImage imageNamed:@"btn_iPad_del_favorite.png"] forState:UIControlStateNormal];
        [btDeleteFavirote addTarget:self action:@selector(deleteToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btDeleteFavirote setFrame:CGRectMake(0, 0, 105, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btDeleteFavirote];
    } else {
        UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFavirote setImage:[UIImage imageNamed:@"btn_iPad_add_favorite.png"] forState:UIControlStateNormal];
        [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btFavirote setFrame:CGRectMake(0, 0, 105, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btFavirote];
    }
    
    [[AppDelegate shared] addCarRecentsWithCarItem:_carItem];
    
    [self loadCellInView:_carItem.carName
                   bonus:_carItem.carGrade
                   price:_carItem.carPrice
                   more1:_carItem.carYear
                   more2:_carItem.carOdd
                   more3:_carItem.carPref
          isMultipeImage:!_carItem.isSmallImage
                carImage:_carItem.thumbImage];
}

- (void) loadCellInView:(NSString*)title
                  bonus:(NSString*)bonus
                  price:(NSString*)price
                  more1:(NSString*)more1
                  more2:(NSString*)more2
                  more3:(NSString*)more3
         isMultipeImage:(BOOL)isMultipeImage
               carImage:(UIImage*)carImage
{
    _titleLb.text = title;
    _bonusLb.text = bonus;
    _priceLb.text = price;
    
    _more1.text = more1;
    _more2.text = more2;
    _more3.text = more3;
    
    _multipeImg.hidden = isMultipeImage;
    
    if (carImage) {
        _carImg.image = carImage;
    } else {
        Downloader *downloader = [[Downloader alloc] init];
        downloader.delegate = self;
        downloader.identifier = @"-100";
        [downloader get:[NSURL URLWithString:_carItem.thumd]];
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sessions count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 960, 25)];
    viewHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *imgBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_section_mainview.png"]];
    imgBG.frame = viewHeader.frame;
    imgBG.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [viewHeader addSubview:imgBG];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 960, 25)];

    title.text = [_sessions objectAtIndex:section];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:12.0];
    title.textColor = [UIColor whiteColor];
    title.shadowOffset = CGSizeMake(1.0, 1.0);
    title.shadowColor = [UIColor grayColor];
    title.textAlignment = UITextAlignmentCenter;
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [viewHeader addSubview:title];
    
    
    return viewHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 3) {
        return ([[_keys objectAtIndex:section] count] %2 == 0) ? [[_keys objectAtIndex:section] count]/2 : [[_keys objectAtIndex:section] count]/2 +1;
    } else {
        return [[_keys objectAtIndex:section] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 3) {
        DetailsPACell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsPACell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailsPACell" owner:self options:nil] lastObject];
        }
        
        
        
        cell.key1.text     = [[_keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row*2];
        cell.value1.text   = [[_values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row*2];
        
        if (indexPath.row*2 + 1 < [[_keys objectAtIndex:indexPath.section] count]) {
            cell.key2.hidden = NO;
            cell.value2.hidden = NO;
            
            cell.key2.text     = [[_keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row*2 + 1];
            cell.value2.text   = [[_values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row*2 + 1];
            
        } else {
            cell.key2.hidden = YES;
            cell.value2.hidden = YES;
        }
        
        return cell;
    } else {
        DetailCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell2"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell2" owner:self options:nil] lastObject];
            cell.lbCell.font = [UIFont systemFontOfSize:13.0];
        }
        
        cell.lbCell.text   = [[_values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CarDetailWSDelegate

- (NSString*) getValueByKey:(NSString*)key withDic:(NSMutableDictionary*)dic
{
    if ([[dic objectForKey:key] isKindOfClass:[NSDictionary class]]) {
        return @"";
    } else {
        return [dic objectForKey:key];
    }
}

- (void) getDetailCarWSByID:(NSString*)carID
{
    self.carId = carID;
    CarDetailWS *carDetail = [[CarDetailWS alloc] init];
    carDetail.delegate = self;
    [carDetail getDetailCarByID:carID];
    [_loadingView show];
    
    // add CoreData --> Recents
}

- (void)didFailWithError:(Error*)error
{
    [_loadingView hide];
    NSLog(@"error msg: %@",error.error_msg);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                        message:error.error_msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (void)didSuccessWithCar:(NSMutableDictionary*)carInfo
{
    if ([[carInfo objectForKey:@"__name"] isEqual:@"results"]) {
        
        NSMutableDictionary *used_car = [carInfo objectForKey:@"used_car"];
        self.userCar = used_car;
        
        NSMutableDictionary *equip = [used_car objectForKey:@"equip"];
        NSMutableDictionary *shop = [used_car objectForKey:@"shop"];
        
        //set title
        _lbTitleCar.text = [NSString stringWithFormat:@"%@%@%@",[self getValueByKey:@"maker" withDic:used_car],[self getValueByKey:@"shashu" withDic:used_car],[self getValueByKey:@"grade" withDic:used_car]];
        
        //set Price
        _lbPriceDisp.text   =  [[self getValueByKey:@"price_disp" withDic:used_car] isEqualToString:@""] ? @"-" : [self getValueByKey:@"price_disp" withDic:used_car];
        _lbPriceDisp.text  = [NSString stringWithFormat:@"本体価格(税込)：%@",_lbPriceDisp.text];
        
        _lbTotalPrice.text  = [[self getValueByKey:@"total_price" withDic:used_car] isEqualToString:@""] ? @"-" : [self getValueByKey:@"total_price" withDic:used_car];
        _lbTotalPrice.text  = [NSString stringWithFormat:@"支払総額(税込)：%@",_lbTotalPrice.text];
        
        //set Description
        _lbDescription.text = [self getValueByKey:@"description" withDic:used_car];
        _tvDes.text = [self getValueByKey:@"description" withDic:used_car];
        
        
        
        // add Session 01
        [_sessions addObject:@"基本情報"];
        NSMutableArray *arrayKey1 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue1 = [[NSMutableArray alloc] init];
        
        
        [arrayKey1 addObject:@"本体価格（税込）"];
        [arrayValue1 addObject:[self getValueByKey:@"price_disp" withDic:used_car]];
        
        [arrayKey1 addObject:@"支払送金額（税込）"];
        [arrayValue1 addObject:[self getValueByKey:@"total_price" withDic:used_car]];
        
        [arrayKey1 addObject:@"走行距離 "];
        [arrayValue1 addObject:[self getValueByKey:@"mileage_disp" withDic:used_car]];
        
        [arrayKey1 addObject:@"年式 "];
        [arrayValue1 addObject:[NSString stringWithFormat:@"%@年式",[self getValueByKey:@"year_disp" withDic:used_car]]];
        
        [arrayKey1 addObject:@"色 "];
        [arrayValue1 addObject:[self getValueByKey:@"color" withDic:used_car]];
        
        [arrayKey1 addObject:@"車台末尾番号 "];
        [arrayValue1 addObject:[self getValueByKey:@"syadai" withDic:used_car]];
        
        [arrayKey1 addObject:@"非気量 "];
        [arrayValue1 addObject:[self getValueByKey:@"displacement" withDic:used_car]];
        
        [arrayKey1 addObject:@"過給器設定モデル "];
        [arrayValue1 addObject:[self getValueByKey:@"Turbo" withDic:equip]];
        
        [arrayKey1 addObject:@"エンジン種別 "];
        [arrayValue1 addObject:[self getValueByKey:@"engine" withDic:equip]];
        
        [arrayKey1 addObject:@"駆動方式 "];
        if ([[self getValueByKey:@"four_wheel" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue1 addObject:@"2WD"];
        } else {
            [arrayValue1 addObject:@"4WD"];
        }
        
        [arrayKey1 addObject:@"ハンドル "];
        [arrayValue1 addObject:[self getValueByKey:@"handle" withDic:equip]];
        
        [arrayKey1 addObject:@"ミッション "];
        [arrayValue1 addObject:[self getValueByKey:@"mission" withDic:used_car]];
        
        [arrayKey1 addObject:@"ボディタイプ "];
        [arrayValue1 addObject:[self getValueByKey:@"body" withDic:used_car]];
        
        [arrayKey1 addObject:@"乗車定数 "];
        [arrayValue1 addObject:[self getValueByKey:@"person" withDic:used_car]];
        
        [arrayKey1 addObject:@"福祉両者 "];
        [arrayValue1 addObject:[self getValueByKey:@"fukushi" withDic:equip]];
        
        [arrayKey1 addObject:@"正規輸入車 "];
        [arrayValue1 addObject:[self getValueByKey:@"dealer_car" withDic:equip]];
        
        [arrayKey1 addObject:@"ドア数 "];
        [arrayValue1 addObject:[self getValueByKey:@"door" withDic:used_car]];
        
        [arrayKey1 addObject:@"スライドドア "];
        [arrayValue1 addObject:[self getValueByKey:@"slide_door" withDic:equip]];
        
        
        // add Session 02
        [_sessions addObject:@"状態"];
        NSMutableArray *arrayKey2 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue2 = [[NSMutableArray alloc] init];
        
        [arrayKey2 addObject:@"修復歴 "];
        [arrayValue2 addObject:[self getValueByKey:@"repair" withDic:used_car]];
        
        [arrayKey2 addObject:@"新車物件 "];
        if ([[self getValueByKey:@"syaken_disp" withDic:used_car] isEqualToString:@"新車未登録"]) {
            [arrayValue2 addObject:@"○"];
        } else {
            [arrayValue2 addObject:@"-"];
        }
        
        [arrayKey2 addObject:@"登録済未使用車 "];
        if ([[self getValueByKey:@"registered_unused" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"定期点検記録簿付 "];
        if ([[self getValueByKey:@"record_list" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"禁煙者 "];
        if ([[self getValueByKey:@"no_smoking" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"車検 "];
        [arrayValue2 addObject:[self getValueByKey:@"syaken_disp" withDic:used_car]];
        
        [arrayKey2 addObject:@"リサイクル料 "];
        [arrayValue2 addObject:[self getValueByKey:@"recycle" withDic:used_car]];
        
        [arrayKey2 addObject:@"ワンオーナー "];
        if ([[self getValueByKey:@"one_owner" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        
        // add Session 03
        [_sessions addObject:@"装備仕様"];
        NSMutableArray *arrayKey3 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue3 = [[NSMutableArray alloc] init];
        
        [arrayKey3 addObject:@"パワステ "];
        if ([[self getValueByKey:@"p_steer" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"パワーウィンドウ "];
        if ([[self getValueByKey:@"p_window" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"エアコン "];
        if ([[self getValueByKey:@"aircon" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"Wエアコン "];
        if ([[self getValueByKey:@"w_aircon" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"カーナビ/TV "];
        [arrayValue3 addObject:[NSString stringWithFormat:@"%@ / %@",[self getValueByKey:@"car_navi" withDic:equip],[self getValueByKey:@"car_tv" withDic:equip]]];
        
        [arrayKey3 addObject:@"バックモニター "];
        if ([[self getValueByKey:@"back_monitor" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"キーレス "];
        if ([[self getValueByKey:@"key_less" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ETC "];
        if ([[self getValueByKey:@"etc" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"本革シート "];
        if ([[self getValueByKey:@"leather_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"電動シート "];
        if ([[self getValueByKey:@"electric_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"フルフラットシート "];
        if ([[self getValueByKey:@"fullflat_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ベンチシート "];
        if ([[self getValueByKey:@"bench_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"3別シート "];
        if ([[self getValueByKey:@"three_line_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ウォークスルー "];
        if ([[self getValueByKey:@"walk_through" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"フルエアロ "];
        if ([[self getValueByKey:@"full_aero" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"アルミホイール "];
        if ([[self getValueByKey:@"a_wheel" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ローダウン "];
        if ([[self getValueByKey:@"low_down" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"サンルーフ "];
        if ([[self getValueByKey:@"sun_roof" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ディスチャージドランブ "];
        if ([[self getValueByKey:@"discharged_lamp" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"盗難防止装置 "];
        if ([[self getValueByKey:@"theft_prevention" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"エアバッグ "];
        [arrayValue3 addObject:[NSString stringWithFormat:@"%@ / %@ / %@",
                                [[self getValueByKey:@"main_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ,
                                [[self getValueByKey:@"sub_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ,
                                [[self getValueByKey:@"side_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ]];
        
        [arrayKey3 addObject:@"ABS "];
        [arrayValue3 addObject:[[self getValueByKey:@"abs" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ];
        
        [arrayKey3 addObject:@"ESC "];
        [arrayValue3 addObject:[[self getValueByKey:@"esc" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ];
        
        [arrayKey3 addObject:@"冷却地仕様 "];
        [arrayValue3 addObject:[[self getValueByKey:@"cold_district" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ];
        
        // add array
        [_keys addObject:arrayKey1];
        [_values addObject:arrayValue1];
        
        [_keys addObject:arrayKey2];
        [_values addObject:arrayValue2];
        
        [_keys addObject:arrayKey3];
        [_values addObject:arrayValue3];
        
        
        // reload Table
        [_tableView reloadData];
        
        //get URL Photo
        int num_photo = [[self getValueByKey:@"m_photo" withDic:used_car] isEqualToString:@""] ? 0 : [[self getValueByKey:@"m_photo" withDic:used_car] integerValue];
        NSMutableDictionary *photo = [used_car objectForKey:@"photo"];
        
        if (num_photo > 0) {
            PhotoItem *photoItem = [[PhotoItem alloc] init];
            photoItem.photoID = @"100";
            photoItem.strCaption = @"";
            photoItem.strUrl = [self getValueByKey:@"main_photo" withDic:photo];
            
            [_images addObject:photoItem];
            
            for (int i = 1; i <= num_photo ; i++) {
                PhotoItem *photoItem = [[PhotoItem alloc] init];
                
                photoItem.photoID    = [NSString stringWithFormat:@"%d",i-1 + 101];
                photoItem.strCaption = [self getValueByKey:[NSString stringWithFormat:@"multi_caption%d",i] withDic:photo];
                photoItem.strUrl     = [self getValueByKey:[NSString stringWithFormat:@"multi_photo%d",i] withDic:photo];
                
                [_images addObject:photoItem];
                
                //                //down load photo
                //                Downloader *downloader = [[Downloader alloc] init];
                //                downloader.delegate = self;
                //                downloader.identifier = photoItem.photoID;
                //                [downloader get:[NSURL URLWithString:photoItem.strUrl]];
                
            }
        } else {
            PhotoItem *photoItem = [[PhotoItem alloc] init];
            
            photoItem.photoID = @"100";
            photoItem.strCaption = @"";
            photoItem.strUrl = [self getValueByKey:@"main_photo" withDic:photo];
            
            [_images addObject:photoItem];
        }
        
        [self loadImageInScroll];
        
        //call Detail
        ShopDetailWS *shopDetailWS = [[ShopDetailWS alloc] init];
        shopDetailWS.delegate = self;
        [shopDetailWS getDetailShopByID:[shop objectForKey:@"shop_id"]];
        
        
        // resize headerView
        float heightTemp = _tvDes.frame.size.height;
        
        CGSize size = [_tvDes.text  sizeWithFont:[UIFont systemFontOfSize:12.0]
                               constrainedToSize:CGSizeMake(635.0, 1024.0)
                                   lineBreakMode:NSLineBreakByWordWrapping];
        
        NSLog(@"height : %f -- temp: %f",size.height, heightTemp);
        
        CGRect rect = _viewHeader.frame;
        
        if (size.height == 0) {
            rect.size.height -=  10;
            _viewHeader.frame = rect;
        } else {
            
            rect.size.height += size.height - heightTemp + 35;
            _viewHeader.frame = rect;
            
            rect = _tvDes.frame;
            rect.size.height = size.height + 45;
            _tvDes.frame = rect;
        }
        
        if ([_images count] < 10) {
            rect = _tvDes.frame;
            rect.origin.y -= 50;
            _tvDes.frame = rect;
            
            rect = _viewHeader.frame;
            rect.size.height -= 50;
            _viewHeader.frame = rect;
        }

        [_tableView setTableHeaderView:_viewHeader];
        
        
    } else {
        [_loadingView hide];
        if ([[carInfo objectForKey:@"status"] integerValue] == 200) {
            
            // set Nodata
            if (_delegate && [_delegate respondsToSelector:@selector(carNoDataWithID:)]) {
                [_delegate carNoDataWithID:_carId];
                [[AppDelegate shared] setDelCarWithID:_carId];
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:@"検索条件に該当する 情報がありませんでした。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    
    
}

#pragma mark -  ShopDetailWSDelegate
- (void)didFailWithErrorShop:(Error *)error
{
    [_loadingView hide];
    [Common showAlert:error.error_msg];
    
    for (int i = 0; i < [_images count] ; i++) {
        PhotoItem *photoItem = [_images objectAtIndex:i];
        
        //down load photo
        Downloader *downloader = [[Downloader alloc] init];
        downloader.delegate = self;
        downloader.identifier = photoItem.photoID;
        [downloader get:[NSURL URLWithString:photoItem.strUrl]];
        
    }
}

- (void)didSuccessWithShop:(NSMutableDictionary*)shopInfo
{
    if ([[shopInfo objectForKey:@"__name"] isEqual:@"results"]) {
        
        NSMutableDictionary *shop = [shopInfo objectForKey:@"shop"];
        
        // add Session 04
        [_sessions addObject:@"店舗情報"];
        NSMutableArray *arrayKey4 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue4 = [[NSMutableArray alloc] init];
        
        [arrayKey4 addObject:@"houjin_name"];
        [arrayValue4 addObject:[self getValueByKey:@"houjin_name" withDic:shop]];
        
        [arrayKey4 addObject:@"address"];
        [arrayValue4 addObject:[self getValueByKey:@"address" withDic:shop]];
        
        [arrayKey4 addObject:@"from - to"];
        
        NSString *eigyouFrom = [self getValueByKey:@"eigyou_from1" withDic:shop];
        NSString *temp1 = [eigyouFrom substringToIndex:2];
        NSString *temp2 = [eigyouFrom substringFromIndex:2];
        eigyouFrom = [NSString stringWithFormat:@"%@:%@",temp1,temp2];
        
        NSString *eigyouTo = [self getValueByKey:@"eigyou_to1" withDic:shop];
        temp1 = [eigyouTo substringToIndex:2];
        temp2 = [eigyouTo substringFromIndex:2];
        eigyouTo = [NSString stringWithFormat:@"%@:%@",temp1,temp2];
        
        [arrayValue4 addObject:[NSString stringWithFormat:@"営業時間:\n%@ ~ %@",eigyouFrom,eigyouTo]];
        
        
        // add array
        
        [_keys addObject:arrayKey4];
        [_values addObject:arrayValue4];
        
        [_tableView reloadData];
        
    } else {
        [Common showAlert:[shopInfo objectForKey:@"message"]];
    }
    
    [_loadingView hide];
    
    for (int i = 0; i < [_images count] ; i++) {
        PhotoItem *photoItem = [_images objectAtIndex:i];
        
        //down load photo
        Downloader *downloader = [[Downloader alloc] init];
        downloader.delegate = self;
        downloader.identifier = photoItem.photoID;
        [downloader get:[NSURL URLWithString:photoItem.strUrl]];
        
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    _isShowEmail = NO;
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _imageScroll) {
        if (!decelerate) {
            _imageIndex = _imageScroll.contentOffset.x / 635;
            
            if (_imageIndex == 0) {
                _btBackScrollImage.hidden = YES;
                _btNextScrollImage.hidden = NO;
            } else if (_imageIndex == [_images count] - 1) {
                _btBackScrollImage.hidden = NO;
                _btNextScrollImage.hidden = YES;
            } else {
                _btBackScrollImage.hidden = NO;
                _btNextScrollImage.hidden = NO;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _imageScroll) {
        _imageIndex = _imageScroll.contentOffset.x / 635;
        
        if (_imageIndex == 0) {
            _btBackScrollImage.hidden = YES;
            _btNextScrollImage.hidden = NO;
        } else if (_imageIndex == [_images count] - 1) {
            _btBackScrollImage.hidden = NO;
            _btNextScrollImage.hidden = YES;
        } else {
            _btBackScrollImage.hidden = NO;
            _btNextScrollImage.hidden = NO;
        }
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView == _tableView) {
//        if (scrollView.contentOffset.y > _tableView.tableHeaderView.frame.size.height) {
//            [self showViewInfoCar:YES];
//        } else {
//            [self showViewInfoCar:NO];
//        }
//    }
//}

- (void)showViewInfoCar:(BOOL)_isShow{
    if (_isShow == _isHidenViewInfoCar) {
        
        if (!_isCloseViewInfoCar) {
            CGRect rectTable = _tableView.frame;
            float alpha = 0;
            
            if (_isShow) {
                rectTable.size.height -= 93;
                rectTable.origin.y += 93;
                alpha = 1;
            } else {
                rectTable.size.height += 93;
                rectTable.origin.y -= 93;
                alpha = 0;
            }
            
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            
            _tableView.frame = rectTable;
            _viewInfoCar.alpha = alpha;
            
            [UIView commitAnimations];
        } else {
            _btOpenViewInfo.hidden = !_isShow;
        }
        
        _isHidenViewInfoCar = !_isShow;
    }
}

- (IBAction)closeViewInfoCar:(id)sender {
    _isCloseViewInfoCar = YES;
    
    if (!_isHidenViewInfoCar) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.4];
        
        CGRect rectTable = _tableView.frame;
        
        rectTable.size.height += 93;
        rectTable.origin.y -= 93;
        
        _tableView.frame = rectTable;
        _viewInfoCar.alpha = 0;
        _btOpenViewInfo.hidden = NO;
        
        [UIView commitAnimations];
    }
}

- (IBAction)openViewInfoCar:(id)sender {
    _isCloseViewInfoCar = NO;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    
    CGRect rectTable = _tableView.frame;
    
    rectTable.size.height -= 93;
    rectTable.origin.y += 93;
    
    _tableView.frame = rectTable;
    _viewInfoCar.alpha = 1;
    _btOpenViewInfo.hidden = YES;
    
    [UIView commitAnimations];
}

#pragma mark - DownloaderDelegate

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    int index = [identifier integerValue];
    
    if (index == - 100) {
        _carImg.image = [UIImage imageWithData:data];
    } else {
        for (UIView *view in _imageScroll.subviews) {
            if (view.tag == index) {
                UIImageView *imageView = (UIImageView*) view;
                imageView.image = [UIImage imageWithData:data];
                
                PhotoItem *item = [_images objectAtIndex:index - 100];
                item.image = [UIImage imageWithData:data];
                
                UIImageView *imageView2 = (UIImageView*) [_viewThumbs viewWithTag:index];
                imageView2.image = [UIImage imageWithData:data];
            }
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    int index = [indentifier integerValue];
    
    if (index == -100) {
        _carImg.image = [UIImage imageNamed:@"no_image_car.png"];
    } else {
        for (UIView *view in _imageScroll.subviews) {
            if (view.tag == index) {
                UIImageView *imageView = (UIImageView*) view;
                imageView.image = [UIImage imageNamed:@"no_image_car.png"];
                
                PhotoItem *item = [_images objectAtIndex:index - 100];
                item.image = [UIImage imageNamed:@"no_image_car.png"];
                
                UIImageView *imageView2 = (UIImageView*) [_viewThumbs viewWithTag:index];
                imageView2.image = [UIImage imageNamed:@"no_image_car.png"];
            }
        }
    }
}

- (void)loadImageInScroll
{
    _imageScroll.contentSize = CGSizeMake(635 * [_images count], 477.0);
    CGRect rect = CGRectMake(0 , 0.0, 635, 477);
    CGRect rect2 = CGRectMake(0, 0, 63, 43);
    
    _imageIndex = 0;
    _btBackScrollImage.hidden = YES;
    
    for (int i = 0; i<[_images count]; i++) {
        
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_no_image.png"]];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.frame = rect;
        img.tag = i + 100;
        img.userInteractionEnabled = YES;
        img.clipsToBounds = YES;
        [_imageScroll addSubview:img];
        
        rect.origin.x += 635;
        
        UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_no_image.png"]];
        img2.contentMode = UIViewContentModeScaleAspectFit;
        img2.frame = rect2;
        img2.tag = i + 100;
        img2.userInteractionEnabled = YES;
        
        [_viewThumbs addSubview:img2];
        
        rect2.origin.x += 63.5;
        if (rect2.origin.x >= 635) {
            rect2.origin.x = 0;
            rect2.origin.y += 50;
        }
        
        
    }
}

- (void)imageTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint touchPoint = [(UITapGestureRecognizer*)recognizer locationInView:_viewThumbs];
    
    int tapIndex = touchPoint.x / 63.5;
    
    if (touchPoint.y < 43) {
        //hang 1
        
    } else if (touchPoint.y < 93 && touchPoint.y > 50){
        //hang 2
        tapIndex += 10;
    }
    
    if (tapIndex < [_images count]) {
        [_imageScroll setContentOffset:CGPointMake(tapIndex*635, 0)];
        
        _imageIndex = tapIndex;
        
        if (_imageIndex == 0) {
            _btBackScrollImage.hidden = YES;
            _btNextScrollImage.hidden = NO;
        } else if (_imageIndex == [_images count] - 1) {
            _btBackScrollImage.hidden = NO;
            _btNextScrollImage.hidden = YES;
        } else {
            _btBackScrollImage.hidden = NO;
            _btNextScrollImage.hidden = NO;
        }
    }
}


#pragma mark - Action

- (IBAction)showAds:(id)sender
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyMMdd"];
    NSString *url = [NSString stringWithFormat:@"http://www.carsensor.net/usedcar/ex_multi_redirect.php?KEIS1=Z%@0000%@&BKKN1=%@&TOI1=1&MAKER1=%@&SHASHU1=%@&KKKU1=%@&PN=gmotech&vos=ncsralsa201307181se",
                     [dateFormat stringFromDate:[NSDate date]],
                     _carId,
                     _carId,
                     [self getValueByKey:@"maker_cd" withDic:_userCar],
                     [self getValueByKey:@"shashu_cd" withDic:_userCar],
                     [[self getValueByKey:@"price" withDic:_userCar] isEqualToString:@"応談"] ? @"999999999" : [self getValueByKey:@"price" withDic:_userCar]];
    
    ViewShopVC *viewShop = [[ViewShopVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewShop];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
//    [viewShop loadWebCarByID:_carId];
    if([Common isIOS7]){
        viewShop.urlAddress = url;
    }
    else
    {
        [viewShop loadWebCarByID:url];

    }
}

- (void) dismissMail
{
    if (_isShowEmail) {
        NSLog(@"dismissMail");
        [_mailComposeViewController dismissModalViewControllerAnimated:NO];
        
        _isShowEmail = NO;
    }
}

- (IBAction)showEmail:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        _isShowEmail = YES;
        
        if (_mailComposeViewController) {
            _mailComposeViewController = nil;
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyMMdd"];
        
        _mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [_mailComposeViewController.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [_mailComposeViewController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master.png"] forBarMetrics:UIBarMetricsDefault];
        _mailComposeViewController.mailComposeDelegate = self;
        [_mailComposeViewController setSubject:@"【中古車ナウ】中古車情報"];
        [_mailComposeViewController setMessageBody:[NSString stringWithFormat:@"中古車ナウをご利用いただきありがとうございます。\n"
                                                    "お客様の送信された中古車情報は下記の通りです。\n"
                                                    "\n"
                                                    "------------------------------------\n"
                                                    "%@ %@ %@\n"
                                                    "------------------------------------\n"
                                                    "\n"
                                                    "【本体価格(税込)】%@\n"
                                                    "\n"
                                                    "■基本情報\n"
                                                    "------------------------------------\n"
                                                    "【走行距離】%@\n"
                                                    "【年式】%@年\n"
                                                    "【色】%@ \n"
                                                    "【車台末尾番号】%@ \n"
                                                    "【排気量】%@cc\n"
                                                    "------------------------------------\n"
                                                    "\n"
                                                    "■[PC・iPad用]在庫確認・見積り依頼はこちら\n"
                                                    "http://www.carsensor.net/usedcar/ex_multi_redirect.php?KEIS1=Z%@0000%@&BKKN1=%@&TOI1=1&MAKER1=%@&SHASHU1=%@&KKKU1=%@&PN=gmotech&vos=ncsralsa201307181se\n"
                                                    "\n"
                                                    "■[スマートフォン用]在庫確認・見積り依頼はこちら\n"
                                                    "https://www.carsensor.net/smph/ex_multi_inquiry_mm.php?STID=SMPH2400&vos=smph201307191&BKKN=%@\n"
                                                    "\n"
                                                    "今後とも中古車ナウをどうぞよろしくお願い致します。\n",
                                                    [self getValueByKey:@"maker" withDic:_userCar],
                                                    [self getValueByKey:@"shashu" withDic:_userCar],
                                                    [self getValueByKey:@"grade" withDic:_userCar],
                                                    [self getValueByKey:@"price_disp" withDic:_userCar],
                                                    [self getValueByKey:@"mileage_disp" withDic:_userCar],
                                                    [self getValueByKey:@"year_disp" withDic:_userCar],
                                                    [self getValueByKey:@"color" withDic:_userCar],
                                                    [self getValueByKey:@"syadai" withDic:_userCar],
                                                    [self getValueByKey:@"displacement" withDic:_userCar],
                                                    [dateFormat stringFromDate:[NSDate date]],
                                                    _carId,
                                                    _carId,
                                                    [self getValueByKey:@"maker_cd" withDic:_userCar],
                                                    [self getValueByKey:@"shashu_cd" withDic:_userCar],
                                                    [[self getValueByKey:@"price" withDic:_userCar] isEqualToString:@"応談"] ? @"999999999" : [self getValueByKey:@"price" withDic:_userCar],
                                                    _carId
                                                    ]
                                            isHTML:NO];
        [self.navigationController presentModalViewController:_mailComposeViewController animated:YES];
    }
}

- (IBAction)backScrollImage:(id)sender {
    _imageIndex--;
    [_imageScroll setContentOffset:CGPointMake(635 * _imageIndex,0 ) animated:YES];
    
    _btNextScrollImage.hidden = NO;
    if (_imageIndex == 0) {
        _btBackScrollImage.hidden = YES;
    } else {
        _btBackScrollImage.hidden = NO;
    }
}

- (IBAction)nextScrollImage:(id)sender {
    _imageIndex++;
    [_imageScroll setContentOffset:CGPointMake(635 * _imageIndex,0 ) animated:YES];
    
    _btBackScrollImage.hidden = NO;
    if (_imageIndex == [_images count] - 1) {
        _btNextScrollImage.hidden = YES;
    } else {
        _btNextScrollImage.hidden = NO;
    }
}



@end
