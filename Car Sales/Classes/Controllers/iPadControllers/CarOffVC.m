//
//  CarOffVC.m
//  Car Sales
//
//  Created by TienLP on 7/2/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import "CarOffVC.h"
#import "AppDelegate.h"
#import "Define.h"
#import "Common.h"
#import "SegmentView.h"
#import "Downloader.h"

#import "CDFavorites.h"
#import "CDRecents.h"
#import "CDHistory.h"

#import "BodyTypeItem.h"
#import "CompanyItem.h"
#import "CatalogItem.h"

#import "ResultsCell.h"

@interface CarOffVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, DownloaderDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet SegmentView *_segmentView;
    
    __weak IBOutlet UIView *_viewConfirm;
    
    __weak IBOutlet UIButton *_btn1;
    __weak IBOutlet UIButton *_btn2;
    __weak IBOutlet UIButton *_btn3;
    
    __weak IBOutlet UITableView *_tableview1;
    __weak IBOutlet UITableView *_tableview2;
    __weak IBOutlet UITableView *_tableview3;
    
    NSMutableArray *_items1, *_items2, *_items3;
    
    BOOL _isHideTable,_isDelete;
    int _indexSelectTable;
}

@property (nonatomic, strong) NSFetchedResultsController *recentsResults;
@property (nonatomic, strong) NSFetchedResultsController *favoritesResults;
@property (nonatomic, strong) NSFetchedResultsController *historyResults;

- (IBAction)confirmDeleteItem:(id)sender;


@end

@implementation CarOffVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPopover)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteList)];

        [[NSBundle mainBundle] loadNibNamed:@"SegmentView" owner:self options:nil];
        self.navigationItem.titleView = _segmentView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableview1.delegate = self;
    _tableview1.dataSource = self;
    
    _tableview2.delegate = self;
    _tableview2.dataSource = self;
    
    _tableview3.delegate = self;
    _tableview3.dataSource = self;
    
    _items1 = [[NSMutableArray alloc] init];
    _items2 = [[NSMutableArray alloc] init];
    _items3 = [[NSMutableArray alloc] init];
    
    _indexSelectTable = 1;
    
    // fix for table view
    // http://stackoverflow.com/questions/18773239/how-to-fix-uitableview-separator-on-ios-7
    if ([_tableview1 respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableview1 setSeparatorInset:UIEdgeInsetsZero];
        [_tableview2 setSeparatorInset:UIEdgeInsetsZero];
        [_tableview3 setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self favoritesResults];
    [self recentsResults];
    [self historyResults];
}

- (void)viewDidUnload {
    _tableview1 = nil;
    _tableview2 = nil;
    _tableview3 = nil;
    _segmentView = nil;
    _viewConfirm = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated{
    _isDelete = YES;
    [self reloadAllTable];
}

- (void) viewWillDisappear:(BOOL)animated
{
    _isDelete = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Others

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
}

- (void)onSegmentChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) {
        
    }
    else if (segment.selectedSegmentIndex == 1) {
        
    }
    else if (segment.selectedSegmentIndex == 2) {
        
    }
    
}

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

-(IBAction)changeListInTable:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    [_btn1 setBackgroundImage:[UIImage imageNamed:@"btn1_segment_popover.png"] forState:UIControlStateNormal];
    [_btn2 setBackgroundImage:[UIImage imageNamed:@"btn2_segment_popover.png"] forState:UIControlStateNormal];
    [_btn3 setBackgroundImage:[UIImage imageNamed:@"btn3_segment_popover.png"] forState:UIControlStateNormal];
    
    CGRect rect = _tableview1.frame;
    rect.origin.x = 640;
    
    _tableview1.frame = rect;
    _tableview2.frame = rect;
    _tableview3.frame = rect;
    
    rect.origin.x = 0;
    
    if (button == _btn1) {
        [_btn1 setBackgroundImage:[UIImage imageNamed:@"btn1_active_segment_popover.png"] forState:UIControlStateNormal];
        _tableview1.frame = rect;
        _indexSelectTable = 1;
    } else if (button == _btn2) {
        [_btn2 setBackgroundImage:[UIImage imageNamed:@"btn2_active_segment_popover.png"] forState:UIControlStateNormal];
        _tableview2.frame = rect;
        _indexSelectTable = 2;
    } else if (button == _btn3) {
        [_btn3 setBackgroundImage:[UIImage imageNamed:@"btn3_active_segment_popover.png"] forState:UIControlStateNormal];
        _tableview3.frame = rect;
        _indexSelectTable = 3;
    }
}

