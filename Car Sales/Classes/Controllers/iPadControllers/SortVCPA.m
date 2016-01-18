//
//  SortVCPA.m
//  Car Sales
//
//  Created by TienLP on 6/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "SortVCPA.h"

@interface SortVCPA () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_items;
}

@end

@implementation SortVCPA

- (id)init
{
    self = [super init];
    if (self) {
        self.title = SORT_TITLE;
        _items = @[@"価格：高い順",
                   @"価格：安い順",
                   @"年式：新しい順",
                   @"年式：古い順",
                   @"走行距離：少ない順"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 220);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.popover) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPopover)];
        self.navigationItem.rightBarButtonItem = nil;
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeSortWithType:)]) {
        switch (indexPath.row) {
            case 0:
            {
                [_delegate didChangeSortWithType:SortTypeHighestPrice];
                break;
            }
            case 1:
            {
                [_delegate didChangeSortWithType:SortTypeCheapPrice];
                break;
            }
            case 2:
            {
                [_delegate didChangeSortWithType:SortTypeNewYear];
                break;
            }
            case 3:
            {
                [_delegate didChangeSortWithType:SortTypeOldestYear];
                break;
            }
            case 4:
            {
                [_delegate didChangeSortWithType:SortTypeLessMileage];
                break;
            }
            default:
                [_delegate didChangeSortWithType:SortTypeNone];
                break;
        }
    }
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Action

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
}

@end
