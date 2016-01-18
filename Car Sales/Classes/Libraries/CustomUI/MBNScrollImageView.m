//
//  MBNScrollImageView2.m
//  SCrollImage
//
//  Created by Nick LE on 1/17/13.
//  Copyright (c) 2013 Nick LE. All rights reserved.
//

#import "MBNScrollImageView.h"

@implementation MBNScrollImageView

#pragma mark - frame method

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - tap

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    
    if (_isZoomMin) {
        _isZoomMin = NO;
        // zoom minimun 
        float minF = MIN(self.frame.size.width,self.frame.size.height);
        float maxI = MAX(_imageView.image.size.width, _imageView.image.size.height);
        
        CGFloat newZoomScale = minF/maxI;
        [self setZoomScale:newZoomScale animated:YES];
    }else{
        _isZoomMin = YES;
        // zoom maximun
        // Get the location within the image view where we tapped
        CGPoint pointInView = [recognizer locationInView:self.imageView];

        // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
        CGFloat newZoomScale = MAX(self.frame.size.height/_imageView.image.size.height, self.frame.size.width/_imageView.image.size.width);
        
        CGSize scrollViewSize = self.bounds.size;
        
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = pointInView.x - (w / 2.0f);
        CGFloat y = pointInView.y - (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        
        [self zoomToRect:rectToZoomTo animated:YES];
    }
    
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    [self setZoomScale:newZoomScale animated:YES];
}

#pragma mark - init method

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        //set
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        
        // Set up the image we want to scroll & zoom and add it to the scroll view
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.imageView];
        
        // Tell the scroll view the size of the contents
        self.contentSize = image.size;
        
        // set up Recognizer with 2 finger
//        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        doubleTapRecognizer.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:doubleTapRecognizer];
        
        // set up Recognizer with tag
        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:twoFingerTapRecognizer];
        
        // set up minimun & maximun scale
        [self centerScrollViewContents];
        
        CGRect scrollViewFrame = self.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = 1.0f;
        self.zoomScale = minScale;
        
        //set double tag
        if (image.size.width <= self.frame.size.width || image.size.height <= self.frame.size.height) {
            _isDoubleTag = NO;
        }else{
            _isDoubleTag = YES;
        }
        
    }
    return self;
}

- (void)addImage:(UIImage*)image
{
    [_imageView removeFromSuperview];
    self.imageView = nil;
    // Set up the image we want to scroll & zoom and add it to the scroll view
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.contentSize = image.size;
    
    // set up minimun & maximun scale
    [self centerScrollViewContents];
    
    CGRect scrollViewFrame = self.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = 1.0f;
    self.zoomScale = minScale;
    
    //set double tag
    if (image.size.width <= self.frame.size.width || image.size.height <= self.frame.size.height) {
        _isDoubleTag = NO;
    }else{
        _isDoubleTag = YES;
    }
}

- (void)resetFrame:(CGRect)frame
{
    self.frame = frame;
    [self zoomMin];
}

#pragma marl - Other

- (void) zoomMin
{
    _isZoomMin = NO;
    // zoom minimun
    float minF = MIN(self.frame.size.width,self.frame.size.height);
    float maxI = MAX(_imageView.image.size.width, _imageView.image.size.height);
    
    CGFloat newZoomScale = minF/maxI;
    [self setZoomScale:newZoomScale animated:YES];
}

- (void)dealloc
{
    self.imageView.image = nil;
    self.imageView = nil;
    [self removeFromSuperview];
}

@end
