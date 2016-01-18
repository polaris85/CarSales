//
//  BodyTypesVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "BodyTypesVC.h"
#import "VehiclesVC.h"

#import "BodyTypesCell.h"

#import "JT2ReadFileDB.h"
#import "Common.h"
#import "Define.h"
#import "BodyTypeItem.h"


@interface BodyTypesVC () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray *_items;
}

@end

@implementation BodyTypesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = BODY_TYPES_TITLE;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = BODY_TYPES_TITLE;
    
    if (![Common user].isIPhone) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _isFilter = NO;
    
    //load sqlite
    [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
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

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BodyTypesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BodyTypesCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BodyTypesCell" owner:self options:nil] lastObject];
    }
    
    BodyTypeItem *item = _items[indexPath.row];
    if (_isFilter) {
        cell.lbCell.text = item.bodyName;
    } else {
        cell.lbCell.text = [NSString stringWithFormat:@"%@ (%@)",item.bodyName, item.bodyAllNum];
    }
    cell.imgCell.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",item.bodyImage]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_isFilter) {
        BodyTypeItem *item = [_items objectAtIndex:indexPath.row];
        
        // set Dic query
        [[Common user].dicQuery removeAllObjects];
        [[Common user].dicQuery setObject:item forKey:@"BodyTypeItem"];
        
        VehiclesVC *vc = [[VehiclesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc loadDataWithBodyItem:item];
    } else {
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeBodyName:code:)]) {
            BodyTypeItem *item = [_items objectAtIndex:indexPath.row];
//            [_delegate didChangeBodyName:item.bodyName code:item.bodyCode];
            [_delegate didChangeBodyItem:item];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Other

- (void)loadIsFilter
{
//    _items = @[@"指定なし",
//               @"ハッチバック",
//               @"ミニバン",
//               @"セダン",
//               @"ステーションワゴン",
//               @"クロカン・SUV",
//               @"オープン",
//               @"ピックアップトラック",
//               @"トラック"];
    
    BodyTypeItem *bodyTypeItem = [[BodyTypeItem alloc] init];
    
    bodyTypeItem.bodyTypeId     = @"0";
    bodyTypeItem.bodyCode       = @"";
    bodyTypeItem.bodyName       = TEXT_DONT_SET;
    bodyTypeItem.bodyImage      = @"";
    bodyTypeItem.bodyAllNum     = @"0";
    bodyTypeItem.bodyViewNum    = @"";
    
    if ([_items count] == 0) {
        [self callReadDBWithPath:[AppDelegate shared].pathFileDB];
    }
    
    [_items addObject:bodyTypeItem];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bodyViewNum" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    _items = [NSMutableArray arrayWithArray:[_items sortedArrayUsingDescriptors:sortDescriptors]];
    
    _isFilter = YES;
    [_tableView reloadData];
}

#pragma mark - Other

- (void)callReadDBWithPath:(NSString *)pathDB {
    NSLog(@"BodyType --> callReadDBWithPath");
    NSString *pathFileDB = [pathDB stringByAppendingPathComponent:BODY_MASTER_DB];
    NSString *tableDB    = BODY_MASTER_TB;
    
    if ([AppDelegate shared].isUseLocalFile) {
        NSString* path = [[NSBundle mainBundle] pathForResource:BODY_MASTER_TB ofType:@"db"];
        if (path){
            pathFileDB = path;
        }
    }
    
    [JT2ReadFileDB readDatabaseWithPath:pathFileDB andTableName:tableDB returnResult:^(NSMutableArray *array, NSError *error) {
        if (array && array.count) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *item in array) {
                
                BodyTypeItem *bodyTypeItem = [[BodyTypeItem alloc] init];
                
                bodyTypeItem.bodyTypeId     = [item objectForKey:@"id"];
                bodyTypeItem.bodyCode       = [item objectForKey:@"body_code"];
                bodyTypeItem.bodyName       = [item objectForKey:@"body_name"];
                bodyTypeItem.bodyImage      = [item objectForKey:@"body_image"];
                bodyTypeItem.bodyAllNum     = [item objectForKey:@"body_all_num"];
                bodyTypeItem.bodyViewNum    = [item objectForKey:@"body_view_num"];
                
                [tempArray addObject:bodyTypeItem];
                
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bodyViewNum" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            _items = [NSMutableArray arrayWithArray:[tempArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            [_tableView reloadData];
        }
    }];
}

@end
