//
//  LYRUIImageViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 12/15/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIImageViewController.h"

@interface LYRUIImageViewController ()

@property (nonatomic) UIImage *image;
@property (nonatomic) UIImageView *imageView;

@end
@implementation LYRUIImageViewController

+ (instancetype)controllerWithImage:(UIImage *)image
{
    return  [[self alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleDoneTapped:)];
    self.navigationItem.leftBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

- (void)handleDoneTapped:(UIButton *)button
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
