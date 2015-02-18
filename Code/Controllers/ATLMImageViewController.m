//
//  ATLMImageViewController.m
//  Atlas Messenger
//
//  Created by Ben Blakley on 1/16/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMImageViewController.h"

@interface ATLMImageViewController () <UIScrollViewDelegate>

@property (nonatomic) UIImage *image;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation ATLMImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    if (!self.image) return;

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.contentSize = self.image.size;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    [self.scrollView addSubview:self.imageView];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    recognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:recognizer];

    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self configureForAvailableSpace];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configureForAvailableSpace];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self configureForAvailableSpace];
}

#pragma mark - Gesture Recognizer Handler

- (void)doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.scrollView.minimumZoomScale == self.scrollView.maximumZoomScale) return;

    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint tappedPoint = [gestureRecognizer locationInView:self.imageView];
        CGRect tappedRect = CGRectMake(tappedPoint.x, tappedPoint.y, 0, 0);
        [self.scrollView zoomToRect:tappedRect animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - Actions

- (void)share:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.image] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)configureForAvailableSpace
{
    if (!self.view.superview) return;

    // We want to position and zoom the image based on the available size, i.e. so that it can be seen without being obstructed by the navigation bar or a toolbar.
    CGSize availableSize = self.scrollView.bounds.size;
    availableSize.height -= self.scrollView.contentInset.top;
    availableSize.height -= self.scrollView.contentInset.bottom;

    // We don't want to display the image larger than its native size.
    CGFloat maximumScale = 1.0;

    // The smallest we want to display the image is the size that it completely fits onscreen.
    CGFloat xFittedScale = availableSize.width / self.image.size.width;
    CGFloat yFittedScale = availableSize.height / self.image.size.height;
    CGFloat fittedScale = MIN(xFittedScale, yFittedScale);

    // If we're dealing with a small image then we only display it at its native size.
    CGFloat minimumScale = MIN(fittedScale, maximumScale);

    // If we're already at the minimum scale, we want to remain at that scale after our adjustments.
    BOOL atMinimumZoomScale = self.scrollView.zoomScale == self.scrollView.minimumZoomScale;
    self.scrollView.maximumZoomScale = maximumScale;
    self.scrollView.minimumZoomScale = minimumScale;
    if (atMinimumZoomScale) {
        self.scrollView.zoomScale = minimumScale;
    }

    CGRect imageViewFrame = self.imageView.frame;

    // If the entire image width is onscreen then we horizontally center the image in the available space.
    if (CGRectGetWidth(imageViewFrame) < availableSize.width) {
        imageViewFrame.origin.x = (availableSize.width - CGRectGetWidth(imageViewFrame)) / 2;
    } else {
        imageViewFrame.origin.x = 0;
    }

    // If the entire image height is onscreen then we vertically center the image in the available space.
    if (CGRectGetHeight(imageViewFrame) < availableSize.height) {
        imageViewFrame.origin.y = (availableSize.height - CGRectGetHeight(imageViewFrame)) / 2;
    } else {
        imageViewFrame.origin.y = 0;
    }

    self.imageView.frame = imageViewFrame;
}

@end