- (void)reloadAllTable{
    [_tableview1 reloadData];
    [_tableview2 reloadData];
    [_tableview3 reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableview1) {
        return [_items1 count];
    } else if (tableView == _tableview2) {
        return [_items2 count];
    } else if (tableView == _tableview3) {
        return [_items3 count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableview1) {
        return 93;
    } else if (tableView == _tableview2) {
        return 93;
    } else if (tableView == _tableview3) {
        return 44;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _tableview1) {
        ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultsCell" owner:self options:nil] lastObject];
        }
        
        if (_isHideTable) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        CarItem *car = [_items1 objectAtIndex:indexPath.row];
        
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
        
    } else if (tableView == _tableview2) {
        ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultsCell" owner:self options:nil] lastObject];
        }
        
        if (_isHideTable) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        CarItem *car = [_items2 objectAtIndex:indexPath.row];
        
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
    } else if (tableView == _tableview3) {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = _items3[indexPath.row];
        return cell;
        
    } else {
        return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (tableView == _tableview1) {
            CarItem *item = [_items1 objectAtIndex:indexPath.row];
            
            if (!item.isDel && _delegate && [_delegate respondsToSelector:@selector(showDetailCar:)]) {
                [_popover dismissPopoverAnimated:YES];
                [_delegate showDetailCar:item];
            }
            
        } else if (tableView == _tableview2) {
            CarItem *item = [_items2 objectAtIndex:indexPath.row];
            
            if (!item.isDel && _delegate && [_delegate respondsToSelector:@selector(showDetailCar:)]) {
                [_popover dismissPopoverAnimated:YES];
                [_delegate showDetailCar:item];
            }
        } else if (tableView == _tableview3) {
            CDHistory *item = [_historyResults.fetchedObjects objectAtIndex:indexPath.row];
            
            if (_delegate && [_delegate respondsToSelector:@selector(loadResultDic:)]) {
                [_popover dismissPopoverAnimated:YES];
                [_delegate loadResultDic:[self coverToQueryDic:[Common dictionaryFormData:item.dicQuery]]];
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

#pragma mark - Fetch CoreData

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == _favoritesResults) {
        [_items1 removeAllObjects];
        for (CDFavorites *cdItem in _favoritesResults.fetchedObjects) {
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
            
            [_items1 addObject:car];
            
        }
        
        if (!_isDelete) {
            [_tableview1 reloadData];
            [self downLoadThumb];
        } else {
            [self downLoadThumb];
        }
    } else if (controller == _recentsResults) {
        [_items2 removeAllObjects];
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
            
            [_items2 addObject:car];
            
        }
        
        if (!_isDelete) {
            [_tableview2 reloadData];
            [self downLoadThumb];
        } else {
            [self downLoadThumb];
        }
    } else if (controller == _historyResults) {
        if (!_isDelete) {
            [_items3 removeAllObjects];
            
            for (CDHistory *item in _historyResults.fetchedObjects) {
                [_items3 addObject:item.name];
            }
            
            [_tableview3 reloadData];
        }
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

- (NSFetchedResultsController*)favoritesResults
{
    if (_favoritesResults == nil) {
        NSString *entityName = @"CDFavorites";
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
        _favoritesResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:appDelegate.managedObjectContext
                                                                  sectionNameKeyPath:nil
                                                                           cacheName:cacheName];
        _favoritesResults.delegate = self;
        
        NSError *error = nil;
        [_favoritesResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        for (CDFavorites *cdItem in _favoritesResults.fetchedObjects) {
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
            
            [_items1 addObject:car];
            
        }
        
        [_tableview1 reloadData];
        [self downLoadThumb];
    }
    
    return _favoritesResults;
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
            
            [_items2 addObject:car];
            
        }
        
        [_tableview2 reloadData];
        [self downLoadThumb];
    }
    
    return _recentsResults;
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
            [_items3 addObject:item.name];
//            NSLog(@"%@ - %@",item.isData,item.name);
        }
        
        [_tableview3 reloadData];
        
    }
    
    return _historyResults;
}


