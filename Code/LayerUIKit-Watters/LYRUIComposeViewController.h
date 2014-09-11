//
//  LYRUIComposeViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/5/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class LYRUIComposeViewController;

@protocol LYRUIComposeViewControllerDelegate <NSObject>

- (void)composeViewController:(LYRUIComposeViewController *)composeViewController didTapRightAccessoryButton:(UIButton *)rightAccessoryButton;

- (void)composeViewController:(LYRUIComposeViewController *)composeViewController didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton;

@end

@interface LYRUIComposeViewController : UIViewController

- (void)insertImage:(UIImage *)image;

- (void)insertVideoAtPath:(NSString *)videoPath;

- (void)insertAudioAtPath:(NSString *)path;

- (void)insertLocation:(CLLocationCoordinate2D)location;

@property (nonatomic, strong) UIButton *leftAccessoryButton;

@property (nonatomic, strong) UIButton *rightAccessoryButton;

@property (nonatomic, strong) UITextView *textInputView;

@property (nonatomic, weak) id<LYRUIComposeViewControllerDelegate>delegate;

@end
