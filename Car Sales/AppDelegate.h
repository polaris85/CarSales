//
//  AppDelegate.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/29/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarItem.h"
#import "GAI.h"
#import "CDHistory.h"
#import "FXTabBarController.h"
#import "FXNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, retain) id<GAITracker> tracker;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) BOOL isUseLocalFile;

@property (nonatomic, strong) NSFetchedResultsController *favoritesResults;
@property (nonatomic, strong) NSFetchedResultsController *recentsResults;
@property (nonatomic, strong) NSFetchedResultsController *prefResults;
@property (nonatomic, strong) NSFetchedResultsController *historyResults;
@property (nonatomic, strong) NSFetchedResultsController *shashuResults;

@property (nonatomic, strong) NSString *pathFileDB;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)isExitsCarFavoritesWithID:(NSString*)carID;
- (BOOL)deleteCarFavoritesWithID:(NSString*)carID;

- (void) addCarRecentsWithCarItem:(CarItem*)carItem;

- (void) setDelCarWithID:(NSString*)carID;

- (void) deleteAllPref;

- (void) addHistoryWithName:(NSString*)name strQuery:(NSString*)strQuery dicQuery:(NSDictionary*)dicQuery;
- (void) setIsDataHistory:(BOOL)isData;
- (CDHistory*) getLastestHistoryisData;

- (void) deleteAllShashu;

- (NSString*) getShashuCodeName:(NSString*) shashuName companyCode:(NSString*)companyCode;

//

@property (nonatomic, assign) BOOL menuBarHidden;
- (void)showHideMenuBar;
- (void)showHideMenuBarWithIsTouch:(BOOL)isTouch;
- (void)showHideMenuBarWithoutBottomBar;

- (void)selectHome;

- (void)showAds;
- (void)showLicense;

- (void)showMasterVC;

+ (AppDelegate *)shared;

//


@end
