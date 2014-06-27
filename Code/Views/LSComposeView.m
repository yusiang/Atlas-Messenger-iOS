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

@property (nonatomic) CGRect defaultRect;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation LSComposeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.defaultRect = frame;
        self.accessibilityLabel = @"composeView";
        [self initizlizeSubviews];
        self.images = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)initizlizeSubviews
{
    [self initializeTextField];
    [self initializeCameraButton];
    [self initializeSendButton];
    [self configureDefaultViewConstraints];
}

- (void)initializeTextField
{
    if (!self.textVIew) {
        self.textVIew = [[UITextView alloc] init];
        self.textVIew.delegate = self;
    }
    self.textVIew.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textVIew.layer.borderWidth = 1;
    self.textVIew.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:16];
    self.textVIew.layer.cornerRadius = 4.0f;
    self.textVIew.accessibilityLabel = @"Compose TextView";
    [self addSubview:self.textVIew];
}

- (void)initializeCameraButton
{
    if (!self.cameraButton){
        self.cameraButton = [[LSButton alloc] initWithText:nil];
        [self.cameraButton setBackgroundColor:[UIColor lightGrayColor]];
    }
    [self.cameraButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraButton];
}

- (void)initializeSendButton
{
    if (!self.sendButton) {
        self.sendButton = [[LSButton alloc] initWithText:@"Cam"];
        [self.cameraButton setBackgroundColor:[LSUIConstants layerBlueColor]];
    }
    
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)configureDefaultViewConstraints
{
    self.frame = self.defaultRect;
    self.textVIew.frame = CGRectMake(50, self.frame.size.height - 42, 200, 36);
    self.cameraButton.frame = CGRectMake(6, self.frame.size.height - 42, 38, 36);
    self.sendButton.frame = CGRectMake(self.frame.size.width -58, self.frame.size.height - 42, 52, 36);
}


- (void)configurePhotoViewConstraints
{
    if (self.frame.size.height < self.defaultRect.size.height + 50) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 50, self.frame.size.width, self.frame.size.height + 50);
        self.textVIew.frame = CGRectMake(self.textVIew.frame.origin.x, self.frame.size.height - 92, self.textVIew.frame.size.width, self.textVIew.frame.size.height + 50);
        self.cameraButton.frame = CGRectMake(6, self.frame.size.height - 42, 38, 36);
        self.sendButton.frame = CGRectMake(self.frame.size.width -58, self.frame.size.height - 42, 52, 36);
    }
}

- (void)cameraTapped
{
    [self.delegate cameraTapped];
}

- (void)sendMessage
{
    [self.textVIew resignFirstResponder];
    
    if (self.textVIew.attributedText) {
        NSAttributedString *string = self.textVIew.attributedText;

    }
    
    if (![self.textVIew.text isEqualToString:@""]) {
        [self.delegate sendMessageWithText:self.textVIew.text];
        [self.textVIew setText:@""];
    }
    
    if (self.images.count > 0) {
        for (UIImage *image in self.images) {
            [self.delegate sendMessageWithImage:image];
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self configureDefaultViewConstraints];
    }];
}

- (void)updateWithImage:(UIImage *)image
{
    [self.images addObject:image];
    
    [self configurePhotoViewConstraints];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textVIew.attributedText];
    
    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
    
    textAttachment.image = image;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
    
    self.textVIew.attributedText = attrStringWithImage;
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
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
