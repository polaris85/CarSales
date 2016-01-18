//
//  FilterVCPA.h
//  Car Sales
//
//  Created by TienLP on 7/2/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterVCPADelegate <NSObject>

- (void)didChangeCommonQueryDic:(NSMutableDictionary*)commonQueryDic;

@end

@interface FilterVCPA : UIViewController

+ (FilterVCPA *)shared;

@property(nonatomic,weak) id<FilterVCPADelegate> delegate;
@property (nonatomic, weak) UIPopoverController *popover;
@property (nonatomic, strong) UIPopoverController *popoverPicker;
@property(nonatomic,strong) NSMutableDictionary *dicQuery;

- (void)loadDicQuery:(NSMutableDictionary*)dicQuery;

@end
