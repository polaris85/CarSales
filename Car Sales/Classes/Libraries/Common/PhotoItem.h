//
//  PhotoItem.h
//  Car Sales
//
//  Created by Le Phuong Tien on 6/1/13.
//  Copyright (c) 2013 Le Phuong Tien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoItem : NSObject

@property(nonatomic,strong) NSString *photoID;
@property(nonatomic,strong) NSString *strUrl;
@property(nonatomic,strong) NSString *strCaption;
@property(nonatomic,strong) UIImage  *image;


@end
