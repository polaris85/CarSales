//
//  RecentsVC.m
//  Car Sales
//
//  Created by Adam on 5/14/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "RecentsVC.h"
#import "DetailsVC.h"
#import "Car.h"
#import "CarCell.h"
#import "ResultsCell.h"
#import "AppDelegate.h"
#import "Common.h"
#import "Define.h"

#import "CDRecents.h"
#import "CarItem.h"
#import "Downloader.h"

@interface RecentsVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate, DownloaderDelegate, DetailsVCDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    int _selectedRow;
    __weak IBOutlet UIView *_viewConfirm;
    
    BOOL _isDelete;
    NSMutableArray *_items;
    
    BOOL _isHideTable;
}

@property (nonatomic, strong) NSFetchedResultsController *recentsResults;
- (IBAction)confirmDeleteItem:(id)sender;

@end

@implementation RecentsVC

- (id)init
{
    self = [super init];
    if (self) {
        self.title = RECENTS_TITLE;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        _selectedRow = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = RECENTS_TITLE;
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
    
    // coreData
    [self recentsResults];
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
    _isHideTable = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rectTable = _tableView.frame;
    CGRect rectView  = _viewConfirm.frame;
    
    NSLog(@"screenRect.size.height = %f",screenRect.size.height);
    rectTable.size.height = screenRect.size.height - 44 - 20 - 59;
    
    if ([Common user].isIPhone5Screen) {
        rectView.origin.y = 568 - 44 - 20 - 59;
    } else {
        rectView.origin.y = 480 - 44 - 20 - 59;
    }
    
    if ([Common isIOS7]) {
        rectTable.size.height += 20;
        rectView.origin.y += 20;
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
    
    _tableView.frame = rectTable;
    _viewConfirm.frame = rectView;
    
    
    [UIView commitAnimations];
}



- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    _isHideTable = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - 49.0;
    
    NSLog(@"screenRect.size.height = %f",screenRect.size.height);
    
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
    return [_items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 93;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultsCell" owner:self options:nil] lastObject];
    }
    
    if (_isHideTable) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CarItem *car = [_items objectAtIndex:indexPath.row];
    //    cell.carImg.image = [UIImage imageNamed:car.icon];
    
    cell.titleLb.text = car.carName;
    cell.bonusLb.text = car.carGrade;
    cell.priceLb.text = car.carPrice;
    
    cell.carNew.hidden = !car.isNew;
    cell.lbDelete.hidden = !car.isDel;
    
    cell.more1.text = car.carYear;
    cell.more2.text = car.carOdd;
    cell.more3.text = car.carPref;
    
    cell.multipeImg.hidden      = !car.isSmallImage;
    cell.imgMultipeImg.hidden   = !car.isSmallImage;
    
    if (car.thumbImage) {
        cell.carImg.image = car.thumbImage;
    } else {
        cell.carImg.image = [UIImage imageNamed:@"img_no_image.png"];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
//        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CarItem *item = [_items objectAtIndex:indexPath.row];
        
        if (!item.isDel) {
            DetailsVC *vc = [[DetailsVC alloc] init];
            vc.delegate = self;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            
            
            vc.carItem = item;
            if(![Common isIOS7]){

            [vc setFavoriteCar];
            
            [vc getDetailCarWSByID:item.carId];
            }
        }
    }
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

- (void)didSelectCell:(int)indexTag{
    
    
    
    if (_tableView.editing) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        CarItem *item = [_items objectAtIndex:indexTag];
        
        if (!item.isDel) {
            DetailsVC *vc = [[DetailsVC alloc] init];
            vc.delegate = self;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            
            vc.carItem = item;
            if(![Common isIOS7]){

            [vc setFavoriteCar];
            
            [vc getDetailCarWSByID:item.carId];
            }
        }
    }
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
    
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        CDRecents *item = [_recentsResults.fetchedObjects objectAtIndex:indexPath.row];
        [[AppDelegate shared].managedObjectContext deleteObject:item];
    }
    [[AppDelegate shared] saveContext];
}