#pragma mark - DownloaderDelegate

- (void) downLoadThumb
{
    NSLog(@"downLoadThumb");
    
    for (ResultsCell *cell in _tableview1.visibleCells) {
        NSIndexPath *indexPath = [_tableview1 indexPathForCell:cell];
        CarItem *item = [_items1 objectAtIndex:indexPath.row];
        
        if (!item.thumbImage) {
            if (![item.thumd isEqualToString:@""]) {
                Downloader *down = [[Downloader alloc] init];
                down.delegate = self;
                down.identifier = indexPath;
                down.index = 1;
                [down get:[NSURL URLWithString:item.thumd]];
            } else {
                item.thumbImage = [UIImage imageNamed:@"no_image_car.png"];
                cell.carImg.image = [UIImage imageNamed:@"no_image_car.png"];
            }
        } else {
            
        }
    }
    
    for (ResultsCell *cell in _tableview2.visibleCells) {
        NSIndexPath *indexPath = [_tableview2 indexPathForCell:cell];
        CarItem *item = [_items2 objectAtIndex:indexPath.row];
        
        if (!item.thumbImage) {
            if (![item.thumd isEqualToString:@""]) {
                Downloader *down = [[Downloader alloc] init];
                down.delegate = self;
                down.identifier = indexPath;
                down.index = 2;
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
    
}

-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier index:(int)index
{
    if (index == 1) {
        NSIndexPath *indexPath = (NSIndexPath*)identifier;
        if (indexPath.row < [_items1 count]) {
            ResultsCell *cell = (ResultsCell*) [_tableview1 cellForRowAtIndexPath:indexPath];
            CarItem *item = [_items1 objectAtIndex:indexPath.row];
            
            if (data.length > 0) {
                cell.carImg.image = [UIImage imageWithData:data];
                item.thumbImage = [UIImage imageWithData:data];
            }
        }
    } else if (index == 2) {
        NSIndexPath *indexPath = (NSIndexPath*)identifier;
        if (indexPath.row < [_items2 count]) {
            ResultsCell *cell = (ResultsCell*) [_tableview2 cellForRowAtIndexPath:indexPath];
            CarItem *item = [_items2 objectAtIndex:indexPath.row];
            
            if (data.length > 0) {
                cell.carImg.image = [UIImage imageWithData:data];
                item.thumbImage = [UIImage imageWithData:data];
            }
        }
    }
}

-(void)downloaderFailedIndentifier:(id)indentifier
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self downLoadThumb];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self downLoadThumb];
}


#pragma mark - Delete

