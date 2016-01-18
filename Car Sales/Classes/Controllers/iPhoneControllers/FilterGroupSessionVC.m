//
//  FilterGroupSessionVC.m
//  Car Sales
//
//  Created by Le Phuong Tien on 5/28/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "FilterGroupSessionVC.h"
#import "Common.h"

@interface FilterGroupSessionVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *_table;
    
    NSArray *_sections;
    NSArray *_items;
    
    int _selectItem;
}

@end

@implementation FilterGroupSessionVC

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
    
    if (![Common user].isIPhone) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    _table = nil;
    [super viewDidUnload];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_selectItem == 1) {
        return [_sections count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_selectItem == 1) {
        return _sections[section];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_selectItem == 1) {
        return 23;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_selectItem == 1) {
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
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectItem == 1) {
        return [_items[section % [_items count]] count];
    } else {
        return [_items count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if (_selectItem == 1) {
        cell.textLabel.text = _items[indexPath.section % [_items count]][indexPath.row];
    } else {
        cell.textLabel.text = _items[indexPath.row];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - other

- (void)loadSelectItem1
{
    self.title = MANUFACTURES_TITLE;
    _selectItem = 1;
    
    _sections = @[@"日本", @"ドイツ", @"イギリス", @"イタリア", @"フランス", @"スウェーデン", @"オランダ", @"?", @"?", @"?"];
    _items = @[@[@"レクサス", @"サンプル", @"サンプル"], @[@"サンプル", @"サンプル", @"サンプル"]];
    
    [_table reloadData];
}

- (void)loadSelectItem2
{
    self.title = VEHICLES_TITLE;
    _selectItem = 2;
    
    _items = @[@"Item1",@"Item2",@"Item3",@"Item4",@"Item5",@"Item6",@"Item7",@"Item8",@"Item9",@"Item10",@"Item11",@"Item12",@"Item13",@"Item14",@"Item15",@"Item16",@"Item17",@"Item18",@"Item19",@"Item20",@"Item21",@"Item22",@"Item23",@"Item24",@"Item25",@"Item26",@"Item27",@"Item28",@"Item29",@"Item30",@"Item31"];
    
    [_table reloadData];
}


@end
