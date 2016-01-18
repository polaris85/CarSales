//
//  HistoryVC.m
//  Car Sales
//
//  Created by Adam on 5/14/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "HistoryVC.h"
#import "ResultsVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "CDHistory.h"

#import "BodyTypeItem.h"
#import "CompanyItem.h"
#import "CatalogItem.h"


@interface HistoryVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    int _selectedRow;
     __weak IBOutlet UIView *_viewConfirm;
    BOOL _isDelete;
}

@property (nonatomic, strong) NSFetchedResultsController *historyResults;
@property (nonatomic, strong) NSMutableArray *items;
- (IBAction)confirmDeleteItem:(id)sender;

@end

@implementation HistoryVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = HISTORY_TITLE;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = HISTORY_TITLE;
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _items = [[NSMutableArray alloc] init];
    
    UIButton *btBack =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btBack setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btBack addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
    [btBack setFrame:CGRectMake(0, 0, 61, 30)];
    
    //add right
    UIButton *btTrash =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btTrash setImage:[UIImage imageNamed:@"icon_trash.png"] forState:UIControlStateNormal];
    [btTrash addTarget:self action:@selector(deleteList) forControlEvents:UIControlEventTouchUpInside];
    [btTrash setFrame:CGRectMake(0, 0, 37, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btTrash];
    
    [self historyResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated{
    _isDelete = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    _isDelete = NO;
}

#pragma mark - Other

- (void)backVC
{
    [self cancelDelete];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:[AppDelegate shared]
                                   selector:@selector(selectHome)
                                   userInfo:nil repeats:NO];
}

- (void)deleteList
{
    //add right
    UIButton *btTrash =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btTrash setImage:[UIImage imageNamed:@"btn_navi_cancel.png"] forState:UIControlStateNormal];
    [btTrash addTarget:self action:@selector(cancelDelete) forControlEvents:UIControlEventTouchUpInside];
    [btTrash setFrame:CGRectMake(0, 0, 68, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btTrash];
    
    
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    [_tableView setEditing:YES animated:YES];
    
    [self hideTabBar:self.tabBarController];
}

- (void)cancelDelete
{
    //add right
    UIButton *btTrash =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btTrash setImage:[UIImage imageNamed:@"icon_trash.png"] forState:UIControlStateNormal];
    [btTrash addTarget:self action:@selector(deleteList) forControlEvents:UIControlEventTouchUpInside];
    [btTrash setFrame:CGRectMake(0, 0, 37, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btTrash];
    
    _tableView.allowsMultipleSelectionDuringEditing = NO;
    [_tableView setEditing:NO animated:YES];
    
    [self showTabBar:self.tabBarController];
}

- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rectTable = _tableView.frame;
    CGRect rectView  = _viewConfirm.frame;
    
    rectTable.size.height = screenRect.size.height - 44 - 20 - 59;
    
    if ([Common user].isIPhone5Screen) {
        rectView.origin.y = 568 - 44 - 20 - 59;
    } else {
        rectView.origin.y = 480 - 44 - 20 - 59;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
    
    if ([Common isIOS7]) {
        rectTable.size.height += 20;
        rectView.origin.y += 20;
    }
    _tableView.frame = rectTable;
    _viewConfirm.frame = rectView;
    
    
    [UIView commitAnimations];
}



- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - 49.0;
    
    CGRect rectTable = _tableView.frame;
    CGRect rectView  = _viewConfirm.frame;
    
    rectTable.size.height = screenRect.size.height - 44 - 20 - 49;
    rectView.origin.y = 500.0;
    
    
    
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - 49.0;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    
    
    
    [UIView commitAnimations];
    
    _tableView.frame = rectTable;
    _viewConfirm.frame = rectView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
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
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        self.navigationItem.leftBarButtonItem.enabled = ([[tableView indexPathsForSelectedRows] count] > 0);
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setEditing:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ResultsVC *vc = [[ResultsVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
        CDHistory *item = [_historyResults.fetchedObjects objectAtIndex:indexPath.row];
        [vc loadListForCommonQueryDic:[self coverToQueryDic:[Common dictionaryFormData:item.dicQuery]]];
    }
}

#pragma mark - Others

- (NSMutableDictionary*) coverToQueryDic:(NSDictionary*)dicCommon
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in dicCommon.allKeys) {
        if ([key isEqualToString:@"CompanyItem"]) {
    
            [dic setObject:[CompanyItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else if ([key isEqualToString:@"BodyTypeItem"]) {
            
           [dic setObject:[BodyTypeItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else if ([key isEqualToString:@"CatalogItem"]) {
            
           [dic setObject:[CatalogItem itemWith:[dicCommon objectForKey:key]] forKey:key];
            
        } else {
            [dic setObject:[dicCommon objectForKey:key] forKey:key];
        }
    }
    
    return dic;
}


#pragma mark - Action

- (void)moveToTrash
{
    NSArray *indexPaths = [_tableView indexPathsForSelectedRows];
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"row" ascending:NO]]];
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        [self.items removeObjectAtIndex:indexPath.row];
    }
    
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    if ([self.items count] == 0) {
        [self setEditing:NO animated:YES];
    }
    
    AppDelegate *appDelegate = [AppDelegate shared];
    
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        CDHistory *item = [_historyResults.fetchedObjects objectAtIndex:indexPath.row];
        [appDelegate.managedObjectContext deleteObject:item];
    }
    
    [appDelegate saveContext];
}

- (IBAction)confirmDeleteItem:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"検索履歴を削除してもよろしいですか？"
                                                   delegate:self
                                          cancelButtonTitle:@"いいえ"
                                          otherButtonTitles:@"はい", nil];
    [alert show];
}

- (void)viewDidUnload {
    _viewConfirm = nil;
    [super viewDidUnload];
}

#pragma mark - UIAlerViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self moveToTrash];
        
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(cancelDelete) userInfo:nil repeats:NO];
    }
}

#pragma mark - Fetch CoreData

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!_isDelete) {
        [_items removeAllObjects];
        
        for (CDHistory *item in _historyResults.fetchedObjects) {
            [_items addObject:item.name];
        }
        
        [_tableView reloadData];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            break;
        }
        default:
            break;
    }
}

- (NSFetchedResultsController*) historyResults
{
    if (_historyResults == nil) {
        AppDelegate *appDelegate = [AppDelegate shared];
        NSString *entityName = @"CDHistory";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:appDelegate.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _historyResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                              managedObjectContext:appDelegate.managedObjectContext
                                                                sectionNameKeyPath:nil
                                                                         cacheName:cacheName];
        _historyResults.delegate = self;
        
        NSError *error = nil;
        [_historyResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        for (CDHistory *item in _historyResults.fetchedObjects) {
            [_items addObject:item.name];
            NSLog(@"%@ - %@",item.isData,item.name);
        }
        
        [_tableView reloadData];
        
    }
    
    return _historyResults;
}

@end
