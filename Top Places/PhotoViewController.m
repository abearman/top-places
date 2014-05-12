//
//  PhotoViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation PhotoViewController

#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scaleImageToScrollView];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self scaleImageToScrollView];
}

- (void)scaleImageToScrollView {
    [self.imageView removeFromSuperview];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.image.size};
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.image.size;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    self.scrollView.zoomScale = MAX(scaleWidth, scaleHeight);
}

#pragma mark Properties

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.image.size};
}

#pragma mark Public API

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    self.image = [UIImage imageWithData:imageData];
}

#pragma mark Outlets

- (void)setScrollView:(UIScrollView *)scrollView { // 2
    _scrollView = scrollView;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
