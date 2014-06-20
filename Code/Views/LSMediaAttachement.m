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


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect systemImageRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    CGRect rectToFit;
    
    if (systemImageRect.size.width > systemImageRect.size.height) {
        double ratio = 80/systemImageRect.size.width;
        double height = systemImageRect.size.height * ratio;
        rectToFit = CGRectMake(0, 0, 80, height);
    } else {
        double ratio = 80/systemImageRect.size.height;
        double width = systemImageRect.size.width * ratio;
        rectToFit = CGRectMake(0, 0, width, 80);
    }
    
    return rectToFit;
}


@end
