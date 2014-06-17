//
//  LSMediaAttachement.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LSMediaAttachement : NSTextAttachment

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CLLocationCoordinate2D *coordinate;

@end
