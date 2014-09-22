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
        
        self.text = @"Enter Message";
        self.contentInset = UIEdgeInsetsMake(-2, 0, 0, 0);
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(textDidChange)
//                                                     name:UITextViewTextDidChangeNotification
//                                                   object:self];
    }
    [self layoutIfNeeded];
    self.textColor = [UIColor lightGrayColor];
    self.font = LSLightFont(16);
    return self;
}

- (CGSize)intrinsicContentSize
{
    return self.contentSize;
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

@end
