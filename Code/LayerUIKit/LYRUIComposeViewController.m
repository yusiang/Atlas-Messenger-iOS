//
//  LYRUIComposeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/5/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIComposeViewController.h"
#import "LYRUIConstants.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIUtilities.h"

@interface LYRUIComposeViewController () <UITextViewDelegate>

@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic) CGFloat textViewContentSizeHeight;
@property (nonatomic) CGSize defaultSize;

@end

@implementation LYRUIComposeViewController

// Compose View Margins
static CGFloat const LSComposeviewHorizontalMargin = 6;
static CGFloat const LSComposeviewVerticalMargin = 6;

static CGFloat const LSleftAccessoryButtonWidth = 40;
static CGFloat const LSrightAccessoryButtonWidth = 50;
static CGFloat const LSButtonHeight = 28;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the Camera Button
    self.leftAccessoryButton = [[UIButton alloc] init];
    self.leftAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
    [self.leftAccessoryButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    self.leftAccessoryButton.layer.cornerRadius = 2;
    [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftAccessoryButton];
    
    // Initialize the Text Input View
    self.textInputView = [[UITextView alloc] init];
    self.textInputView.delegate = self;
    self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textInputView.layer.borderWidth = 1;
    self.textInputView.layer.cornerRadius = 4.0f;
    self.textInputView.font = LSLightFont(16);
    self.textInputView.textContainerInset = UIEdgeInsetsMake(4, 0, 0, 0);
    self.textInputView.accessibilityLabel = @"Text Input View";
    [self.view addSubview:self.textInputView];
    
    // Initialize the Send Button
    self.rightAccessoryButton = [[UIButton alloc] init];
    self.rightAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightAccessoryButton.accessibilityLabel = @"Send Button";
    self.rightAccessoryButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightAccessoryButton setTitle:@"SEND" forState:UIControlStateNormal];
    [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rightAccessoryButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
    [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightAccessoryButton];
    
    [self setupLayoutConstraints];
    
    self.messageContentParts = [[NSMutableArray alloc] init];
    // Setup
    self.view.backgroundColor =  LSLighGrayColor();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.keyboardIsOnScreen = NO;
    
    if (!self.defaultSize.height) {
        self.defaultSize = self.view.frame.size;
    }
}

- (void)insertImage:(UIImage *)image
{
    [self.messageContentParts addObject:image];
    
    [self.rightAccessoryButton setHighlighted:TRUE];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInputView.attributedText];
    LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
    textAttachment.image = image;

    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
    self.textInputView.attributedText = attrStringWithImage;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect rect = LYRUIImageRectForThumb(imageView.frame.size, 100);
    [self adjustFrameForHeightDifference:rect.size.height];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    
}

- (void)insertAudioAtPath:(NSString *)path
{
    
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    
}


- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSleftAccessoryButtonWidth]];
    
    // Left Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LSComposeviewVerticalMargin]];
    // Height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewHorizontalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSrightAccessoryButtonWidth]];
    
    // Right Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
    // Height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewHorizontalMargin]];
    
    //**********Text Input View Constraints**********//
    // Left Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:LSComposeviewVerticalMargin]];
    
    // Right Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
    // Top Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:LSComposeviewHorizontalMargin]];
    // Bottom Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewHorizontalMargin]];
}

- (void)leftAccessoryButtonTapped
{
    [self.delegate composeViewController:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)rightAccessoryButtonTapped
{
    if (self.textInputView.text.length > 0 || self.textInputView.attributedText) {
        [self.delegate composeViewController:self didTapRightAccessoryButton:self.rightAccessoryButton];
        self.textInputView.text = @"";
        [self.rightAccessoryButton setHighlighted:FALSE];
        if (self.defaultSize.height != self.view.frame.size.height) {
            [self adjustFrameForHeightDifference:self.defaultSize.height - self.view.frame.size.height];
        }
    }
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textViewContentSizeHeight = textView.contentSize.height;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.rightAccessoryButton setHighlighted:FALSE];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textViewContentSizeHeight != textView.contentSize.height) {
        CGFloat heightDiff = textView.contentSize.height - self.textViewContentSizeHeight;
        [self adjustFrameForHeightDifference:heightDiff];
        self.textViewContentSizeHeight = textView.contentSize.height;
    }
    if (textView.text.length > 0) {
        [self.rightAccessoryButton setHighlighted:TRUE];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.attributedText) {
        //Press return key
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

- (void)adjustFrameForHeightDifference:(CGFloat)heightDifference
{
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - heightDifference , self.view.frame.size.width, self.view.frame.size.height + heightDifference)];
    }];

}

@end