- (void) deleteList{    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDelete)];
    
    _isHideTable    = YES;
    _btn1.enabled   = NO;
    _btn2.enabled   = NO;
    _btn3.enabled   = NO;
    
    if (_indexSelectTable == 1) {
        _tableview1.allowsMultipleSelectionDuringEditing = YES;
        [_tableview1 setEditing:YES animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableview1 selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else if (_indexSelectTable == 2) {
        _tableview2.allowsMultipleSelectionDuringEditing = YES;
        [_tableview2 setEditing:YES animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableview2 selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else if (_indexSelectTable == 3) {
        _tableview3.allowsMultipleSelectionDuringEditing = YES;
        [_tableview3 setEditing:YES animated:YES];
    }
    
    NSLog(@"self.view.frame.size.height = %f",self.view.frame.size.height);
    
    CGRect rectTable1 = _tableview1.frame;
    rectTable1.size.height = self.view.frame.size.height - 59;
    
    CGRect rectTable2 = _tableview2.frame;
    rectTable2.size.height = self.view.frame.size.height - 59;
    
    CGRect rectTable3 = _tableview3.frame;
    rectTable3.size.height = self.view.frame.size.height - 59;
    
    CGRect rectViewConfirm = _viewConfirm.frame;
    rectViewConfirm.origin.y = self.view.frame.size.height - 59;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    _tableview1.frame = rectTable1;
    _tableview2.frame = rectTable2;
    _tableview3.frame = rectTable3;
    
    _viewConfirm.frame = rectViewConfirm;
    
    
    [UIView commitAnimations];
}

- (void)cancelDelete
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteList)];
    
    _isHideTable    = NO;
    _btn1.enabled   = YES;
    _btn2.enabled   = YES;
    _btn3.enabled   = YES;

    if (_indexSelectTable == 1) {
        _tableview1.allowsMultipleSelectionDuringEditing = NO;
        [_tableview1 setEditing:NO animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableview1 selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else if (_indexSelectTable == 2) {
        _tableview2.allowsMultipleSelectionDuringEditing = NO;
        [_tableview2 setEditing:NO animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:_tableview2 selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else if (_indexSelectTable == 3) {
        _tableview3.allowsMultipleSelectionDuringEditing = NO;
        [_tableview3 setEditing:NO animated:YES];
    }
    
    NSLog(@"self.view.frame.size.height = %f",self.view.frame.size.height);
    
    CGRect rectTable1 = _tableview1.frame;
    rectTable1.size.height = self.view.frame.size.height + 59;

    CGRect rectTable2 = _tableview2.frame;
    rectTable2.size.height = self.view.frame.size.height + 59;

    CGRect rectTable3 = _tableview3.frame;
    rectTable3.size.height = self.view.frame.size.height + 59;

    CGRect rectViewConfirm = _viewConfirm.frame;
    rectViewConfirm.origin.y = self.view.frame.size.height + 59;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    _tableview1.frame = rectTable1;
    _tableview2.frame = rectTable2;
    _tableview3.frame = rectTable3;
    
    _viewConfirm.frame = rectViewConfirm;
    
    
    [UIView commitAnimations];
}

- (IBAction)confirmDeleteItem:(id)sender {
    
    NSString *message = @"";
    
    if (_indexSelectTable == 1) {
        message = @"お気に入りを削除してもよろしいですか？";
    } else if (_indexSelectTable == 2) {
        message = @"履歴を削除してもよろしいですか？";
    } else if (_indexSelectTable == 3) {
        message = @"検索履歴を削除してもよろしいですか？";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"いいえ"
                                          otherButtonTitles:@"はい", nil];
    [alert show];
}

#pragma mark - UIAlerViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self moveToTrash];
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(cancelDelete) userInfo:nil repeats:NO];
    }
}

- (void)moveToTrash
{
    
    if (_indexSelectTable == 1) {
        NSArray *indexPaths = [_tableview1 indexPathsForSelectedRows];
        NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"row" ascending:NO]]];
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            [_items1 removeObjectAtIndex:indexPath.row];
        }
        [_tableview1 deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        if ([_items1 count] == 0) {
            [self setEditing:NO animated:YES];
        }
        
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            CDFavorites *item = [_favoritesResults.fetchedObjects objectAtIndex:indexPath.row];
            [[AppDelegate shared].managedObjectContext deleteObject:item];
        }
        
        [[AppDelegate shared] saveContext];
        
    } else if (_indexSelectTable == 2) {
        NSArray *indexPaths = [_tableview2 indexPathsForSelectedRows];
        NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"row" ascending:NO]]];
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            [_items2 removeObjectAtIndex:indexPath.row];
        }
        [_tableview2 deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        if ([_items2 count] == 0) {
            [self setEditing:NO animated:YES];
        }
        
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            CDRecents *item = [_recentsResults.fetchedObjects objectAtIndex:indexPath.row];
            [[AppDelegate shared].managedObjectContext deleteObject:item];
        }
        [[AppDelegate shared] saveContext];
    } else if (_indexSelectTable == 3) {
        NSArray *indexPaths = [_tableview3 indexPathsForSelectedRows];
        NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"row" ascending:NO]]];
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            [_items3 removeObjectAtIndex:indexPath.row];
        }
        
        [_tableview3 deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        if ([_items3 count] == 0) {
            [self setEditing:NO animated:YES];
        }
        
        AppDelegate *appDelegate = [AppDelegate shared];
        
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            CDHistory *item = [_historyResults.fetchedObjects objectAtIndex:indexPath.row];
            [appDelegate.managedObjectContext deleteObject:item];
        }
        
        [appDelegate saveContext];
    }
    
    
}




@end