- (NSMutableArray *)items
{
    if (_items) {
        return _items;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [items addObject:[[Car alloc] init]];
    }
    
    _items = items;
    return _items;
}

- (IBAction)confirmDeleteItem:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"履歴を削除してもよろしいですか？"
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
    [_items removeAllObjects];
    for (CDRecents *cdItem in _recentsResults.fetchedObjects) {
        CarItem *car = [[CarItem alloc] init];
        
        car.carId = cdItem.carId;
        car.carName = cdItem.carName;
        car.carGrade = cdItem.carGrade;
        car.carPrice = cdItem.carPrice;
        car.carYear = cdItem.carYear;
        car.carOdd = cdItem.carOdd;
        car.carPref = cdItem.carPref;
        car.thumd = cdItem.thumd;
        car.isNew = cdItem.isNew;
        car.isSmallImage = cdItem.isSmallImage;
        car.isDel = cdItem.isDel;
        
        [_items addObject:car];
        
    }
    
    if (!_isDelete) {
        [_tableView reloadData];
        [self downLoadThumb];
    } else {
        [self downLoadThumb];
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

- (NSFetchedResultsController*)recentsResults
{
    if (_recentsResults == nil) {
        NSString *entityName = @"CDRecents";
        AppDelegate *appDelegate = [AppDelegate shared];
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:appDelegate.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carId != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _recentsResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:appDelegate.managedObjectContext
                                                                  sectionNameKeyPath:nil
                                                                           cacheName:cacheName];
        _recentsResults.delegate = self;
        
        NSError *error = nil;
        [_recentsResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        for (CDRecents *cdItem in _recentsResults.fetchedObjects) {
            CarItem *car = [[CarItem alloc] init];
            
            car.carId = cdItem.carId;
            car.carName = cdItem.carName;
            car.carGrade = cdItem.carGrade;
            car.carPrice = cdItem.carPrice;
            car.carYear = cdItem.carYear;
            car.carOdd = cdItem.carOdd;
            car.carPref = cdItem.carPref;
            car.thumd = cdItem.thumd;
            car.isNew = cdItem.isNew;
            car.isSmallImage = cdItem.isSmallImage;
            car.isDel = cdItem.isDel;
            
            [_items addObject:car];
            
        }
        
        [_tableView reloadData];
        [self downLoadThumb];
    }
    
    return _recentsResults;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        if (!decelerate) {
            [self downLoadThumb];
        }
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self downLoadThumb];
    }
}

#pragma mark - DownloaderDelegate

- (void) downLoadThumb
{
    for (ResultsCell *cell in _tableView.visibleCells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        CarItem *item = [_items objectAtIndex:indexPath.row];
        
        if (!item.thumbImage) {
            if (![item.thumd isEqualToString:@""]) {
                Downloader *down = [[Downloader alloc] init];
                down.delegate = self;
                down.identifier = indexPath;
                [down get:[NSURL URLWithString:item.thumd]];
            } else {
                item.thumbImage = [UIImage imageNamed:@"no_image_car.png"];
                cell.carImg.image = [UIImage imageNamed:@"no_image_car.png"];
            }
        } else {
            
        }
    }
}

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier
{
    NSIndexPath *indexPath = (NSIndexPath*)identifier;
    if (indexPath.row < [_items count]) {
        ResultsCell *cell = (ResultsCell*) [_tableView cellForRowAtIndexPath:indexPath];
        CarItem *item = [_items objectAtIndex:indexPath.row];
        
        if (data.length > 0) {
            cell.carImg.image = [UIImage imageWithData:data];
            item.thumbImage = [UIImage imageWithData:data];
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    
}

#pragma mark - DetailsVCDelegate 
- (void)carNoDataWithID:(NSString*)carID
{
    for (CDRecents *item in _recentsResults.fetchedObjects) {
        if ([item.carId isEqualToString:carID]) {
            item.isDel = YES;
            [[AppDelegate shared] saveContext];
            break;
        }
    }
}

@end
