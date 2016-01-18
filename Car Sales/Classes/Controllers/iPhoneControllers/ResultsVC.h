//
//  ResultsVC.h
//  Car Sales
//
//  Created by Adam on 5/15/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ResultsVC : ViewController

@property (nonatomic, strong) NSMutableDictionary *commonQueryDic;

- (void)loadListForSearchByKeyword:(NSString*)keyWord;
- (void)loadListForDic:(NSMutableDictionary*)dicQuery;
- (void)loadListForCommonQueryDic:(NSMutableDictionary*)commonQueryDic;

@end
