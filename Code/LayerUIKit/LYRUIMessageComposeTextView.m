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
        self.textContainerInset = UIEdgeInsetsMake(4, 0, 4, 0);
        self.font = LSLightFont(14);
        self.text = @"Enter Message";
        self.textColor = [UIColor lightGrayColor];
        [self layoutIfNeeded];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return self.contentSize;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // Don'd do anything here to prevent autoscrolling.
    // Unless you plan on using this method in another fashion.
}

- (void)insertImage:(UIImage *)image
{
    LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
    textAttachment.image = image;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : LSLightFont(16)}];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    [self layoutIfNeeded];
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    [self layoutIfNeeded];
}

- (void)removeAttachements
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : LSLightFont(16)}];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

@end
