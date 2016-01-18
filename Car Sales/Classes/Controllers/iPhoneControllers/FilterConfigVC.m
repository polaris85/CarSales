//
//  FilterConfigVC.m
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "FilterConfigVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "JT2ReadFileDB.h"

@interface FilterConfigVC () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIBarButtonItem *_doneButtonItem;
    
    NSMutableArray *_items;
    NSMutableArray *_values;
    
    BOOL _isNoChoiceColor;
}

@end

@implementation FilterConfigVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = FILTER_CONFIG_TITLE;
        
//        _items = @[@"指定なし",
//                   @"白",
//                   @"黄色",
//                   @"ベージュ",
//                   @"緑色",
//                   @"青色",
//                   @"紺色",
//                   @"赤色",
//                   @"オレンジ色",
//                   @"ピンク",
//                   @"紫色",
//                   @"茶色",
//                   @"グレー",
//                   @"黒",
//                   @"シルバー",
//                   @"ゴールド",
//                   @"その他"];
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
    
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    _tableView.editing = YES;
    _doneButtonItem.enabled = NO;
    
    _items = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] init];
    
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.textLabel.text = _items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        _isNoChoiceColor = YES;
        for (NSIndexPath *path in [_tableView indexPathsForSelectedRows]) {
            if (path.row != 0) {
                [_tableView deselectRowAtIndexPath:path animated:NO];
            }
        }
    } else {
        _isNoChoiceColor = NO;
        [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO];
    }
    
    _doneButtonItem.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _doneButtonItem.enabled = ([[_tableView indexPathsForSelectedRows] count] > 0);
}

#pragma mark - Action

- (IBAction)saveConfig
{
    
    
    if (_isNoChoiceColor) {
        [_delegate didSelectWithDic:nil];
    } else {
        NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] init];
        NSArray *arraySelect = [_tableView indexPathsForSelectedRows];
        
        for (NSIndexPath *path in arraySelect) {
            [dicInfo setObject:[_values objectAtIndex:path.row] forKey:[_items objectAtIndex:path.row]];
        }
        
        [_delegate didSelectWithDic:dicInfo];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - sqlite

//read data from file DB
- (void)callReadDBWithPath:(NSString *)pathDB {
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:COLOR_MASTER_DB];
    NSString *tableDB    = COLOR_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:COLOR_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSLog(@"count array ===> %d",array.count);
            [_items addObject:TEXT_DONT_SET];
            [_values addObject:@""];
            
            for (NSDictionary *item in array) {
                [_items addObject:[item objectForKey:@"color_name"]];
                [_values addObject:[item objectForKey:@"color_code"]];
            }
        }
        
        [_tableView reloadData];
        
    }];
}

- (void)loadSelect:(NSMutableDictionary*)dicInfo
{
    if (dicInfo) {
        
        for (int i = 0; i < [_items count]; i++) {
            for (int j = 0; j < [dicInfo.allKeys count]; j++) {
                if ([[dicInfo.allKeys objectAtIndex:j] isEqualToString:[_items objectAtIndex:i]]) {
                    _doneButtonItem.enabled = YES;
                    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
        }
        
        
    }
}

@end
