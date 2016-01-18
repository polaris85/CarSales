//
//  DetailsVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "DetailsVC.h"
#import "MultiLineButton.h"
#import "KeyValueCell.h"
#import "OuterShadowView.h"
#import <MessageUI/MessageUI.h>
#import "DetailsCell.h"
#import "DetailCell2.h"

#import "Define.h"
#import "Common.h"
#import "CarDetailWS.h"
#import "ShopDetailWS.h"

#import "PhotoItem.h"
#import "Downloader.h"
#import "LoadingView.h"

#import "CDFavorites.h"

#import "JT2PopupAlertView.h"

#import "ZoomImageVC.h"
#import "ZoomImageScrollVC.h"
#import "ViewShopVC.h"

#import "FXNavigationController.h"

@interface DetailsVC () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, CarDetailWSDelegate, DownloaderDelegate, ShopDetailWSDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIScrollView *_imageScroll;
    __weak IBOutlet UIView *_viewInfoCar;
    __weak IBOutlet UIButton *_btOpenViewInfo;

    __weak IBOutlet UIButton *_emailButtonItem;
    __weak IBOutlet UIButton *_adsButtonItem;
    
    __weak IBOutlet UITextView *_tvDes;
    NSMutableArray *_items;
    
    NSMutableArray *_sessions;
    
    NSMutableArray *_keys;
    NSMutableArray *_values;
    
    NSMutableArray *_images;
    
    BOOL _scrollingByPageControl;
    
    __weak IBOutlet UIView *_viewHeader;
    __weak IBOutlet UILabel *_lbTitleCar;
    
    __weak IBOutlet UILabel *_lbPriceDisp;
    __weak IBOutlet UILabel *_lbTotalPrice;
    
    __weak IBOutlet UILabel *_lbDescription;
    __weak IBOutlet UIButton *_btNextScrollImage;
    __weak IBOutlet UIButton *_btBackScrollImage;
    
    LoadingView *_loadingView;
    
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

@implementation DetailsVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = DETAILS_TITLE;
        
        UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFavirote setImage:[UIImage imageNamed:@"btn_navi_favorite.png"] forState:UIControlStateNormal];
        [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btFavirote setFrame:CGRectMake(0, 0, 60, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btFavirote];
        
        
        _items = [[NSMutableArray alloc] init];
        
        _sessions = [[NSMutableArray alloc] init];
        _keys = [[NSMutableArray alloc] init];
        _values = [[NSMutableArray alloc] init];
        
        _images = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = DETAILS_TITLE;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _imageScroll.delegate = self;
    _imageScroll.clipsToBounds = NO;
    
    _isHidenViewInfoCar = YES;
    _viewInfoCar.alpha = 0;
    _btOpenViewInfo.hidden = YES;
    
    
    if ([Common isIOS7]) {
        CGRect tmpRect = self.view.bounds;
        tmpRect.size.height += 48;
        tmpRect.origin.y += 48;
        _loadingView = [[LoadingView alloc] initWithFrame:tmpRect];
    }
    else
        _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loadingView];
    
    // set up Recognizer with tag
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    imageTapRecognizer.numberOfTapsRequired = 1;
    imageTapRecognizer.numberOfTouchesRequired = 1;
    [_imageScroll addGestureRecognizer:imageTapRecognizer];
    
    if([Common isIOS7]){
        [self setFavoriteCar];
        
        [self getDetailCarWSByID:self.carItem.carId];
        
        NSLog(@"info view : %@", _viewInfoCar);
        CGRect tmpRect = _viewInfoCar.frame;
        tmpRect.origin.y += 60;
        _viewInfoCar.frame = tmpRect;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _tableView = nil;
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
    _viewInfoCar = nil;
    _btOpenViewInfo = nil;
    [super viewDidUnload];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // fix crash app when scroll to bottom table view
    if ([Common isIOS7]) {
        CGRect sectionRect = [_tableView rectForSection:2];
        [_tableView scrollRectToVisible:sectionRect animated:YES];
    }
    
}

