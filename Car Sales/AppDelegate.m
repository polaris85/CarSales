//
//  AppDelegate.m
//  Car Sales
//
//  Created by Le Phuong Tien on 5/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

//

#import "AppDelegate.h"
#import "Common.h"
#import "Define.h"
#import "Reachability.h"

#import "UIImage+UIColor.h"
#import <MoreApps/MoreAppsViewController.h>
#import "ExtMoreAppsViewController.h"
#import "ImplementControl.h"
#import "ImplementControlDB.h"

#import "GAI.h"

#import "SearchVC.h"
#import "FavoritesVC.h"
#import "RecentsVC.h"
#import "HistoryVC.h"
#import "LicenseVC.h"
#import "SplashVC.h"
#import "DetailsVC.h"

#import "MasterTabBarController.h"
#import "MasterNavigationController.h"
#import "DetailNavigationController.h"
#import "SearchVCPA.h"
#import "SplashVCPA.h"
#import "MoreAppsVC.h"
#import "LicenseVCPA.h"


#import "CDFavorites.h"
#import "CDRecents.h"
#import "CDPref.h"
#import "CDHistory.h"
#import "CDShashu.h"

#import "PrefWS.h"
#import "ShashuWS.h"

#import <MZFormSheetController/MZFormSheetController.h>

static __weak AppDelegate *shared = nil;
static NSString *const kTrackingId = @"UA-33794444-2";

@interface AppDelegate () <UITabBarDelegate,NSFetchedResultsControllerDelegate,PrefWSDelegate,ShashuWSDelegate>
{
    BOOL _bottomBarHidden;
    BOOL _animating;
    BOOL _isReLoadPref;
    BOOL _numFinishedDownload;
}

@property (nonatomic, strong) FXTabBarController *tabBarController;
@property (nonatomic, weak) UITabBar *menuBar;

@property (strong, nonatomic) UISplitViewController *rootSplitViewController;
@property (nonatomic, strong) MasterNavigationController *masterNavigationController;
@property (nonatomic, strong) DetailNavigationController *detailNavigationController;


@end

@implementation AppDelegate

@synthesize menuBar = _menuBar;

