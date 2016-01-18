//
//  FilterVCPA.m
//  Car Sales
//
//  Created by TienLP on 7/2/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "FilterVCPA.h"
#import "Define.h"
#import "AppDelegate.h"
#import "Common.h"

#import "JT2ReadFileDB.h"
#import "AppDelegate.h"
#import "Common.h"
#import "Define.h"
#import "CompanyItem.h"
#import "CatalogItem.h"
#import "BodyTypeItem.h"

#import "FilterConfigVC.h"
#import "TextFieldCell.h"
#import "FilterCell.h"

#import "FilterGroupSessionVC.h"
#import "FilterStatesVC.h"
#import "PickerSheet.h"
#import "BodyTypesVC.h"

#import "PAPickerVC.h"

@interface FilterVCPA ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate,PickerSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate,FilterStatesVCDelegate, FilterConfigVCDelegate, BodyTypesVCDelegate, PAPickerDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UITextField *_tfSearch;
    
    NSArray *_items;
    NSArray *_values;
    
    int _selectItem;
    
    NSMutableArray *_companyItems;
    CompanyItem    *_companyItem;
    
    NSMutableArray *_catalogItems;
    CatalogItem    *_catalogItem;
    
    BodyTypeItem   *_bodyTypeItem;
    
    NSMutableDictionary *_dicPref;
    
    NSArray *_priceList;
    NSString *_priceMin,*_priceMax;
    
    NSMutableArray *_yearList;
    NSString *_yearMin,*_yearMax;
    
    NSArray *_oddList;
    NSString *_oddMin,*_oddMax;
    
    NSArray *_missionList;
    NSString *_missionItem;
    
    NSMutableDictionary *_dicColor;
    
    NSString *_bodyTypeName, *_bodyTypeCode;
    
    int _companyIndex,_missionIndex,_catalogIndex;
    
    PAPickerVC *_pickerVC;
}

@end

static __weak FilterVCPA *shared = nil;

@implementation FilterVCPA

- (id)init
{
    self = [super init];
    if (self) {
        shared = self;
    }
    return self;
}

