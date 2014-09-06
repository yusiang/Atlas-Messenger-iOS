//
//  LYRUIComposeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/5/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIComposeViewController.h"

@interface LYRUIComposeViewController () <UITextViewDelegate>

@end

@implementation LYRUIComposeViewController

// Compose View Margins
static CGFloat const LSComposeviewHorizontalMargin = 6;
static CGFloat const LSComposeviewVerticalMargin = 6;

static CGFloat const LSleftControlItemWidth = 40;
static CGFloat const LSrightControlItemWidth = 50;
static CGFloat const LSButtonHeight = 28;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the Camera Button
    self.leftControlItem = [[UIButton alloc] init];
    self.leftControlItem.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftControlItem.BackgroundColor = [UIColor greenColor];
    self.leftControlItem.accessibilityLabel = @"Cam Button";
    self.leftControlItem.imageView.image = [UIImage imageNamed:@"camera"];
    self.leftControlItem.layer.cornerRadius = 2;
    [self.leftControlItem addTarget:self action:@selector(leftControlItemTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftControlItem];
    
    // Initialize the Text Input View
    self.textInputView = [[UITextView alloc] init];
    self.textInputView.delegate = self;
    self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textInputView.layer.borderWidth = 1;
    self.textInputView.layer.cornerRadius = 4.0f;
    self.textInputView.accessibilityLabel = @"Compose TextView";
    [self.view addSubview:self.textInputView];
    
    // Initialize the Send Button
    self.rightControlItem = [[UIButton alloc] init];
    self.rightControlItem.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rightControlItem setTitle:@"SEND" forState:UIControlStateNormal];
    [self.rightControlItem setTitleColor:UIControlStateNormal forState:UIControlStateNormal];

    [self.rightControlItem addTarget:self action:@selector(rightControlItemTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightControlItem];
    
    [self setupLayoutConstraints];
    
    // Setup
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftControlItem
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSleftControlItemWidth]];
    
    // Left Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftControlItem
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LSComposeviewVerticalMargin]];
    // Height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftControlItem
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftControlItem
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewHorizontalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightControlItem
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSrightControlItemWidth]];
    
    // Right Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightControlItem
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
    // Height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightControlItem
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rightControlItem
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
                                                        toItem:self.leftControlItem
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:LSComposeviewVerticalMargin]];
    
    // Right Margin
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.rightControlItem
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

- (void)leftControlItemTapped
{
    self.rightControlItem.titleLabel.text = @"SEND";
    self.rightControlItem.titleLabel.font = [UIFont systemFontOfSize:4];
    self.rightControlItem.titleLabel.textColor = [UIColor whiteColor];
}

- (void)rightControlItemTapped
{
//    [self.delegate composeViewShouldRestFrame:self];
//    self.rightControlItem.textLabel.textColor = [UIColor grayColor];
//    
//    // Send Image
//    if (self.images.count > 0) {
//        for (UIImage *image in self.images) {
//            [self.delegate composeView:self sendMessageWithImage:image];
//        }
//        self.textInputView.font = LSMediumFont(16);
//    } else {
//        if (self.textInputView.text.length) [self.delegate composeView:self sendMessageWithText:self.textInputView.text];
//    }
//    
//    self.textInputView.text = @"";
//    [self.images removeAllObjects];
}

- (void)updateWithImage:(UIImage *)image
{
//{
//    [self.images addObject:image];
//    
//    self.rightControlItem.textLabel.textColor = LSBlueColor();
//    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInputView.attributedText];
//    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
//    textAttachment.image = image;
//    
//    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
//    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
//    self.textInputView.attributedText = attrStringWithImage;
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    //self.rightControlItem.textLabel.textColor = [UIColor grayColor];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //[self.delegate composeView:self setComposeViewHeight:textView.contentSize.height + 4];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//    } else {
//        self.rightControlItem.textLabel.textColor = LSBlueColor();
//    }
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
