//
//  ZoomImageScrollVC.h
//  Car Sales
//
//  Created by TienLP on 6/20/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ZoomImageScrollVC : ViewController

@property(nonatomic,strong) NSMutableArray *images;
@property(nonatomic) int indexImage;

- (void) loadInfor:(NSMutableArray*)images index:(int)indexImage;

@end
