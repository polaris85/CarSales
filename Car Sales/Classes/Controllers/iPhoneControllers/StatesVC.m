//
//  StatesVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "StatesVC.h"
#import "ResultsVC.h"
#import "JT2ReadFileDB.h"
#import "Common.h"
#import "Define.h"

#import "CDPref.h"
#import "CMIndexBar.h"


@interface StatesVC () <UITableViewDataSource, UITableViewDelegate,CMIndexBarDelegate>
{
    __weak IBOutlet UITableView *_selectAllTableView;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIButton *_doneButtonItem;
    __weak IBOutlet UIView *_viewContainer;
    
    NSArray *_sections;
    NSArray *_items;
    
    NSMutableDictionary *_prefCode;
    NSMutableDictionary *_dicQuery;
    
    BOOL _selectAll;
}


@end

@implementation StatesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = STATES_TITLE;
        
        _sections = @[@"北海道・東北", @"関東", @"中部", @"近畿", @"中国", @"四国", @"九州", @"沖縄"];
        _items = @[@[@"北海道", @"青森県", @"岩手県", @"宮城県", @"秋田県", @"山形県", @"福島県"],
                   @[@"茨城県", @"栃木県", @"群馬県", @"埼玉県", @"千葉県", @"東京都", @"神奈川県"],
                   @[@"新潟県", @"富山県", @"石川県", @"福井県", @"山梨県", @"長野県", @" 岐阜県", @"静岡県", @"愛知県"],
                   @[@"三重県", @"滋賀県", @"京都府", @"大阪府", @"兵庫県", @"奈良県", @"和歌山県"],
                   @[@"鳥取県", @"島根県", @"岡山県", @"広島県", @"山口県"],
                   @[@"徳島県", @"香川県", @"愛媛県", @"高知県"],
                   @[@"福岡県", @"佐賀県", @"長崎県", @"熊本県", @"大分県", @"宮崎県", @"鹿児島県"],
                   @[@"沖縄県"]];
        _prefCode = [[NSMutableDictionary alloc] init];
        _dicQuery = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//- (void) viewWillAppear
//{
//    [_selectAllTableView setContentInset:UIEdgeInsetsZero];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = STATES_TITLE;
    
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_selectAllTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    CMIndexBar *indexBar ;
    
    if ([Common isIOS7]) {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 120.0, 80.0, self.view.frame.size.height-120)];
        indexBar.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    else
    {
        indexBar = [[CMIndexBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 20.0, 80.0, self.view.frame.size.height-80)];
    }
    
    [indexBar setIndexes:_sections ];
    
    indexBar.delegate = self;
    [self.view addSubview:indexBar];

    
    _selectAllTableView.dataSource = self;
    _selectAllTableView.delegate = self;
    _selectAllTableView.allowsMultipleSelectionDuringEditing = YES;
    _selectAllTableView.scrollEnabled = NO;

    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    
    _selectAllTableView.editing = YES;
    _tableView.editing = YES;
    
    _doneButtonItem.enabled = NO;
    
//    if ([Common user].isPrefCoreData) {
//        [self loadPerfCoredata];
//        NSLog(@"load Perf Coredata");
//    } else {
//        NSLog(@"load Perf File DB");
//        //sqlie
//        [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
//    }
//    
//    // load pref coredata
//    [self loadPerfCoredata];
    
    //sqlie
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
        
}