+ (FilterVCPA *)shared
{
    return shared;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPopover)];
        self.title = FILTER_TITLE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"戻る";
    self.navigationItem.backBarButtonItem = back;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.hidesBottomBarWhenPushed = YES;
    _selectItem = -1;
    
    //company
    _companyIndex = -1;
    
    //catalog
    _catalogIndex = -1;
    
    _items = @[@"メーカー",
               @"車種",
               @"都道府県",
               @"価格",
               @"年式",
               @"走行距離",
               @"カラー",
               @"ボディタイプ",
               @"ミッション"];
    _values = @[@"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし",
                @"指定なし"];
    
    
    // pref
    _dicPref = [[NSMutableDictionary alloc] init];
    
    // price
    _priceList = @[TEXT_DONT_SET,
                   @"20万円",
                   @"40万円",
                   @"60万円",
                   @"80万円",
                   @"100万円",
                   @"150万円",
                   @"200万円",
                   @"250万円",
                   @"300万円",
                   @"350万円",
                   @"400万円",
                   @"450万円",
                   @"500万円",
                   @"600万円",
                   @"700万円",
                   @"800万円",
                   @"900万円",
                   @"1000万円"];
    _priceMin = TEXT_DONT_SET;
    _priceMax = TEXT_DONT_SET;
    
    // year
    _yearList = [[NSMutableArray alloc] init];
    _yearMin = TEXT_DONT_SET;
    _yearMax = TEXT_DONT_SET;
    
    [_yearList addObject:TEXT_DONT_SET];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    int year = [components year];
    
    for (int i = year; i >= 1987; i--) {
        [_yearList addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    
    // odd list
    _oddList = @[TEXT_DONT_SET,
                 @"1000km",
                 @"2000km",
                 @"3000km",
                 @"4000km",
                 @"5000km",
                 @"1万km",
                 @"2万km",
                 @"3万km",
                 @"4万km",
                 @"5万km",
                 @"6万km",
                 @"7万km",
                 @"8万km",
                 @"9万km",
                 @"10万km",];
    _oddMin = TEXT_DONT_SET;
    _oddMax = TEXT_DONT_SET;
    
    //mission
    _missionList = @[TEXT_DONT_SET,@"AT",@"MT"];
    _missionItem = TEXT_DONT_SET;
    _missionIndex = 0;
    
    //color
    _dicColor = [[NSMutableDictionary alloc] init];
    
    //body
    _bodyTypeName = TEXT_DONT_SET;
    _bodyTypeCode = @"";
    
    // load picker
    _pickerVC = [[PAPickerVC alloc] initWithNibName:@"PAPickerVC" bundle:nil];
    _pickerVC.contentSizeForViewInPopover = CGSizeMake(320.0, 260.0);
    _pickerVC.view.frame = CGRectMake(0.0, 0.0, 320.0, 260.0);
    _pickerVC.picker.delegate = self;
    _pickerVC.picker.dataSource = self;
    _pickerVC.delegate = self;
}

- (void)viewDidUnload{
    _tableView = nil;
    _tfSearch = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.contentSizeForViewInPopover = CGSizeMake(320, 505);
}

#pragma mark - Action

- (IBAction)showResult
{
    NSMutableDictionary *commonQueryDic = [[NSMutableDictionary alloc] init];
    
    //0
    if (_companyItem) {
        [commonQueryDic setObject:_companyItem forKey:@"CompanyItem"];
    }
    
    //1
    if (_catalogItem) {
        [commonQueryDic setObject:_catalogItem forKey:@"CatalogItem"];
    }
    
    //2
    if ([_dicPref count] > 0) {
        [commonQueryDic setObject:_dicPref forKey:@"PrefItem"];
    }
    
    //3
    if (!([_priceMin isEqualToString:TEXT_DONT_SET] && [_priceMax isEqualToString:TEXT_DONT_SET])) {
        NSMutableDictionary *priceItem = [[NSMutableDictionary alloc] init];
        
        [priceItem setObject:[_priceMin stringByReplacingOccurrencesOfString:@"万円" withString:@""] forKey:@"priceNameMin"];
        [priceItem setObject:[_priceMax stringByReplacingOccurrencesOfString:@"万円" withString:@""] forKey:@"priceNameMax"];
        
        [commonQueryDic setObject:priceItem forKey:@"PriceItem"];
    }
    
    //4
    if (!([_yearMin isEqualToString:TEXT_DONT_SET] && [_yearMax isEqualToString:TEXT_DONT_SET])) {
        NSMutableDictionary *yearItem = [[NSMutableDictionary alloc] init];
        
        
        [yearItem setObject:[_yearMin stringByReplacingOccurrencesOfString:@"年" withString:@""] forKey:@"yearMin"];
        [yearItem setObject:[_yearMax stringByReplacingOccurrencesOfString:@"年" withString:@""] forKey:@"yearMax"];
        
        [commonQueryDic setObject:yearItem forKey:@"YearItem"];
    }
    
    
    //5
    if (!([_oddMin isEqualToString:TEXT_DONT_SET] && [_oddMax isEqualToString:TEXT_DONT_SET])) {
        NSMutableDictionary *oddItem = [[NSMutableDictionary alloc] init];
        
        [oddItem setObject:_oddMin forKey:@"oddMin"];
        [oddItem setObject:_oddMax forKey:@"oddMax"];
        
        [commonQueryDic setObject:oddItem forKey:@"OddItem"];
    }
    
    
    //6
    if ([_dicColor count] > 0)
    {
        [commonQueryDic setObject:_dicColor forKey:@"ColorItem"];
    }
    
    //7
    if (_bodyTypeItem) {
        [commonQueryDic setObject:_bodyTypeItem forKey:@"BodyTypeItem"];
    }
    
    //8
    if (![_missionItem isEqualToString:TEXT_DONT_SET]) {
        [commonQueryDic setObject:_missionItem forKey:@"MissionItem"];
    }
    
    //9
//    if (![[Common trimString:_tfSearch.text] isEqualToString:@""]) {
//        [commonQueryDic setObject:[Common trimString:_tfSearch.text] forKey:@"Keyword"];
//    }
    NSString *value = [_tfSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([value length] > 0) {
        [commonQueryDic setObject:[Common trimString:_tfSearch.text] forKey:@"Keyword"];
    }
    
    //    NSLog(@"Result Dic Query: %@",commonQueryDic);
    
    [_delegate didChangeCommonQueryDic:commonQueryDic];
    [_popover dismissPopoverAnimated:YES];
}

#pragma mark - Load Info

- (void) resetFilter{
    _selectItem = -1;
    
    //company
    _companyIndex = -1;
    _companyItem = nil;
    
    //catalog
    _catalogIndex = -1;
    _catalogItem = nil;
    
    // pref
    [_dicPref removeAllObjects];
    
    // price
    _priceMin = TEXT_DONT_SET;
    _priceMax = TEXT_DONT_SET;
    
    // year
    _yearMin = TEXT_DONT_SET;
    _yearMax = TEXT_DONT_SET;
    
    // odd list
    _oddMin = TEXT_DONT_SET;
    _oddMax = TEXT_DONT_SET;
    
    //mission
    _missionItem = TEXT_DONT_SET;
    _missionIndex = 0;
    
    //color
    [_dicColor removeAllObjects];
    
    //body
    _bodyTypeItem = nil;
    _bodyTypeName = TEXT_DONT_SET;
    _bodyTypeCode = @"";
}

- (void)loadDicQuery:(NSMutableDictionary*)dicQuery
{
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    [self resetFilter];
    
    // 0
    if ([dicQuery objectForKey:@"CompanyItem"]) {
        _companyItem = [dicQuery objectForKey:@"CompanyItem"];
    }
    
    // 1
    if ([dicQuery objectForKey:@"CatalogItem"]) {
        _catalogItem = [dicQuery objectForKey:@"CatalogItem"];
    }
    
    // 2
    if ([dicQuery objectForKey:@"PrefItem"]) {
        _dicPref = [dicQuery objectForKey:@"PrefItem"];
    }
    
    // 3
    if ([dicQuery objectForKey:@"PriceItem"]) {
        NSMutableDictionary *price = [dicQuery objectForKey:@"PriceItem"];
        
        if ([[price objectForKey:@"priceNameMin"] isEqual:@""] || [[price objectForKey:@"priceNameMin"] isEqual:TEXT_DONT_SET]) {
            _priceMin = TEXT_DONT_SET;
        } else {
            _priceMin = [NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMin"]];
        }
        
        if ([[price objectForKey:@"priceNameMax"] isEqual:@""] || [[price objectForKey:@"priceNameMax"] isEqual:TEXT_DONT_SET]) {
            _priceMax = TEXT_DONT_SET;
        } else {
            _priceMax = [NSString stringWithFormat:@"%@万円",[price objectForKey:@"priceNameMax"]];
        }
    }
    
    // 4
    if ([dicQuery objectForKey:@"YearItem"]) {
        NSMutableDictionary *year = [dicQuery objectForKey:@"YearItem"];
        
        _yearMin = [[year objectForKey:@"yearMin"] isEqual:@""] ? TEXT_DONT_SET : [NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMin"]];
        _yearMax = [[year objectForKey:@"yearMax"] isEqual:@""] ? TEXT_DONT_SET : [NSString stringWithFormat:@"%@年",[year objectForKey:@"yearMax"]];
    }
    
    // 5
    if ([dicQuery objectForKey:@"OddItem"]) {
        NSMutableDictionary *oddItem = [dicQuery objectForKey:@"OddItem"];
        
        _oddMin = [[oddItem objectForKey:@"oddMin"] isEqual:@""] ? TEXT_DONT_SET : [NSString stringWithFormat:@"%@",[oddItem objectForKey:@"oddMin"]];
        _oddMax = [[oddItem objectForKey:@"oddMax"] isEqual:@""] ? TEXT_DONT_SET : [NSString stringWithFormat:@"%@",[oddItem objectForKey:@"oddMax"]];
    }
    
    // 6
    if ([dicQuery objectForKey:@"ColorItem"]) {
        _dicColor = [dicQuery objectForKey:@"ColorItem"];
    }
    
    // 7
    if ([dicQuery objectForKey:@"BodyTypeItem"]) {
        _bodyTypeItem = [dicQuery objectForKey:@"BodyTypeItem"];
        
        _bodyTypeName = _bodyTypeItem.bodyName;
        _bodyTypeCode = _bodyTypeItem.bodyCode;
    }
    
    // 8
    if ([dicQuery objectForKey:@"MissionItem"]) {
        _missionItem = [dicQuery objectForKey:@"MissionItem"];
        
        if ([_missionItem isEqualToString:@"AT"]) {
            _missionIndex = 1;
        } else {
            _missionIndex = 2;
        }
        
    }
    
    //9
    if ([dicQuery objectForKey:@"Keyword"]) {
        _tfSearch.text = [dicQuery objectForKey:@"Keyword"];
    }
    
    [self reloadInfoTableView];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FilterCell" owner:self options:nil] lastObject];
    }
    
    cell.lbKey.text = [_items objectAtIndex:indexPath.row];
    cell.lbValue.text = [_values objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectItem = indexPath.row;
    
    switch (indexPath.row) {
        case 0:
        {
            [self readCompanyList];
            
            if (_companyIndex == -1) {
                _companyIndex = [self indexOfCompanyName:_companyItem.companyName];
            }
            
//            PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//            pickerSheet.picker.delegate = self;
//            pickerSheet.picker.dataSource = self;
//            pickerSheet.delegate = self;
//            [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//            [pickerSheet.picker selectRow:_companyIndex inComponent:0 animated:YES];
//            [pickerSheet show];
            
            [self showPicker];
            [_pickerVC.picker selectRow:_companyIndex inComponent:0 animated:YES];
            [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];
            
            break;
        }
        case 1:
        {
            if (!_companyItem || [_companyItem.companyName isEqualToString:TEXT_DONT_SET]) {
                [Common showAlert:@"メーカーを指定してください。"];
            } else {
                
                [self readCatalogList];
                
                if ([_catalogItems count] == 0) {
                    [Common showAlert:@"メーカーを指定してください。"];
                } else {
                    if (_catalogIndex == -1) {
                        _catalogIndex = [self indexOfCatalogName:_catalogItem.model];
                    }
                    
//                    PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//                    pickerSheet.picker.delegate = self;
//                    pickerSheet.picker.dataSource = self;
//                    pickerSheet.delegate = self;
//                    [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//                    [pickerSheet.picker selectRow:_catalogIndex inComponent:0 animated:YES];
//                    [pickerSheet show];
                    
                    [self showPicker];
                    [_pickerVC.picker selectRow:_catalogIndex inComponent:0 animated:YES];
                    [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];
                }
            }
            
            break;
        }
        case 2:
        {
            FilterStatesVC *filterStatesVC = [[FilterStatesVC alloc] init];
            filterStatesVC.delegate = self;
            [self.navigationController pushViewController:filterStatesVC animated:YES];
            [filterStatesVC loadSelectDic:_dicPref];
            break;
        }
        case 3:
        {
            
            int min = 0;
            int max = 0;
            
            for (int i = 0; i < [_priceList count]; i++) {
                if ([[_priceList objectAtIndex:i] isEqual:_priceMin]) {
                    min = i;
                }
                
                if ([[_priceList objectAtIndex:i] isEqual:_priceMax]) {
                    max = i;
                }
            }
            
//            PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//            pickerSheet.picker.delegate = self;
//            pickerSheet.picker.dataSource = self;
//            pickerSheet.delegate = self;
//            [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//            [pickerSheet.picker selectRow:min inComponent:0 animated:YES];
//            [pickerSheet.picker selectRow:max inComponent:1 animated:YES];
//            [pickerSheet show];
            
            [self showPicker];
            [_pickerVC.picker selectRow:min inComponent:0 animated:YES];
            [_pickerVC.picker selectRow:max inComponent:1 animated:YES];
            [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];

            
            break;
        }
        case 4:
        {
            int min = 0;
            int max = 0;
            
            for (int i = 0; i < [_yearList count]; i++) {
                if ([[_yearList objectAtIndex:i] isEqual:_yearMin]) {
                    min = i;
                }
                
                if ([[_yearList objectAtIndex:i] isEqual:_yearMax]) {
                    max = i;
                }
            }
            
//            PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//            pickerSheet.picker.delegate = self;
//            pickerSheet.picker.dataSource = self;
//            pickerSheet.delegate = self;
//            [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//            [pickerSheet.picker selectRow:min inComponent:0 animated:YES];
//            [pickerSheet.picker selectRow:max inComponent:1 animated:YES];
//            [pickerSheet show];
            
            [self showPicker];
            [_pickerVC.picker selectRow:min inComponent:0 animated:YES];
            [_pickerVC.picker selectRow:max inComponent:1 animated:YES];
            [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];
            
            break;
        }
        case 5:
        {
            int min = 0;
            int max = 0;
            
            for (int i = 0; i < [_oddList count]; i++) {
                if ([[_oddList objectAtIndex:i] isEqual:_oddMin]) {
                    min = i;
                }
                
                if ([[_oddList objectAtIndex:i] isEqual:_oddMax]) {
                    max = i;
                }
            }
            
//            PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//            pickerSheet.picker.delegate = self;
//            pickerSheet.picker.dataSource = self;
//            pickerSheet.delegate = self;
//            [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//            [pickerSheet.picker selectRow:min inComponent:0 animated:YES];
//            [pickerSheet.picker selectRow:max inComponent:1 animated:YES];
//            [pickerSheet show];
            
            [self showPicker];
            [_pickerVC.picker selectRow:min inComponent:0 animated:YES];
            [_pickerVC.picker selectRow:max inComponent:1 animated:YES];
            [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];
            
            break;
        }
        case 6:
        {
            FilterConfigVC *filterConfigVC = [[FilterConfigVC alloc] init];
            filterConfigVC.delegate = self;
            [self.navigationController pushViewController:filterConfigVC animated:YES];
            [filterConfigVC loadSelect:_dicColor];
            
            break;
        }
        case 7:
        {
            BodyTypesVC *bodyTypeVC = [[BodyTypesVC alloc] init];
            bodyTypeVC.isFilter = YES;
            bodyTypeVC.delegate = self;
            [self.navigationController pushViewController:bodyTypeVC animated:YES];
            [bodyTypeVC loadIsFilter];
            break;
        }
        case 8:
        {
//            PickerSheet *pickerSheet = [[PickerSheet alloc] init];
//            pickerSheet.picker.delegate = self;
//            pickerSheet.picker.dataSource = self;
//            pickerSheet.delegate = self;
//            [pickerSheet setTitlePicker:[_items objectAtIndex:indexPath.row]];
//            [pickerSheet.picker selectRow:_missionIndex inComponent:0 animated:YES];
//            [pickerSheet show];
            
            [self showPicker];
            [_pickerVC.picker selectRow:_missionIndex inComponent:0 animated:YES];
            [_pickerVC setTitlePicker:[_items objectAtIndex:indexPath.row]];
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (![Common isPortrait]) {
        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_tfSearch resignFirstResponder];
    return  YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    [_tfSearch resignFirstResponder];
}

#pragma mark - PickerSheet



#pragma mark - Reload Table

- (void) reloadInfoTableView
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_values count]; i++) {
        switch (i) {
            case 0:
            {
                if (!_companyItem || [_companyItem.companyName isEqualToString:TEXT_DONT_SET]) {
                    [tempArray addObject:TEXT_DONT_SET];
                } else {
                    [tempArray addObject:_companyItem.companyName];
                }
                break;
            }
            case 1:
            {
                if (!_catalogItem || [_catalogItem.model isEqualToString:TEXT_DONT_SET]) {
                    [tempArray addObject:TEXT_DONT_SET];
                } else {
                    [tempArray addObject:_catalogItem.model];
                }
                break;
            }
            case 2:
            {
                
                if ([_dicPref count] > 0) {
                    NSString *temp = @"";
                    for (NSString *key in _dicPref.allKeys) {
                        temp = [temp stringByAppendingString:key];
                        temp = [temp stringByAppendingString:@" "];
                    }
                    [tempArray addObject:temp];
                } else {
                    [tempArray addObject:TEXT_DONT_SET];
                }
                
                break;
            }
            case 3:
            {
                if ([_priceMin isEqualToString:TEXT_DONT_SET] && [_priceMax isEqualToString:TEXT_DONT_SET]) {
                    [tempArray addObject:TEXT_DONT_SET];
                } else {
                    [tempArray addObject:[NSString stringWithFormat:@"%@ ~ %@",_priceMin,_priceMax]];
                }
                break;
            }
            case 4:
            {
                if ([_yearMin isEqualToString:TEXT_DONT_SET] && [_yearMax isEqualToString:TEXT_DONT_SET]) {
                    [tempArray addObject:TEXT_DONT_SET];
                } else {
                    [tempArray addObject:[NSString stringWithFormat:@"%@ ~ %@",_yearMin,_yearMax]];
                }
                break;
            }
            case 5:
            {
                if ([_oddMin isEqualToString:TEXT_DONT_SET] && [_oddMax isEqualToString:TEXT_DONT_SET]) {
                    [tempArray addObject:TEXT_DONT_SET];
                } else {
                    [tempArray addObject:[NSString stringWithFormat:@"%@ ~ %@",_oddMin,_oddMax]];
                }
                break;
            }
            case 6:
            {
                if ([_dicColor count] > 0) {
                    NSString *temp = @"";
                    for (NSString *key in _dicColor.allKeys) {
                        temp = [temp stringByAppendingString:key];
                        temp = [temp stringByAppendingString:@" "];
                    }
                    [tempArray addObject:temp];
                } else {
                    [tempArray addObject:TEXT_DONT_SET];
                }
                
                break;
            }
            case 7:
            {
                [tempArray addObject:_bodyTypeName];
                break;
            }
            case 8:
            {
                [tempArray addObject:_missionItem];
                break;
            }
            default:
                [tempArray addObject:[_values objectAtIndex:i]];
                break;
        }
    }
    
    _values = [NSArray arrayWithArray:tempArray];
    [_tableView reloadData];
}

#pragma mark - PAPickerVCDelegate

- (void)showPicker{
    [_tfSearch resignFirstResponder];
    
    if (_popoverPicker) {
        if ([_popoverPicker isPopoverVisible]) {
            [_popoverPicker dismissPopoverAnimated:YES];
        } else {
            
            [_popoverPicker presentPopoverFromRect:CGRectMake(10.0, 44.0 * _selectItem, 640.0, 44.0)
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
        }
    } else {
        
        _popoverPicker = [[UIPopoverController alloc] initWithContentViewController:_pickerVC];
        [_popoverPicker presentPopoverFromRect:CGRectMake(10.0, 44.0 * _selectItem , 640.0, 44.0)
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
        
        _pickerVC.popover = _popoverPicker;
    }
}

- (void)didChangePickerWithDone:(BOOL)isDone date:(NSDate*)date
{
}

- (void)pickerSheet:(PAPickerVC *)pickerSheet dismissWithDone:(BOOL)done;
{
    if (done) {
        
        NSString *tempStr = TEXT_DONT_SET;
        
        switch (_selectItem) {
            case 0:
            {
                if (_companyItem) {
                    _companyItem = nil;
                }
                
                _companyIndex = [pickerSheet.picker selectedRowInComponent:0];
                
                CompanyItem *item = [_companyItems objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                
                if ([item.companyName isEqualToString:TEXT_DONT_SET]) {
                    _companyItem = nil;
                    tempStr = item.companyName;
                } else {
                    _companyItem = item;
                    tempStr = item.companyName;
                }
                
                // -----
                _catalogItem = nil;
                _catalogIndex = 0;
                
                break;
            }
            case 1:
            {
                if (_catalogItem) {
                    _catalogItem = nil;
                }
                
                _catalogIndex = [pickerSheet.picker selectedRowInComponent:0];
                
                _catalogItem = [_catalogItems objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                tempStr = _catalogItem.model;
                break;
            }
            case 2:
            {
                
                break;
            }
            case 3:
            {
                int indexMin = [pickerSheet.picker selectedRowInComponent:0];
                int indexMax = [pickerSheet.picker selectedRowInComponent:1];
                
                if (indexMin > indexMax && indexMax !=0 && indexMin !=0 ) {
                    _priceMax = [_priceList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                    _priceMin = [_priceList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                } else {
                    _priceMin = [_priceList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                    _priceMax = [_priceList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                }
                
                break;
            }
            case 4:
            {
                int indexMin = [pickerSheet.picker selectedRowInComponent:0];
                int indexMax = [pickerSheet.picker selectedRowInComponent:1];
                
                if (indexMin < indexMax && indexMax !=0 && indexMin !=0 ) {
                    _yearMin = [_yearList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                    _yearMax = [_yearList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                } else {
                    _yearMin = [_yearList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                    _yearMax = [_yearList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                }
                
                break;
            }
            case 5:
            {
                int indexMin = [pickerSheet.picker selectedRowInComponent:0];
                int indexMax = [pickerSheet.picker selectedRowInComponent:1];
                
                if (indexMin > indexMax && indexMax !=0 && indexMin !=0 ) {
                    _oddMin = [_oddList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                    _oddMax = [_oddList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                } else {
                    _oddMin = [_oddList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                    _oddMax = [_oddList objectAtIndex:[pickerSheet.picker selectedRowInComponent:1]];
                }
                
                break;
            }
            case 6:
            {
                
                break;
            }
            case 7:
            {
                
                break;
            }
            case 8:
            {
                _missionIndex = [pickerSheet.picker selectedRowInComponent:0];
                _missionItem = [_missionList objectAtIndex:[pickerSheet.picker selectedRowInComponent:0]];
                break;
            }
            default:
            {
                
                break;
            }
        }
        
        [self reloadInfoTableView];
        
    }
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (_selectItem) {
        case 0:
        {
            return 1;
            break;
        }
        case 1:
        {
            return 1;
            break;
        }
        case 2:
        {
            return 0;
            break;
        }
        case 3:
        {
            return 2;
            break;
        }
        case 4:
        {
            return 2;
            break;
        }
        case 5:
        {
            return 2;
            break;
        }
        case 6:
        {
            return 0;
            break;
        }
        case 7:
        {
            return 0;
            break;
        }
        case 8:
        {
            return 1;
            break;
        }
        default:
        {
            return 0;
            break;
        }
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (_selectItem) {
        case 0:
        {
            return [_companyItems count];
            break;
        }
        case 1:
        {
            return [_catalogItems count];;
            break;
        }
        case 2:
        {
            return 0;
            break;
        }
        case 3:
        {
            return [_priceList count];
            break;
        }
        case 4:
        {
            return [_yearList count];
            break;
        }
        case 5:
        {
            return [_oddList count];
            break;
        }
        case 6:
        {
            return 0;
            break;
        }
        case 7:
        {
            return 0;
            break;
        }
        case 8:
        {
            return [_missionList count];
            break;
        }
        default:
        {
            return 0;
            break;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (_selectItem) {
        case 0:
        {
            CompanyItem *item = [_companyItems objectAtIndex:row];
            return item.companyName;
            break;
        }
        case 1:
        {
            CatalogItem *item = [_catalogItems objectAtIndex:row];
            return item.model;
            break;
        }
        case 2:
        {
            return @"";
            break;
        }
        case 3:
        {
            return [_priceList objectAtIndex:row];
            break;
        }
        case 4:
        {
            return [_yearList objectAtIndex:row];
            break;
        }
        case 5:
        {
            return [_oddList objectAtIndex:row];
            break;
        }
        case 6:
        {
            return @"";
            break;
        }
        case 7:
        {
            return @"";
            break;
        }
        case 8:
        {
            return [_missionList objectAtIndex:row];
            break;
        }
        default:
        {
            return @"";
            break;
        }
    }
}

#pragma mark - FilterStatesVCDelegate

- (void) didSelectWithPref:(NSMutableDictionary*)dicPref
{
    if (dicPref == nil) {
        [_dicPref removeAllObjects];
    } else {
        _dicPref = [NSMutableDictionary dictionaryWithDictionary:dicPref];
    }
    
    [self reloadInfoTableView];
}

#pragma mark - FilterConfigVCDelegate
- (void)didSelectWithDic:(NSMutableDictionary*)dicSelect
{
    if (dicSelect == nil) {
        [_dicColor removeAllObjects];
    } else {
        _dicColor = [NSMutableDictionary dictionaryWithDictionary:dicSelect];
    }
    
    [self reloadInfoTableView];
}

#pragma mark - BodyTypesVCDelegate
- (void)didChangeBodyName:(NSString*)name code:(NSString*)code
{
    if ([name isEqualToString:TEXT_DONT_SET]) {
        _bodyTypeName = TEXT_DONT_SET;
        _bodyTypeCode = @"";
    } else {
        _bodyTypeCode = code;
        _bodyTypeName = name;
    }
    
    [self reloadInfoTableView];
}

- (void)didChangeBodyItem:(BodyTypeItem*)bodyTypeItem
{
    NSLog(@"didChangeBodyItem");
    if ([bodyTypeItem.bodyName isEqualToString:TEXT_DONT_SET] || bodyTypeItem == nil) {
        
        NSLog(@"didChangeBodyItem --> nil");
        
        _bodyTypeItem = nil;
        
        _bodyTypeName = TEXT_DONT_SET;
        _bodyTypeCode = @"";
        
    } else {
        
        
        _bodyTypeItem = bodyTypeItem;
        
        _bodyTypeCode = _bodyTypeItem.bodyCode;
        _bodyTypeName = _bodyTypeItem.bodyName;
    }
    
    [self reloadInfoTableView];
}

#pragma mark - SQL

- (void) readCompanyList
{
    if (_companyItems == nil) {
        _companyItems = [[NSMutableArray alloc] init];
        
        NSString *pathFileDB = [[AppDelegate shared].pathFileDB stringByAppendingPathComponent:COMPANY_MASTER_DB];
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
                
                CompanyItem *companyItem    = [[CompanyItem alloc] init];
                
                companyItem.companyID       = @"0";
                companyItem.companyCode     = @"0";
                companyItem.companyName     = TEXT_DONT_SET;
                companyItem.companyImage    = @"";
                companyItem.countryCode     = @"";
                companyItem.countryName     = @"";
                companyItem.useCarNum       = @"";
                companyItem.status          = @"";
                companyItem.viewNum         = @"";
                
                [_companyItems addObject:companyItem];
                
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
                        
                        [_companyItems addObject:companyItem];
                        
                    }
                }
                
            }
        }];
    }
}

- (BOOL) indexOfCompanyName:(NSString*)companyName
{
    for (int i = 0; i < [_companyItems count]; i++){
        CompanyItem *item = [_companyItems objectAtIndex:i];
        
        if ([item.companyName isEqualToString:companyName]) {
            return i;
        }
    }
    
    return 0;
}

- (BOOL) indexOfCatalogName:(NSString*)catalogName
{
    for (int i = 0; i < [_catalogItems count]; i++){
        CatalogItem *item = [_catalogItems objectAtIndex:i];
        
        if ([item.model isEqualToString:catalogName]) {
            NSLog(@"catalog index : %d",i);
            return i;
        }
    }
    
    return 0;
}

- (void) readCatalogList
{
    if (_catalogItems == nil) {
        _catalogItems = [[NSMutableArray alloc] init];
    } else {
        [_catalogItems removeAllObjects];
    }
    
    
    NSString *pathFileDB = [[AppDelegate shared].pathFileDB stringByAppendingPathComponent:CATALOG_MASTER_DB];
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
            
            
            
            for (NSDictionary *item in newArray) {
                
                if([[item objectForKey:@"company_code"] isEqual:_companyItem.companyCode] &&
                   ![[item objectForKey:@"car_num"] isEqual:@"0"]){
                    CatalogItem *catalogItem = [[CatalogItem alloc] init];
                    
                    catalogItem.catalogId   = [item objectForKey:@"id"];
                    catalogItem.model       = [item objectForKey:@"model"];
                    catalogItem.grade       = [item objectForKey:@"grade"];
                    catalogItem.companyCode = [item objectForKey:@"company_code"];
                    catalogItem.bodyCode    = [item objectForKey:@"body_code"];
                    catalogItem.photo       = [item objectForKey:@"photo"];
                    catalogItem.carNum      = [item objectForKey:@"car_num"];
                    
                    [_catalogItems addObject:catalogItem];
                }
            }
        }
    }];
}


@end
