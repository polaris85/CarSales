//
//  SortVC.m
//  Car Sales
//
//  Created by Adam on 5/17/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "SortVC.h"
#import "SortCell.h"
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "Common.h"
#import "Define.h"

@interface SortVC () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_items;
}

@end

@implementation SortVC

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
    
    self.trackedViewName = SORT_TITLE;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
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
    SortCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SortCell" owner:self options:nil] lastObject];
    }
    
    cell.lbCell.text = _items[indexPath.row];
    
    if ([Common isIOS7]) {
        cell.layer.cornerRadius  = 5.0f;
        cell.layer.borderWidth = 0.6f;
        cell.layer.borderColor = [[UIColor  lightGrayColor] CGColor];
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
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
}

@end
