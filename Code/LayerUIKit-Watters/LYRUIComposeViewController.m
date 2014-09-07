//
//  LYRUIComposeViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/5/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIComposeViewController.h"

@interface LYRUIComposeViewController () <UITextViewDelegate>

@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic, strong) NSMutableArray *contentParts;
@property (nonatomic) CGFloat textViewContentSizeHeight;

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
    self.textInputView.font = [UIFont systemFontOfSize:14];
    self.textInputView.accessibilityLabel = @"Compose TextView";
    self.textViewContentSizeHeight = self.textInputView.contentSize.height;
    [self.view addSubview:self.textInputView];
    
    // Initialize the Send Button
    self.rightControlItem = [[UIButton alloc] init];
    self.rightControlItem.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightControlItem.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightControlItem setTitle:@"SEND" forState:UIControlStateNormal];
    [self.rightControlItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rightControlItem setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [self.rightControlItem addTarget:self action:@selector(rightControlItemTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightControlItem];
    
    [self setupLayoutConstraints];
    
    // Setup
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.keyboardIsOnScreen = NO;
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

}

- (void)rightControlItemTapped
{
    [self.rightControlItem setHighlighted:FALSE];

}

- (void)updateWithImage:(UIImage *)image
{
    [self.contentParts addObject:image];
    
    [self.rightControlItem setHighlighted:TRUE];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInputView.attributedText];
//    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
//    textAttachment.image = image;
    
//    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
//    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
//    self.textInputView.attributedText = attrStringWithImage;
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textViewContentSizeHeight = textView.contentSize.height;
    [self.rightControlItem setHighlighted:TRUE];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.rightControlItem setHighlighted:FALSE];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textViewContentSizeHeight != textView.contentSize.height) {
        CGFloat heightDiff = textView.contentSize.height - self.textViewContentSizeHeight;
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - heightDiff , self.view.frame.size.width, self.view.frame.size.height + heightDiff)];
        self.textViewContentSizeHeight = textView.contentSize.height;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
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