- (void) setFavoriteCar
{
    NSLog(@"setFavoriteCar");
    if ([[AppDelegate shared] isExitsCarFavoritesWithID:_carItem.carId]) {
        UIButton *btDeleteFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btDeleteFavirote setImage:[UIImage imageNamed:@"btn_navi_delete_favorite.png"] forState:UIControlStateNormal];
        [btDeleteFavirote addTarget:self action:@selector(deleteToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btDeleteFavirote setFrame:CGRectMake(0, 0, 60, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btDeleteFavirote];
    } else {
        UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFavirote setImage:[UIImage imageNamed:@"btn_navi_favorite.png"] forState:UIControlStateNormal];
        [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btFavirote setFrame:CGRectMake(0, 0, 60, 30)];
        
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
    NSLog(@"loadCellInView");
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

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (scrollView == _imageScroll) {
//        [_tableView setContentOffset:CGPointZero animated:YES];
//    }
//}
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        if (scrollView.contentOffset.y > _tableView.tableHeaderView.frame.size.height) {
            [self showViewInfoCar:YES];
        } else {
            [self showViewInfoCar:NO];
        }
    }
    else {
    }
}

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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _imageScroll) {
        if (!decelerate) {
            
//            float x = scrollView.contentOffset.x;
//            int detal = abs((95) - (x + 45));
//            int detalI = 0;
//
//            for (int i = 0; i < [_images count]; i++) {
//                
//                if (detal > abs((i*230 + 95) - (x + 45))) {
//                    detal = abs((i*230 + 95) - (x + 45));
//                    detalI = i;
//                }
//            }
//            [scrollView setContentOffset:CGPointMake(detalI*230, 0) animated:YES];
            
            _imageIndex = _imageScroll.contentOffset.x / 320;
            
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
//         float x = scrollView.contentOffset.x;
//         int detal = abs((95) - (x + 45));
//         int detalI = 0;
//
//         for (int i = 0; i < [_images count]; i++) {
//             
//             if (detal > abs((i*230 + 95) - (x + 45))) {
//                 detal = abs((i*230 + 95) - (x + 45));
//                 detalI = i;
//             }
//         }
//         [scrollView setContentOffset:CGPointMake(detalI*230, 0) animated:YES];
         
         _imageIndex = _imageScroll.contentOffset.x / 320;
         
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
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    
    UIImageView *imgBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_section.png"]];
    imgBG.frame = viewHeader.frame;
    [viewHeader addSubview:imgBG];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
//    title.text = @"基本情報";
    title.text = [_sessions objectAtIndex:section];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:12.0];
    title.textColor = [UIColor whiteColor];
    title.shadowOffset = CGSizeMake(1.0, 1.0);
    title.shadowColor = [UIColor grayColor];
    title.textAlignment = UITextAlignmentCenter;
    [viewHeader addSubview:title];
    
    return viewHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_keys objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section %d",indexPath.section);
    if (indexPath.section != 3) {
        NSLog(@"DetailsCell %d",indexPath.section);
        DetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailsCell" owner:self options:nil] lastObject];
        }
        
        
        cell.lbKey.text     = [[_keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.lbValue.text   = [[_values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        return cell;
    } else {
        NSLog(@"DetailCell2 %d",indexPath.section);
        DetailCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell2"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell2" owner:self options:nil] lastObject];
        }
        
        cell.lbCell.text   = [[_values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        return cell;
    }
    NSLog(@"nil %d",indexPath.section);
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Action

- (void)addToFavorites
{
    UIButton *btDeleteFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btDeleteFavirote setImage:[UIImage imageNamed:@"btn_navi_delete_favorite.png"] forState:UIControlStateNormal];
    [btDeleteFavirote addTarget:self action:@selector(deleteToFavorites) forControlEvents:UIControlEventTouchUpInside];
    [btDeleteFavirote setFrame:CGRectMake(0, 0, 60, 30)];
    
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
    
//    [Common showAlert:@"Add car in favorite."];
    [JT2PopupAlertView showPopupAlertViewWithString:@"お気に入りに登録しました。" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
}

- (void)deleteToFavorites
{
    AppDelegate *appDelegate = [AppDelegate shared];
    if ([appDelegate deleteCarFavoritesWithID:_carItem.carId]) {
//        [Common showAlert:@"Delete car in favorite"];
        [JT2PopupAlertView showPopupAlertViewWithString:@"お気に入りから削除しました。" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
        
        UIButton *btFavirote =  [UIButton buttonWithType:UIButtonTypeCustom];
        [btFavirote setImage:[UIImage imageNamed:@"btn_navi_favorite.png"] forState:UIControlStateNormal];
        [btFavirote addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        [btFavirote setFrame:CGRectMake(0, 0, 60, 30)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btFavirote];
    } else {
//        [Common showAlert:@"Can't delete car in favorite"];
        [JT2PopupAlertView showPopupAlertViewWithString:@"Can't delete car in favorite" withFont:[UIFont systemFontOfSize:15.0] andDelayTime:2.0];
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
                                                    "■[PC用]在庫確認・見積り依頼はこちら\n"
                                                    "http://www.carsensor.net/usedcar/ex_multi_redirect.php?KEIS1=Z%@0000%@&BKKN1=%@&TOI1=1&MAKER1=%@&SHASHU1=%@&KKKU1=%@&PN=gmotech&vos=ncsralsa201307191se\n"
                                                    "\n"
                                                    "■[スマートフォン用]在庫確認・見積り依頼はこちら\n"
                                                    "https://www.carsensor.net/smph/ex_multi_inquiry_mm.php?STID=SMPH2400&vos=smph201305071&BKKN=%@\n"
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

- (void)setHideButtonImageScroll{
    if (_imageScroll.contentOffset.x == 0) {
        _btBackScrollImage.hidden = YES;
        _btNextScrollImage.hidden = NO;
    } else if (_imageScroll.contentOffset.x == 320 * ([_images count] -1 )) {
        _btBackScrollImage.hidden = NO;
        _btNextScrollImage.hidden = YES;
    } else {
        _btBackScrollImage.hidden = NO;
        _btNextScrollImage.hidden = NO;
    }
}

- (void)setHideButtonImageScrollWithIndexPage:(int)index{
    if (index <= 0 ) {
        _btBackScrollImage.hidden = YES;
        _btNextScrollImage.hidden = NO;
    } else if (index >= [_images count] - 1) {
        _btBackScrollImage.hidden = NO;
        _btNextScrollImage.hidden = YES;
    } else {
        _btBackScrollImage.hidden = NO;
        _btNextScrollImage.hidden = NO;
    }
}

- (IBAction)backScrollImage:(id)sender {
    _imageIndex--;
    [_imageScroll setContentOffset:CGPointMake(320 * _imageIndex,0 ) animated:YES];
    
    _btNextScrollImage.hidden = NO;
    if (_imageIndex == 0) {
        _btBackScrollImage.hidden = YES;
    } else {
        _btBackScrollImage.hidden = NO;
    }
}

- (IBAction)nextScrollImage:(id)sender {    
    _imageIndex++;
    [_imageScroll setContentOffset:CGPointMake(320 * _imageIndex,0 ) animated:YES];

    _btBackScrollImage.hidden = NO;
    if (_imageIndex == [_images count] - 1) {
        _btNextScrollImage.hidden = YES;
    } else {
        _btNextScrollImage.hidden = NO;
    }
}

- (IBAction)showAds:(id)sender {    
    ViewShopVC *viewShop = [[ViewShopVC alloc] init];
    viewShop.carID = _carId;
    FXNavigationController *navi = [[FXNavigationController alloc] initWithRootViewController:viewShop];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
    //[viewShop loadWebCarByID:_carId];
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
        _lbPriceDisp.text = [NSString stringWithFormat:@"本体価格(税込) %@",_lbPriceDisp.text];
        _lbTotalPrice.text  = [[self getValueByKey:@"total_price" withDic:used_car] isEqualToString:@""] ? @"-" : [self getValueByKey:@"total_price" withDic:used_car];
        _lbTotalPrice.text = [NSString stringWithFormat:@"支払総額（税込) %@",_lbTotalPrice.text];
        
        //set Description
        _lbDescription.text = [self getValueByKey:@"description" withDic:used_car];
        _tvDes.text = [self getValueByKey:@"description" withDic:used_car];
        
        float heightTemp = _tvDes.frame.size.height;
        
        CGSize size = [_tvDes.text  sizeWithFont:[UIFont systemFontOfSize:12.0]
                               constrainedToSize:CGSizeMake(320.0, 480.0)
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
        
        
        
        [_tableView setTableHeaderView:_viewHeader];
        
        // add Session 01
        [_sessions addObject:@"基本情報"];
        NSMutableArray *arrayKey1 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue1 = [[NSMutableArray alloc] init];
        
        
        [arrayKey1 addObject:@"本体価格（税込）:"];
        [arrayValue1 addObject:[self getValueByKey:@"price_disp" withDic:used_car]];
        
        [arrayKey1 addObject:@"支払送金額（税込）:"];
        [arrayValue1 addObject:[self getValueByKey:@"total_price" withDic:used_car]];
        
        [arrayKey1 addObject:@"走行距離 :"];
        [arrayValue1 addObject:[self getValueByKey:@"mileage_disp" withDic:used_car]];
        
        [arrayKey1 addObject:@"年式 :"];
        [arrayValue1 addObject:[NSString stringWithFormat:@"%@年式",[self getValueByKey:@"year_disp" withDic:used_car]]];
        
        [arrayKey1 addObject:@"色 :"];
        [arrayValue1 addObject:[self getValueByKey:@"color" withDic:used_car]];
        
        [arrayKey1 addObject:@"車台末尾番号 :"];
        [arrayValue1 addObject:[self getValueByKey:@"syadai" withDic:used_car]];
        
        [arrayKey1 addObject:@"非気量 :"];
        [arrayValue1 addObject:[self getValueByKey:@"displacement" withDic:used_car]];

        [arrayKey1 addObject:@"過給器設定モデル :"];
        [arrayValue1 addObject:[self getValueByKey:@"Turbo" withDic:equip]];
        
        [arrayKey1 addObject:@"エンジン種別 :"];
        [arrayValue1 addObject:[self getValueByKey:@"engine" withDic:equip]];
        
        [arrayKey1 addObject:@"駆動方式 :"];
        if ([[self getValueByKey:@"four_wheel" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue1 addObject:@"2WD"];
        } else {
            [arrayValue1 addObject:@"4WD"];
        }
        
        [arrayKey1 addObject:@"ハンドル :"];
        [arrayValue1 addObject:[self getValueByKey:@"handle" withDic:equip]];
        
        [arrayKey1 addObject:@"ミッション :"];
        [arrayValue1 addObject:[self getValueByKey:@"mission" withDic:used_car]];
        
        [arrayKey1 addObject:@"ボディタイプ :"];
        [arrayValue1 addObject:[self getValueByKey:@"body" withDic:used_car]];
        
        [arrayKey1 addObject:@"乗車定数 :"];
        [arrayValue1 addObject:[self getValueByKey:@"person" withDic:used_car]];
        
        [arrayKey1 addObject:@"福祉両者 :"];
        [arrayValue1 addObject:[self getValueByKey:@"fukushi" withDic:equip]];
        
        [arrayKey1 addObject:@"正規輸入車 :"];
        [arrayValue1 addObject:[self getValueByKey:@"dealer_car" withDic:equip]];
        
        [arrayKey1 addObject:@"ドア数 :"];
        [arrayValue1 addObject:[self getValueByKey:@"door" withDic:used_car]];
        
        [arrayKey1 addObject:@"スライドドア :"];
        [arrayValue1 addObject:[self getValueByKey:@"slide_door" withDic:equip]];
        
        
        // add Session 02
        [_sessions addObject:@"状態"];
        NSMutableArray *arrayKey2 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue2 = [[NSMutableArray alloc] init];
        
        [arrayKey2 addObject:@"修復歴 :"];
        [arrayValue2 addObject:[self getValueByKey:@"repair" withDic:used_car]];
        
        [arrayKey2 addObject:@"新車物件 :"];
        if ([[self getValueByKey:@"syaken_disp" withDic:used_car] isEqualToString:@"新車未登録"]) {
            [arrayValue2 addObject:@"○"];
        } else {
            [arrayValue2 addObject:@"-"];
        }
        
        [arrayKey2 addObject:@"登録済未使用車 :"];
        if ([[self getValueByKey:@"registered_unused" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"定期点検記録簿付 :"];
        if ([[self getValueByKey:@"record_list" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"禁煙者 :"];
        if ([[self getValueByKey:@"no_smoking" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        [arrayKey2 addObject:@"車検 :"];
        [arrayValue2 addObject:[self getValueByKey:@"syaken_disp" withDic:used_car]];
        
        [arrayKey2 addObject:@"リサイクル料 :"];
        [arrayValue2 addObject:[self getValueByKey:@"recycle" withDic:used_car]];
        
        [arrayKey2 addObject:@"ワンオーナー :"];
        if ([[self getValueByKey:@"one_owner" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue2 addObject:@"-"];
        } else {
            [arrayValue2 addObject:@"○"];
        }
        
        
        // add Session 03
        [_sessions addObject:@"装備仕様"];
        NSMutableArray *arrayKey3 = [[NSMutableArray alloc] init];
        NSMutableArray *arrayValue3 = [[NSMutableArray alloc] init];
        
        [arrayKey3 addObject:@"パワステ :"];
        if ([[self getValueByKey:@"p_steer" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"パワーウィンドウ :"];
         if ([[self getValueByKey:@"p_window" withDic:equip] isEqualToString:@"0"]) {
             [arrayValue3 addObject:@"-"];
         } else {
             [arrayValue3 addObject:@"○"];
         }
        
        [arrayKey3 addObject:@"エアコン :"];
        if ([[self getValueByKey:@"aircon" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"Wエアコン :"];
        if ([[self getValueByKey:@"w_aircon" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"カーナビ/TV :"];
        [arrayValue3 addObject:[NSString stringWithFormat:@"%@ / %@",[self getValueByKey:@"car_navi" withDic:equip],[self getValueByKey:@"car_tv" withDic:equip]]];
        
        [arrayKey3 addObject:@"バックモニター :"];
        if ([[self getValueByKey:@"back_monitor" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"キーレス :"];
        if ([[self getValueByKey:@"key_less" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ETC :"];
        if ([[self getValueByKey:@"etc" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"本革シート :"];
        if ([[self getValueByKey:@"leather_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"電動シート :"];
        if ([[self getValueByKey:@"electric_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"フルフラットシート :"];
        if ([[self getValueByKey:@"fullflat_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ベンチシート :"];
        if ([[self getValueByKey:@"bench_seat" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"3別シート :"];
         if ([[self getValueByKey:@"three_line_seat" withDic:equip] isEqualToString:@"0"]) {
             [arrayValue3 addObject:@"-"];
         } else {
             [arrayValue3 addObject:@"○"];
         }
        
        [arrayKey3 addObject:@"ウォークスルー :"];
        if ([[self getValueByKey:@"walk_through" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"フルエアロ :"];
        if ([[self getValueByKey:@"full_aero" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"アルミホイール :"];
        if ([[self getValueByKey:@"a_wheel" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ローダウン :"];
        if ([[self getValueByKey:@"low_down" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"サンルーフ :"];
        if ([[self getValueByKey:@"sun_roof" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"ディスチャージドランブ :"];
        if ([[self getValueByKey:@"discharged_lamp" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"盗難防止装置 :"];
        if ([[self getValueByKey:@"theft_prevention" withDic:equip] isEqualToString:@"0"]) {
            [arrayValue3 addObject:@"-"];
        } else {
            [arrayValue3 addObject:@"○"];
        }
        
        [arrayKey3 addObject:@"エアバッグ :"];
        [arrayValue3 addObject:[NSString stringWithFormat:@"%@ / %@ / %@",
                                [[self getValueByKey:@"main_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ,
                                [[self getValueByKey:@"sub_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ,
                                [[self getValueByKey:@"side_airbag" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ]];
        
        [arrayKey3 addObject:@"ABS :"];
        [arrayValue3 addObject:[[self getValueByKey:@"abs" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ];
        
        [arrayKey3 addObject:@"ESC :"];
        [arrayValue3 addObject:[[self getValueByKey:@"esc" withDic:equip] isEqualToString:@"0"] ? @"-" : @"○" ];
        
        [arrayKey3 addObject:@"冷却地仕様 :"];
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
        
        
    } else {        
        if ([[carInfo objectForKey:@"status"] integerValue] == 200) {
            
            // set Nodata
            if (_delegate && [_delegate respondsToSelector:@selector(carNoDataWithID:)]) {
                [_delegate carNoDataWithID:_carId];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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
            }
        }
    }
}


- (void)loadImageInScroll
{
//    _imageScroll.contentSize = CGSizeMake(230 * [_images count] + 45, 155.0);
    
//    CGRect rect = CGRectMake((230 - 220)/2 , 0.0, 220, 150.0);
    
    _imageScroll.contentSize = CGSizeMake(320 * [_images count], 240.0);
    CGRect rect = CGRectMake(0 , 0.0, 320, 240.0);
    _imageIndex = 0;
    _btBackScrollImage.hidden = YES;
    
    for (int i = 0; i<[_images count]; i++) {
        
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_no_image.png"]];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.frame = rect;
        img.tag = i + 100;
        img.userInteractionEnabled = YES;
        rect.origin.x += 320;
 
        [_imageScroll addSubview:img];
    }
}

#pragma mark -  imageTapped

- (void)imageTapped:(UITapGestureRecognizer*)recognizer {
   
    int tapIndex = _imageScroll.contentOffset.x / 320;
    ZoomImageScrollVC *zoomImageVC = [[ZoomImageScrollVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:zoomImageVC];
    [self.navigationController presentModalViewController:navi animated:NO];
    if ([Common isIOS7]) {
        for (PhotoItem *item in _images) {
            [zoomImageVC.images addObject:item];
        }
        zoomImageVC.indexImage = tapIndex;
    }
    else{
        [zoomImageVC loadInfor:_images index:tapIndex];
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






@end
