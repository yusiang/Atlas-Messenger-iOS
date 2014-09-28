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
        self.textContainerInset = UIEdgeInsetsMake(6, 0, 6, 0);
        self.font = [UIFont systemFontOfSize:14];
        self.text = @"Enter Message";
        self.textColor = [UIColor lightGrayColor];
        [self layoutIfNeeded];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewBeganEditing)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:nil];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat width = self.contentSize.width;
    CGFloat height = self.contentSize.height;
    return CGSizeMake(width, height);
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
    
    if (self.text.length > 0) {
        [self insertLineBreak];
    }
    
    NSMutableAttributedString *attributedString = [self.attributedText mutableCopy];
    if (attributedString.length > 1) {
        [attributedString replaceCharactersInRange:NSMakeRange(attributedString.length, 0)
                              withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    } else {
        [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length)
                              withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    }

    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    [attributedString insertAttributedString:space atIndex:attributedString.length];
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

- (void)textViewBeganEditing
{
    if (self.font != [UIFont systemFontOfSize:14]) {
        self.font = [UIFont systemFontOfSize:14];
    }
    if ([self.text isEqualToString:@"Enter Message"]) {
        self.text = @"";
    }
    
    if ([self attributedTextContainsAttachment]) {
        [self insertLineBreak];
    }
}

- (void)insertLineBreak
{
    NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
    NSMutableAttributedString *lineBreak = [[NSMutableAttributedString alloc] initWithString:@" \n"];
    [mutableAttributedString insertAttributedString:lineBreak atIndex:self.attributedText.length];
    self.attributedText = mutableAttributedString;
}

- (BOOL)attributedTextContainsAttachment
{
    NSRange theStringRange = NSMakeRange(0, self.attributedText.length);
    for (int i = 0; i < self.attributedText.length; i++) {
        NSDictionary *theAttributes = [self.attributedText attributesAtIndex:i longestEffectiveRange:nil inRange:theStringRange];
        NSTextAttachment *theAttachment = [theAttributes objectForKey:NSAttachmentAttributeName];
        if (theAttachment != NULL) {
            return TRUE;
        }
    }
    return FALSE;
}

@end
