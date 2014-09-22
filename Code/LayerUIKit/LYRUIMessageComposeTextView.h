//
//  LYRUIMessageComposeTextView.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// Auto-resizing. Support insertion of audio and videos?

@interface LYRUIMessageComposeTextView : UITextView

@property (nonatomic, strong) NSString *placeHolderText;

- (void)insertImage:(UIImage *)image;

- (void)insertVideoAtPath:(NSString *)videoPath;

- (void)insertLocation:(CLLocationCoordinate2D)location;

@end
