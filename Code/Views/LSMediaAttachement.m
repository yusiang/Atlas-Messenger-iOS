//
//  LSMediaAttachement.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMediaAttachement.h"

@interface LSMediaAttachement ()

@end

@implementation LSMediaAttachement

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    CGRect rect = CGRectMake(0, 0, 40, 40);
    UIImage *image = [super imageForBounds:rect textContainer:textContainer characterIndex:charIndex];
    return image;
}


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    double ratio = lineFrag.size.width/80;
    double height = lineFrag.size.height * ratio;
    return CGRectMake(0, 0, 80, height);
}


@end
