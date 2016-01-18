//
//  CarCell.h
//  Car Sales
//
//  Created by Adam on 5/20/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NotHighlightedLabel.h"
#import "OuterShadowView.h"

@interface CarCell : UITableViewCell

@property (nonatomic, weak) IBOutlet OuterShadowView *iconView;
@property (nonatomic, weak) IBOutlet NotHighlightedLabel *iconLb;
@property (nonatomic, weak) IBOutlet UILabel *titleLb;
@property (nonatomic, weak) IBOutlet UILabel *bonusLb;
@property (nonatomic, weak) IBOutlet UILabel *priceLb;
@property (nonatomic, weak) IBOutlet NotHighlightedLabel *moreLb;
@property (nonatomic, weak) IBOutlet NotHighlightedLabel *hotLb;

@end
