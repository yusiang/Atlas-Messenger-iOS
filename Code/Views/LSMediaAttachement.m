//
//  LSMediaAttachement.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMediaAttachement.h"
#import "LSUtilities.h"

@interface LSMediaAttachement ()

@end

@implementation LSMediaAttachement


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect systemImageRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    return LSImageRectForThumb(systemImageRect.size, 120);
}


@end
