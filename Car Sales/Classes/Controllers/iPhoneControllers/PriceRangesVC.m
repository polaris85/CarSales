//
//  PriceRangesVC.m
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "PriceRangesVC.h"
#import "StatesVC.h"
#import "Common.h"
#import "AppDelegate.h"
#import "Define.h"


@interface PriceRangesVC () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_items;
}

@end

@implementation PriceRangesVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = PRICE_RANGES_TITLE;
        _items = @[@"~20万円",
                   @"20~40万円",
                   @"40~60万円",
                   @"60~80万円",
                   @"80~100万円",
                   @"100~150万円",
                   @"150~200万円",
                   @"200~250万円",
                   @"250~300万円",
                   @"300~350万円",
                   @"350~400万円",
                   @"400~450万円",
                   @"450~500万円",
                   @"500~600万円",
                   @"600~700万円",
                   @"700~800万円",
                   @"800~900万円",
                   @"900~1000万円"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = PRICE_RANGES_TITLE;
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSMutableDictionary *priceItem = [[NSMutableDictionary alloc] init];
    
    NSArray *array = [[_items objectAtIndex:indexPath.row] componentsSeparatedByString:@"~"] ;
    [priceItem setObject:array[0] forKey:@"priceNameMin"];
    NSString *priceMin = [NSString stringWithFormat:@"%@0000",array[0]];
    array = [array[1] componentsSeparatedByString:@"万円"];
    [priceItem setObject:array[0] forKey:@"priceNameMax"];
    NSString *priceMax = [NSString stringWithFormat:@"%@0000",array[0]];;
    
    // set Dic query
    [[Common user].dicQuery removeAllObjects];
    [[Common user].dicQuery setObject:priceItem forKey:@"PriceItem"];
    
    NSLog(@"Min: %@ --> Max: %@",priceMin,priceMax);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    StatesVC *vc = [[StatesVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc loadPrefPrefWithPriceMin:priceMin priceMax:priceMax];
}

@end