- (void)viewDidLayoutSubviews
{
    if ([Common isIOS7]) {
        CGRect tmpRect = _viewContainer.frame;
        tmpRect.origin.y += 64;
        _viewContainer.frame = tmpRect;
        _selectAllTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

        tmpRect = _tableView.frame;
        tmpRect.origin.y += 64;
        tmpRect.size.height -=64;
        _tableView.frame = tmpRect;
    }
    
    NSLog(@"%@", _selectAllTableView);
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
    if (tableView == _selectAllTableView) {
        NSLog(@"_selectAllTableView numberOfSectionsInTableView");
        return 1;
    }
    
    return [_sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        NSLog(@"_selectAllTableView titleForHeaderInSection");
        return nil;
    }
    return _sections[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        NSLog(@"_selectAllTableView heightForHeaderInSection");
        return 0;
    }
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    if (tableView == _selectAllTableView) {
        NSLog(@"_selectAllTableView viewForHeaderInSection");
        return nil;
    } else {
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
    
    
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    if (tableView == _selectAllTableView) {
//        return nil;
//    }
//    return _sections;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return index;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        NSLog(@"_selectAllTableView numberOfRowsInSection");

        return 1;
    }
    
    return [_items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _selectAllTableView) {
        NSLog(@"SelectAllCell");
        static NSString *CellIdentifier = @"SelectAllCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.textLabel.textColor = [UIColor blackColor];

            UIView *selectedBgView = [[UIView alloc] initWithFrame:cell.bounds];
            selectedBgView.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = selectedBgView;
        }
        cell.textLabel.text = STATES_SELECT_ALL;
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"Cell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _items[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _selectAllTableView) {
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _doneButtonItem.enabled = YES;
    if (tableView == _selectAllTableView) {
        _selectAll = YES;
        for (int section = 0; section < [_items count]; section++) {
            for (int row = 0; row < [_items[section] count]; row++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
                [_tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else {
        int all = 0;
        for (NSArray *array in _items) {
            all += [array count];
        }
        if ([[_tableView indexPathsForSelectedRows] count] == all) {
            _selectAll = YES;
            [_selectAllTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
        }
        
//        NSLog(@"Pref name : %@ --- %@",_items[indexPath.section][indexPath.row],[_prefCode objectForKey:_items[indexPath.section][indexPath.row]]);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _selectAllTableView) {
        _selectAll = NO;
        _doneButtonItem.enabled = NO;
        for (NSIndexPath *path in [_tableView indexPathsForSelectedRows]) {
            [_tableView deselectRowAtIndexPath:path animated:NO];
        }
    } else {
        _selectAll = NO;
        [_selectAllTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
        _doneButtonItem.enabled = ([[_tableView indexPathsForSelectedRows] count] > 0);
    }
}

- (IBAction)showResult
{
    ResultsVC *vc = [[ResultsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    if (_catalogItem) {
        NSLog(@"_catalogItem %@ ",_catalogItem.grade);
        [_dicQuery setObject:_catalogItem.grade forKey:PRA_GRADE];
    }
    
    if (_companyItem) {
        NSLog(@"_companyItem %@ ",_catalogItem.companyCode);
        [_dicQuery setObject:_companyItem.companyCode forKey:PRA_MAKER];
    }
    
    if (_selectAll) {
        NSLog(@"_selectAll %d ",_selectAll);
        [[Common user].dicQuery removeObjectForKey:@"PrefItem"];
    } else {
        NSArray *indexPaths = [_tableView indexPathsForSelectedRows];
        NSString *strPref =@"";
        
        NSMutableDictionary *dicPref = [[NSMutableDictionary alloc] init];
        
        for (int i=0; i< [indexPaths count]; i++) {
            NSIndexPath *indexPath = [indexPaths objectAtIndex:i];
            strPref = [strPref stringByAppendingString:[_prefCode objectForKey:_items[indexPath.section][indexPath.row]]];
            
            [dicPref setObject:[_prefCode objectForKey:_items[indexPath.section][indexPath.row]] forKey:_items[indexPath.section][indexPath.row]];
            
            if (i < [indexPaths count] - 1) {
                strPref = [strPref stringByAppendingString:@","];
            }
            
                    NSLog(@"pref : %@",strPref);
        }
        
        // add Pref
        [[Common user].dicQuery removeObjectForKey:@"PrefItem"];
        [[Common user].dicQuery setObject:dicPref forKey:@"PrefItem"];
        [_dicQuery setObject:strPref forKey:PRA_PREF];
    }
    
    // set query data for iOS 7
    vc.commonQueryDic = [Common user].dicQuery;
    [vc loadListForDic:nil];
    
}

#pragma mark - Others

- (void)loadPrefPrefWithPriceMin:(NSString*)priceMin priceMax:(NSString*)priceMax
{

    if (![priceMin isEqualToString:@"0000"]) {
        [_dicQuery setObject:priceMin forKey:PRA_PRICE_MIN];
    }
    
    if (![priceMax isEqualToString:@"0000"]) {
        [_dicQuery setObject:priceMax forKey:PRA_PRICE_MAX];
    }
}

#pragma mark - splite

//read data from file DB
- (void)callReadDBWithPath:(NSString *)pathDB {
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:PREF_MASTER_DB];
    NSString *tableDB    = PREF_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:PREF_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSLog(@"count array ===> %d",array.count);
            
            for (NSDictionary *item in array) {
                [_prefCode setObject:[item objectForKey:@"pref_code"] forKey:[item objectForKey:@"pref_name"]];
            }
           
        }
    }];
};

#pragma mark - Load Pref in CoreData

- (void) loadPerfCoredata
{
    NSString *temp = @"~";
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    BOOL isFirst = NO;
    
    for (CDPref *cdItem in [AppDelegate shared].prefResults.fetchedObjects) {
        
        if (![cdItem.sessionName isEqualToString:temp]) {
            
            if (isFirst) {
                [items addObject:tempArray];
                tempArray = [[NSMutableArray alloc] init];
            }
            
//            NSLog(@"temp: %@ - sessionName: %@",temp,cdItem.sessionName);
            temp = cdItem.sessionName;
            [sections addObject:cdItem.sessionName];
            isFirst = YES;
        }
        
        [tempArray addObject:cdItem.prefName];
        
        [_prefCode setObject:[NSString stringWithFormat:@"%d",cdItem.prefCode] forKey:cdItem.prefName];
        
    }
    
    [items addObject:tempArray];
    
    _items = [NSArray arrayWithArray:items];
    _sections = [NSArray arrayWithArray:sections];
    
    [_tableView reloadData];
}

@end
