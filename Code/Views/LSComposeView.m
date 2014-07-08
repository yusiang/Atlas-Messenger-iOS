//
//  LSComposeView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSComposeView.h"
#import "LSMediaAttachement.h"
#import "LSUIConstants.h"

@interface LSComposeView ()

@property (nonatomic, strong) LSButton *cameraButton;
@property (nonatomic, strong) UITextView *textInputView;
@property (nonatomic, strong) LSButton *sendButton;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) CGRect defaultRect;

@end

@implementation LSComposeView

static CGFloat const LSComposeiewHorizontalMargin = 6;
static CGFloat const LSComposeiewVerticalMargin = 6;

static CGFloat const LSCameraButtonWidth = 40;
static CGFloat const LSSendButtonWidth = 50;
static CGFloat const LSButtonHeight = 28;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //Initialize the Camera Button
        self.cameraButton = [[LSButton alloc] init];
        self.cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.cameraButton.BackgroundColor = LSBlueColor();
        self.cameraButton.accessibilityLabel = @"Cam Button";
        self.cameraButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        self.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.cameraButton.layer.cornerRadius = 2;
        [self.cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.cameraButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cameraButton];
        
        //Initialize the Text Input View
        self.textInputView = [[UITextView alloc] init];
        self.textInputView.contentInset = UIEdgeInsetsMake(-2, 0, 0, 0);
        self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textInputView.layer.borderWidth = 1;
        self.textInputView.font = LSMediumFont(16);
        self.textInputView.layer.cornerRadius = 4.0f;
        self.textInputView.delegate = self;
        self.textInputView.accessibilityLabel = @"Compose TextView";
        [self addSubview:self.textInputView];
        
        //Initialize the Send Button
        self.sendButton = [[LSButton alloc] initWithText:@"Send"];
        self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.sendButton.backgroundColor = [UIColor clearColor];
        self.sendButton.textLabel.font = LSMediumFont(18);
        self.sendButton.textLabel.textColor = [UIColor grayColor];
        [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        [self setupLayoutConstraints];
        
        //Setup
        self.backgroundColor = LSLighGrayColor();
        self.accessibilityLabel = @"composeView";
        self.images = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSCameraButtonWidth]];
    
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LSComposeiewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeiewHorizontalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSSendButtonWidth]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-LSComposeiewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeiewHorizontalMargin]];
    
    //**********Text Input View Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.cameraButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:LSComposeiewVerticalMargin]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.sendButton
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-LSComposeiewVerticalMargin]];
    // Top Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:LSComposeiewHorizontalMargin]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeiewHorizontalMargin]];
}

- (void)cameraTapped
{
    [self.delegate cameraTapped];
}

- (void)sendMessage
{
    [self.textInputView resignFirstResponder];
    
    //Send Image
    if (self.images.count > 0) {
        for (UIImage *image in self.images) {
            [self.delegate composeView:self sendMessageWithImage:image];
        }
    }
    
    //If not text, don't send
    if ([self.textInputView.text isEqualToString:@" "]) {
        return;
    } else {
        [self.delegate composeView:self sendMessageWithText:self.textInputView.text];
    }
    
    //Reset text input view label
    [self.textInputView setText:@""];
}

- (void)updateWithImage:(UIImage *)image
{
    [self.images addObject:image];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInputView.attributedText];
    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
    textAttachment.image = image;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
    self.textInputView.attributedText = attrStringWithImage;
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.sendButton.textLabel.textColor = [UIColor grayColor];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat height = self.textInputView.contentSize.height;
    double lines = height / textView.font.lineHeight;
    [self.delegate composeView:self shouldChangeHeightForLines:(double)lines];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    } else {
       self.sendButton.textLabel.textColor = LSBlueColor();
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}


@end