+ (AppDelegate *)shared
{
    return shared;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    shared = self;
    _menuBarHidden = YES;
    
    // Google Analytics
    [GAI sharedInstance].debug = NO;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    // check device
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
            [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
            NSLog(@"iPad");
            [Common user].isIPhone = NO;
            
            SearchVCPA *searchVCPA = [[SearchVCPA alloc] init];
            self.masterNavigationController = [[MasterNavigationController alloc] initWithRootViewController:searchVCPA];
//            if (![Common isIOS7]) {
//                [self.masterNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master2.png"] forBarMetrics:UIBarMetricsDefault];
//            }
//            else
//                [self.masterNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master.png"] forBarMetrics:UIBarMetricsDefault];
            
            self.detailNavigationController = [[DetailNavigationController alloc] init_];
            if ([Common isIOS7]) {
                [self.detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master2.png"] forBarMetrics:UIBarMetricsDefault];
            }
            else
                [self.detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master.png"] forBarMetrics:UIBarMetricsDefault];
            
            self.rootSplitViewController = [[UISplitViewController alloc] init];
            self.rootSplitViewController.viewControllers = @[self.masterNavigationController, self.detailNavigationController];
            self.rootSplitViewController.delegate = self.detailNavigationController;
            
            SplashVCPA *splashVCPA = [[SplashVCPA alloc] init];
            
            self.window.rootViewController = splashVCPA;
            
        }
        else
        {
            [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
            
            if ([Common isIOS7]) {
                [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navi_ipad.png"] forBarMetrics:UIBarMetricsDefault];
//                [[UINavigationBar appearance] setTintColor:[UIColor orangeColor]];
            }
            else
            {
                [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navi_02.png"] forBarMetrics:UIBarMetricsDefault];
//                [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:71.0/255.0 green:141.0/255.0 blue:243.0/255.0 alpha:1.0]];
                
            }

            
            NSLog(@"iPhone");
            [Common user].isIPhone = YES;
            
            UIViewController *vc1 = [[SearchVC alloc] init];
            UIViewController *vc2 = [[FavoritesVC alloc] init];
            UIViewController *vc3 = [[RecentsVC alloc] init];
            UIViewController *vc4 = [[HistoryVC alloc] init];
            
            FXNavigationController *navi1 = [[FXNavigationController alloc] initWithRootViewController:vc1];
            navi1.tabBarItem = [[UITabBarItem alloc] initWithTitle:SEARCH_TITLE image:[UIImage imageNamed:@"icon_tabbar_search.png"] tag:1];
            
            FXNavigationController *navi2 = [[FXNavigationController alloc] initWithRootViewController:vc2];
            navi2.tabBarItem = [[UITabBarItem alloc] initWithTitle:FAVORITES_TITLE image:[UIImage imageNamed:@"icon_tabbar_favourite.png"] tag:2];
            
            FXNavigationController *navi3 = [[FXNavigationController alloc] initWithRootViewController:vc3];
            navi3.tabBarItem = [[UITabBarItem alloc] initWithTitle:RECENTS_TITLE image:[UIImage imageNamed:@"icon_tabbar_time.png"] tag:3];
            
            
            FXNavigationController *navi4 = [[FXNavigationController alloc] initWithRootViewController:vc4];
            navi4.tabBarItem = [[UITabBarItem alloc] initWithTitle:HISTORY_TITLE image:[UIImage imageNamed:@"icon_tabbar_menu.png"] tag:4];
            
            self.tabBarController = [[FXTabBarController alloc] init];
            self.tabBarController.viewControllers = @[navi1, navi2, navi3, navi4];
            self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bg_tabbar.png"];
            self.window.rootViewController = self.tabBarController;
            
            SplashVC *splashVC= [[SplashVC alloc] initWithNibName:@"SplashVC" bundle:nil];
            
            self.window.rootViewController = splashVC;
        }
        
    }
    
    // init coredata
    [self favoritesResults];
    [self recentsResults];
    [self prefResults];
    [self historyResults];
    [self shashuResults];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [userDefault objectForKey:@"lastDate"];
    
    if (lastDate == nil) {
        NSLog(@"first run");
        _isUseLocalFile = YES;
        
        // add time
        lastDate = [NSDate date];
        [userDefault setObject:lastDate forKey:@"lastDate"];
        [userDefault synchronize];
        
        //        //get pretWS
        //        [self getPrefWS];
        
        //shashu
        [self getShashuWS];
        
    } else {
        NSLog(@"more run");
        _isUseLocalFile = NO;
        
        NSDate *curentDate = [NSDate date];
        NSTimeInterval distanceBetweenTwoTimes = [curentDate timeIntervalSinceDate:lastDate];
        NSLog(@"last date: %@",[ImplementControl stringFromDate:lastDate format:@"MM:dd:YYYY-hh:mm:ss"]);
        NSLog(@"curent date: %@",[ImplementControl stringFromDate:curentDate format:@"MM:dd:YYYY-hh:mm:ss"]);
        NSLog(@"second: %f",distanceBetweenTwoTimes);
        
        if (distanceBetweenTwoTimes > TIME_REDOWNLOAD && [self isNetworkAvailable]) {
            
            NSLog(@"reDownload file DB");
            // lock screen
            
            for (UINavigationController *navi in _tabBarController.viewControllers) {
                UIViewController *vc = [navi.viewControllers objectAtIndex:[navi.viewControllers count] - 1];
                
                if ([vc isKindOfClass:[DetailsVC class]]) {
                    NSLog(@"DetailsVC visible");
                    DetailsVC *detailVC = (DetailsVC*)vc;
                    [detailVC dismissMail];
                }
                
                [navi popToRootViewControllerAnimated:NO];
            }
            
            if ([Common user].isIPhone) {
                _tabBarController.selectedIndex = 0;
                
                SplashVC *splashVC= [[SplashVC alloc] initWithNibName:@"SplashVC" bundle:nil];
                self.window.rootViewController = splashVC;
            } else {
                SplashVCPA *splashVC = [[SplashVCPA alloc] init];
                self.window.rootViewController = splashVC;
            }
            
            
            // redownload
            NSArray *urlDBs = @[ALL_CAR_NUM_URL,BODY_MASTER_URL,COMPANY_MASTER_URL,CATALOG_MASTER_URL,COLOR_MASTER_URL,PREF_MASTER_URL];
            NSArray *dbNames = @[ALL_CAR_NUM_DB,BODY_MASTER_DB,COMPANY_MASTER_DB,CATALOG_MASTER_DB,COLOR_MASTER_DB,PREF_MASTER_DB];
            
            [self downloadFileWithURL:urlDBs DBName:dbNames];
            
            
        } else {
            
            if ([userDefault objectForKey:@"pathFileDB"]) {
                NSLog(@"user database");
                _isUseLocalFile = NO;
                _pathFileDB = [userDefault objectForKey:@"pathFileDB"];
                
                NSLog(@"pathFileDB: %@",_pathFileDB);
                NSString *tempPath = [NSString stringWithFormat:@"%@/body_master.db",_pathFileDB];
                NSLog(@"tempPath: %@",tempPath);
                
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempPath];
                
                if (fileExists) {
                    NSLog(@"OK files DB Exists At Path");
                    
                    if ([Common user].isIPhone) {
                        self.window.rootViewController = _tabBarController;
                    } else {
                        self.window.rootViewController = self.rootSplitViewController;
                    }
                    
                } else {
                    NSLog(@"files DB not found");
                    NSLog(@"redownload files DB");
                    
                    
                    // lock screen
                    
                    for (UINavigationController *navi in _tabBarController.viewControllers) {
                        UIViewController *vc = [navi.viewControllers objectAtIndex:[navi.viewControllers count] - 1];
                        
                        if ([vc isKindOfClass:[DetailsVC class]]) {
                            NSLog(@"DetailsVC visible");
                            DetailsVC *detailVC = (DetailsVC*)vc;
                            [detailVC dismissMail];
                        }
                        
                        [navi popToRootViewControllerAnimated:NO];
                    }
                    
                    if ([Common user].isIPhone) {
                        _tabBarController.selectedIndex = 0;
                        
                        SplashVC *splashVC= [[SplashVC alloc] initWithNibName:@"SplashVC" bundle:nil];
                        self.window.rootViewController = splashVC;
                    } else {
                        SplashVCPA *splashVC = [[SplashVCPA alloc] init];
                        self.window.rootViewController = splashVC;
                    }
                    
                    
                    // redownload
                    NSArray *urlDBs = @[ALL_CAR_NUM_URL,BODY_MASTER_URL,COMPANY_MASTER_URL,CATALOG_MASTER_URL,COLOR_MASTER_URL,PREF_MASTER_URL];
                    NSArray *dbNames = @[ALL_CAR_NUM_DB,BODY_MASTER_DB,COMPANY_MASTER_DB,CATALOG_MASTER_DB,COLOR_MASTER_DB,PREF_MASTER_DB];
                    
                    [self downloadFileWithURL:urlDBs DBName:dbNames];
                    
                }
                
                
                
            } else {
                NSLog(@"user file");
                _isUseLocalFile = YES;
                
                if ([Common user].isIPhone) {
                    self.window.rootViewController = _tabBarController;
                    
                } else {
                    self.window.rootViewController = self.rootSplitViewController;
                }
            }
        }
    }
}

-(BOOL)isNetworkAvailable
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    return !( [r currentReachabilityStatus] == NotReachable);
}

// download
- (void) downloadFileWithURL:(NSArray*)urlDBs DBName:(NSArray*)dbNames
{
    _numFinishedDownload = 0;
    
    for (int i = 0; i < [urlDBs count]; i++) {
        [ImplementControlDB callDownloadDBFileWithURL:urlDBs[i] andFileNameDatabase:dbNames[i] returnPathDirectoryExtract:^(NSString *pathDirectoryExtract) {
            _numFinishedDownload ++;
            
            if (!pathDirectoryExtract) {
                _pathFileDB = nil;
                
            } else {
                _pathFileDB = pathDirectoryExtract;
                
            }
            
            
            
            if (_numFinishedDownload == 6) {
                if (self.pathFileDB) {
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    _isUseLocalFile = NO;
                    // add time
                    NSDate *lastDate = [NSDate date];
                    [userDefault setObject:lastDate forKey:@"lastDate"];
                    [userDefault setObject:self.pathFileDB forKey:@"pathFileDB"];
                    [userDefault synchronize];
                    
                    //                    // pref ws
                    //                    [self getPrefWS];
                    
                    //shashu
                    //                    [self getShashuWS];
                    if ([Common user].isIPhone) {
                        self.window.rootViewController = _tabBarController;
                    } else {
                        self.window.rootViewController = self.rootSplitViewController;
                    }
                    
                } else {
                    self.isUseLocalFile = YES;
                    if ([Common user].isIPhone) {
                        self.window.rootViewController = _tabBarController;
                    } else {
                        self.window.rootViewController = self.rootSplitViewController;
                    }
                }
            }
            
        }];
        
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

#pragma mark - CoreData

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Car_Sales" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Car_Sales.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Fetch CoreData

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
}

#pragma mark - favoritesResults

- (NSFetchedResultsController*)favoritesResults
{
    if (_favoritesResults == nil) {
        NSString *entityName = @"CDFavorites";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carId != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _favoritesResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:self.managedObjectContext
                                                                  sectionNameKeyPath:nil
                                                                           cacheName:cacheName];
        _favoritesResults.delegate = self;
        
        NSError *error = nil;
        [_favoritesResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        NSLog(@"Favorites total : %d",[_favoritesResults.fetchedObjects count]);
    }
    
    return _favoritesResults;
}

- (BOOL)isExitsCarFavoritesWithID:(NSString*)carID
{
    for (CDFavorites *item in _favoritesResults.fetchedObjects) {
        if ([item.carId isEqualToString:carID]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)deleteCarFavoritesWithID:(NSString*)carID
{
    for (CDFavorites *item in _favoritesResults.fetchedObjects) {
        if ([item.carId isEqualToString:carID]) {
            [_managedObjectContext deleteObject:item];
            [self saveContext];
            return YES;
        }
    }
    
    return NO;
}

- (void) setDelCarWithID:(NSString*)carID
{
    // favorites
    for (CDFavorites *item in _favoritesResults.fetchedObjects) {
        if ([item.carId isEqualToString:carID]) {
            item.isDel = YES;
            break;
        }
    }
    
    for (CDRecents *item in _recentsResults.fetchedObjects) {
        if ([item.carId isEqualToString:carID]) {
            item.isDel = YES;
            break;
        }
    }
    
    [self saveContext];
}

#pragma mark - recentsResults

- (NSFetchedResultsController*) recentsResults
{
    if (_recentsResults == nil) {
        NSString *entityName = @"CDRecents";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carId != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _recentsResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                              managedObjectContext:self.managedObjectContext
                                                                sectionNameKeyPath:nil
                                                                         cacheName:cacheName];
        _recentsResults.delegate = self;
        
        NSError *error = nil;
        [_recentsResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        NSLog(@"recents total : %d",[_recentsResults.fetchedObjects count]);
    }
    
    return _recentsResults;
}

- (void) addCarRecentsWithCarItem:(CarItem*)carItem
{
    for (CDRecents *item in _recentsResults.fetchedObjects) {
        if ([item.carId isEqualToString:carItem.carId]) {
            item.created = [[NSDate date] timeIntervalSince1970];
            [self saveContext];
            return;
        }
    }
    
    // add new item
    CDRecents *cdRecents = (CDRecents *)[NSEntityDescription insertNewObjectForEntityForName:@"CDRecents"
                                                                      inManagedObjectContext:self.managedObjectContext];
    cdRecents.carId         = carItem.carId;
    cdRecents.carName       = carItem.carName;
    cdRecents.carGrade      = carItem.carGrade;
    cdRecents.carPrice      = carItem.carPrice;
    cdRecents.carYear       = carItem.carYear;
    cdRecents.carOdd        = carItem.carOdd;
    cdRecents.carPref       = carItem.carPref;
    cdRecents.thumd         = carItem.thumd;
    cdRecents.isNew         = carItem.isNew;
    cdRecents.isSmallImage  = carItem.isSmallImage;
    
    cdRecents.created = [[NSDate date] timeIntervalSince1970];
    
    [self saveContext];
    
}

#pragma mark - prefResults

- (NSFetchedResultsController*) prefResults
{
    if (_prefResults == nil) {
        NSString *entityName = @"CDPref";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"sessionName" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"prefCode > 0"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _prefResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                           managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                                      cacheName:cacheName];
        _prefResults.delegate = self;
        
        NSError *error = nil;
        [_prefResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        NSLog(@"Pref total : %d",[_prefResults.fetchedObjects count]);
        
        
    }
    
    return _prefResults;
}

- (void) deleteAllPref
{
    for (CDPref *item in _prefResults.fetchedObjects) {
        [_managedObjectContext deleteObject:item];
        //        [self saveContext];
    }
}

#pragma mark - historyResults

- (NSFetchedResultsController*) historyResults
{
    if (_historyResults == nil) {
        
        NSString *entityName = @"CDHistory";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _historyResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                              managedObjectContext:self.managedObjectContext
                                                                sectionNameKeyPath:nil
                                                                         cacheName:cacheName];
        _historyResults.delegate = self;
        
        NSError *error = nil;
        [_historyResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        NSLog(@"history total : %d",[_historyResults.fetchedObjects count]);
        
        //        for (CDHistory *item in _historyResults.fetchedObjects) {
        //            NSLog(@"name: %@",item.name);
        //            NSLog(@"str query: %@",item.strQuery);
        //            NSLog(@"dic query: %@",[Common dictionaryFormData:item.dicQuery]);
        //        }
    }
    
    return _historyResults;
}

- (void) addHistoryWithName:(NSString*)name strQuery:(NSString*)strQuery dicQuery:(NSDictionary*)dicQuery
{
    BOOL ok = YES;
    for (CDHistory *item in _historyResults.fetchedObjects) {
        if ([item.name isEqualToString:name]) {
            NSLog(@"Update time of item");
            item.created = [NSDate date];
            ok = NO;
            break;
        }
    }
    
    if (ok) {
        NSLog(@"Add new item : %@",name);
        CDHistory *history = (CDHistory *)[NSEntityDescription insertNewObjectForEntityForName:@"CDHistory"
                                                                        inManagedObjectContext:self.managedObjectContext];
        history.name = name;
        history.strQuery = strQuery;
        history.created = [NSDate date];
        history.dicQuery = [Common dataFormDictionary:dicQuery];
    }
    
    [self saveContext];
}

- (void) setIsDataHistory:(BOOL)isData{
    CDHistory *item = [_historyResults.fetchedObjects objectAtIndex:0];
    item.isData = [NSNumber numberWithBool:isData];
    [self saveContext];
}

- (CDHistory*) getLastestHistoryisData
{
    for (CDHistory *item in _historyResults.fetchedObjects) {
        if ([item.isData boolValue]) {
            NSLog(@"name : %@",item.name);
            return item;
            break;
        }
    }
    
    return nil;
}

#pragma mark - shashuResults

- (NSFetchedResultsController*) shashuResults
{
    if (!_shashuResults) {
        NSString *entityName = @"CDShashu";
        
        NSString *cacheName = [NSString stringWithFormat:@"%@",entityName];
        [NSFetchedResultsController deleteCacheWithName:cacheName];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
        
        NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"makerCode" ascending:NO];
        NSArray *sortList = [NSArray arrayWithObjects:sort0, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shashuCode != nil"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.sortDescriptors = sortList;
        fetchRequest.predicate = predicate;
        _shashuResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.managedObjectContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:cacheName];
        _shashuResults.delegate = self;
        
        NSError *error = nil;
        [_shashuResults performFetch:&error];
        if (error) {
            NSLog(@"%@ core data error: %@", [self class], error.localizedDescription);
        }
        
        NSLog(@"Shashu total : %d",[_shashuResults.fetchedObjects count]);
    }
    
    return _shashuResults;
}

- (void) deleteAllShashu
{
    for (CDShashu *item in _shashuResults.fetchedObjects) {
        [_managedObjectContext deleteObject:item];
        //        [self saveContext];
    }
}

- (NSString*) getShashuCodeName:(NSString*) shashuName companyCode:(NSString*)companyCode
{
    for (CDShashu *item in _shashuResults.fetchedObjects) {
        if ([item.shashuName isEqualToString:shashuName] && [item.makerCode isEqualToString:companyCode]) {
            //            NSLog(@"maker: %@ - %@ ---- shashu: %@ - %@",item.makerCode,item.makerName, item.shashuCode, item.shashuName);
            return item.shashuCode;
        }
    }
    
    return nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Others

- (void)showHideMenuBar
{
    _bottomBarHidden = NO;
    BOOL hidden = self.menuBarHidden;
    self.menuBarHidden = !hidden;
}

- (void)showHideMenuBarWithIsTouch:(BOOL)isTouch
{
    if (isTouch && !self.menuBarHidden) {
        _bottomBarHidden = NO;
        BOOL hidden = self.menuBarHidden;
        self.menuBarHidden = !hidden;
    }
}

- (void)showHideMenuBarWithoutBottomBar
{
    _bottomBarHidden = YES;
    BOOL hidden = self.menuBarHidden;
    self.menuBarHidden = !hidden;
}

- (void)setMenuBarHidden:(BOOL)menuBarHidden
{
    if (_animating || _menuBarHidden == menuBarHidden) {
        return;
    }
    
    _animating = YES;
    _menuBarHidden = menuBarHidden;
    if (_menuBarHidden) {
        CGRect frame = self.menuBar.frame;
        frame.origin.y = self.tabBarController.view.bounds.size.height;
        if (_bottomBarHidden) {
            frame.origin.y -= frame.size.height;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = frame;
            self.tabBarController.tabBar.alpha = 1;
        } completion:^(BOOL finished) {
            self.menuBar = nil;
            _animating = NO;
        }];
    } else {
        CGRect frame = self.menuBar.frame;
        frame.origin.y = self.tabBarController.view.bounds.size.height - frame.size.height;
        if (_bottomBarHidden) {
            frame.origin.y -= frame.size.height;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = frame;
            self.tabBarController.tabBar.alpha = 0;
        } completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
}

- (void)selectHome
{
    //    UINavigationController *navi = _tabBarController.viewControllers[0];
    //    [navi popToRootViewControllerAnimated:NO];
    _tabBarController.selectedIndex = 0;
}

- (void)showMasterVC
{
    if ([Common isPortrait]) {
        
    }
}

#pragma mark - Setter, Getter

- (UITabBar *)menuBar
{
    if (_menuBar) {
        return _menuBar;
    }
    
    CGRect frame = self.tabBarController.tabBar.bounds;
    frame.origin.y = self.tabBarController.view.bounds.size.height;
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:frame];
    tabBar.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:0.2 alpha:1]];
    tabBar.items = @[[[UITabBarItem alloc] initWithTitle:TOP image:[UIImage imageNamed:@"icon_tabbar_top.png"] tag:1],
                     [[UITabBarItem alloc] initWithTitle:LICENSE_TITLE image:[UIImage imageNamed:@"icon_tabbar_infor.png"] tag:2],
                     [[UITabBarItem alloc] initWithTitle:ADS_TITLE image:[UIImage imageNamed:@"icon_tabbar_dropdown.png"] tag:3]];
    tabBar.delegate = self;
    [self.tabBarController.view addSubview:tabBar];
    _menuBar = tabBar;
    return _menuBar;
}

- (void)setMenuBar:(UITabBar *)menuBar
{
    if (menuBar == nil) {
        [_menuBar removeFromSuperview];
        _menuBar = nil;
    }
    _menuBar = menuBar;
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.menuBarHidden = YES;
    
    switch (item.tag) {
        case 1: {
            //            UINavigationController *selectedNavigation = (UINavigationController *)self.tabBarController.selectedViewController;
            //            [selectedNavigation popToRootViewControllerAnimated:YES];
            
            _tabBarController.selectedIndex = 0;
            
            UINavigationController *navi = [_tabBarController.viewControllers objectAtIndex:0];
            [navi popToRootViewControllerAnimated:YES];
            
            break;
        }
            
        case 2: {
            [self showLicense];
            break;
        }
            
        case 3: {
            [self showAds];
            break;
        }
    }
}

- (void)showLicense
{
    if ([Common user].isIPhone) {
        UINavigationController *selectedNavigation = (UINavigationController *)self.tabBarController.selectedViewController;
        UIViewController *visibleViewController = selectedNavigation.visibleViewController;
        LicenseVC *vc = [[LicenseVC alloc] init];
        BOOL hidesBottomBarWhenPushed = visibleViewController.hidesBottomBarWhenPushed;
        visibleViewController.hidesBottomBarWhenPushed = YES;
        [selectedNavigation pushViewController:vc animated:YES];
        visibleViewController.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
    } else {
        LicenseVCPA *vc = [[LicenseVCPA alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [navi.navigationBar setBackgroundImage:[UIImage imageNamed:@"ipad_navibar_master.png"] forBarMetrics:UIBarMetricsDefault];
        navi.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.window.rootViewController presentModalViewController:navi animated:YES];
    }
}

- (void)showAds
{
    if ([Common user].isIPhone) {
        UINavigationController *selectedNavigation = (UINavigationController *)self.tabBarController.selectedViewController;
        ExtMoreAppsViewController *vc = [[ExtMoreAppsViewController alloc] initWithZoneId:@"60474828"];
        vc.showDefaultNavigationBar = NO;
        
//        selectedNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
//        [selectedNavigation presentModalViewController:vc  animated:YES];
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        formSheet.cornerRadius = 8.0;
        formSheet.portraitTopInset = 6.0;
        formSheet.landscapeTopInset = 6.0;
        formSheet.presentedFormSheetSize = CGSizeMake(selectedNavigation.view.frame.size.width, selectedNavigation.view.frame.size.height - 48);
        
        
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        [selectedNavigation mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
        

        
    } else {
        [_detailNavigationController dismissPopover];
        //        MoreAppsVC *vc = [[MoreAppsVC alloc] initWithZoneId:@"60474828"];
        MoreAppsViewController *vc = [[MoreAppsViewController alloc] initWithZoneId:@"60474828"];
        vc.showDefaultNavigationBar = NO;
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.window.rootViewController presentModalViewController:vc animated:YES];
    }
}

#pragma mark - PrefWSDelegate

- (void)getPrefWS
{
    if ([_prefResults.fetchedObjects count] == 0) {
        PrefWS *prefWS = [[PrefWS alloc] init];
        prefWS.delegate = self;
        [prefWS getPrefFile];
    } else {
        
        PrefWS *prefWS = [[PrefWS alloc] init];
        prefWS.delegate = self;
        [prefWS getPrefWS];
    }
}

- (void)didFailWithErrorPref:(Error *)error
{
    NSLog(@"PrefWSDelegate didFailWithError");
    if (!_isReLoadPref) {
        //shashu
        [self getShashuWS];
    } else {
        [Common user].isPrefCoreData = NO;
    }
}
- (void)didSuccess
{
    
}

- (void)didSuccessWith:(NSMutableArray*)listItem
{
    if ([listItem count] > 0) {
        // delete coredata pref
        [self deleteAllPref];
        
        for (NSMutableDictionary *item in listItem) {
            CDPref *cdPref = (CDPref *)[NSEntityDescription insertNewObjectForEntityForName:@"CDPref"
                                                                     inManagedObjectContext:[AppDelegate shared].managedObjectContext];
            cdPref.prefCode     = [[item objectForKey:@"prefCode"] integerValue];
            cdPref.prefName     = [item objectForKey:@"prefName"];
            cdPref.sessionCode  = [[item objectForKey:@"sessionCode"] integerValue];
            cdPref.sessionName  = [item objectForKey:@"sessionName"];
        }
        
        [self saveContext];
        [Common user].isPrefCoreData = YES;
    }
    
    //shashu
    [self getShashuWS];
}

#pragma mark - ShashuWSDelegate

- (void)getShashuWS
{
    
    if ([_shashuResults.fetchedObjects count] == 0) {
        ShashuWS *shashuWS = [[ShashuWS alloc] init];
        shashuWS.delegate = self;
        [shashuWS getShashuFile];
    } else {
        ShashuWS *shashuWS = [[ShashuWS alloc] init];
        shashuWS.delegate = self;
        [shashuWS getShashuWS];
    }
}

- (void)didFailWithErrorShashu:(Error *)error
{
    NSLog(@"didFailWithErrorShashu");
    if ([Common user].isIPhone) {
        self.window.rootViewController = _tabBarController;
    } else {
        self.window.rootViewController = self.rootSplitViewController;
    }
}

- (void)didSuccessShashu
{
}

- (void)didSuccessShashuWith:(NSMutableArray *)listItem
{
    NSLog(@"didSuccessShashu");
    
    if ([listItem count] > 0) {
        [self deleteAllShashu];
        
        for (NSMutableDictionary *item in listItem) {
            
            CDShashu *cdShashu = (CDShashu *)[NSEntityDescription insertNewObjectForEntityForName:@"CDShashu"
                                                                           inManagedObjectContext:[AppDelegate shared].managedObjectContext];
            cdShashu.makerCode  = [item objectForKey:@"makerCode"];
            cdShashu.makerName  = [item objectForKey:@"makerName"];
            cdShashu.shashuCode = [item objectForKey:@"shashuCode"];
            cdShashu.shashuName = [item objectForKey:@"shashuName"];
        }
        
        
        [self saveContext];
    }
    
    if ([Common user].isIPhone) {
        self.window.rootViewController = _tabBarController;
    } else {
        self.window.rootViewController = self.rootSplitViewController;
    }
}

@end
