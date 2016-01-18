//
//  ResultsCell.h
//  Car Sales
//
//  Created by Le Phuong Tien on 5/27/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLb;
@property (nonatomic, weak) IBOutlet UILabel *bonusLb;
@property (nonatomic, weak) IBOutlet UILabel *priceLb;

@property (nonatomic, weak) IBOutlet UILabel *more1;
@property (nonatomic, weak) IBOutlet UILabel *more2;
@property (nonatomic, weak) IBOutlet UILabel *more3;

@property (nonatomic, weak) IBOutlet UILabel *multipeImg;
@property (nonatomic, weak) IBOutlet UIImageView *imgMultipeImg;
@property (nonatomic, weak) IBOutlet UILabel *lbDelete;

@property (nonatomic, weak) IBOutlet UIImageView *carImg;
@property (nonatomic, weak) IBOutlet UIImageView *carNew;



@end
