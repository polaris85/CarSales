//
//  FilterStatesVC.m
//  Car Sales
//
//  Created by Le Phuong Tien on 5/28/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "FilterStatesVC.h"
#import "AppDelegate.h"
#import "JT2ReadFileDB.h"
#import "Common.h"
#import "Define.h"

#import "CDPref.h"

@interface FilterStatesVC () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_selectAllTableView;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIButton *_doneButtonItem;
    
    NSArray *_sections;
    NSArray *_items;
    
    NSMutableDictionary *_prefCode;
    NSMutableDictionary *_dicQuery;
    
    BOOL _selectAll;
}

- (IBAction)showResult;

@end

@implementation FilterStatesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = STATES_TITLE;
        
        _sections = @[@"北海道・東北", @"関東", @"中部", @"近畿", @"中国", @"四国", @"九州", @"沖縄"];
        _items = @[@[@"北海道", @"青森県", @"岩手県", @"宮城県", @"秋田県", @"山形県", @"福島県"],
                   @[@"茨城県", @"栃木県", @"群馬県", @"埼玉県", @"千葉県", @"東京都", @"神奈川県"],
                   @[@"新潟県", @"富山県", @"石川県", @"福井県", @"山梨県", @"長野県", @"岐阜県", @"静岡県", @"愛知県"],
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![Common user].isIPhone) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
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
//    } else {
//        //sqlie
//        [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
//    }
//    
//    //load in coredata
//    [self loadPerfCoredata];
    
    //sqlie
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _selectAllTableView) {
        return 1;
    }
    
    return [_sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        return nil;
    }
    return _sections[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        return 0;
    }
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    if (tableView == _selectAllTableView) {
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _selectAllTableView) {
        return 1;
    }
    
    return [_items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _selectAllTableView) {
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
        cell.textLabel.text = TEXT_DONT_SET;
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
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
//        for (int section = 0; section < [_items count]; section++) {
//            for (int row = 0; row < [_items[section] count]; row++) {
//                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
//                [_tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
//            }
//        }
        for (NSIndexPath *path in [_tableView indexPathsForSelectedRows]) {
            [_tableView deselectRowAtIndexPath:path animated:NO];
        }
    } else {
        int all = 0;
        for (NSArray *array in _items) {
            all += [array count];
        }
        
//        if ([[_tableView indexPathsForSelectedRows] count] == all) {
//            _selectAll = YES;
//            [_selectAllTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
//        } else {
//        }
        
//         NSLog(@"Pref name : %@ --- %@",_items[indexPath.section][indexPath.row],[_prefCode objectForKey:_items[indexPath.section][indexPath.row]]);
        
        _selectAll = NO;
        [_selectAllTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
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
    
    NSArray *arraySelect = [_tableView indexPathsForSelectedRows];
    
    if ([arraySelect count] == 0) {
        [_delegate didSelectWithPref:nil];
    } else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        for (NSIndexPath *indexPath in arraySelect) {
            [dic setObject:[_prefCode objectForKey:_items[indexPath.section][indexPath.row]] forKey:_items[indexPath.section][indexPath.row]];
        }
        [_delegate didSelectWithPref:dic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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

- (void) loadSelectDic:(NSMutableDictionary*)dicInfo
{
    for (int session = 0; session < [_items count]; session++) {
        for (int index = 0; index < [[_items objectAtIndex:session] count]; index++) {
            for (int select = 0; select < [dicInfo.allKeys count]; select++) {
                if ([[dicInfo.allKeys objectAtIndex:select] isEqualToString:_items[session][index] ]) {
                    _doneButtonItem.enabled = YES;
                    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:session]
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
        }
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
//                NSLog(@"code: %@ - name: %@",[item objectForKey:@"pref_code"],[item objectForKey:@"pref_name"]);
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
