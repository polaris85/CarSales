//
//  MBNScrollImageView2.h
//  SCrollImage
//
//  Created by Nick LE on 1/17/13.
//  Copyright (c) 2013 Nick LE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBNScrollImageView : UIScrollView <UIScrollViewDelegate>{
    BOOL _isZoomMin,_isDoubleTag;
}

@property(nonatomic,strong) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

- (void)zoomMin;

- (void)addImage:(UIImage*)image;

- (void)resetFrame:(CGRect)frame;

@end
