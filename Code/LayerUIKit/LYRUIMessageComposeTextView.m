//
//  UIMessageComposeTextView.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageComposeTextView.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIConstants.h"

@interface LYRUIMessageComposeTextView () <UITextViewDelegate>

@property (nonatomic) CGFloat contentHeight;

@end

@implementation LYRUIMessageComposeTextView

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    if (!self.text.length > 0) {
        return CGSizeMake(0, 24);
    } else {
        return self.contentSize;
    }
    
}

- (void)insertImage:(UIImage *)image
{
    LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
    textAttachment.image = image;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : LSLightFont(16)}];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    self.attributedText = attributedString;
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    
}

- (void)textDidChange
{
    if (self.contentHeight != self.contentSize.height) {
        [self invalidateIntrinsicContentSize];
    }
    self.contentHeight = self.contentSize.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.delegate textViewDidChange:self];
}
@end
