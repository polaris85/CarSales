//
//  AutoResizeCellCollectionView.m
//  Car Sales
//
//  Created by Adam on 5/27/13.
//  Copyright (c) 2013 Green Global Co., Ltd. All rights reserved.
//

#import "AutoResizeCellCollectionView.h"

@implementation AutoResizeCellCollectionView

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame, self.frame)) {
        float space = frame.origin.x;
        float width = frame.size.width;
        PSUICollectionViewFlowLayout *layout = (PSUICollectionViewFlowLayout *)self.collectionViewLayout;
        float w = truncf((width - 2*space)/3);
        float h = roundf(w * layout.itemSize.height / layout.itemSize.width);
        layout.itemSize = CGSizeMake(w, h);
        [super setFrame:frame];
    }
}

@end
