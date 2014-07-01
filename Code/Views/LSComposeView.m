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

@property (nonatomic, strong) UIView *backingTextView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) LSButton *cameraButton;
@property (nonatomic, strong) LSButton *sendButton;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) CGRect defaultRect;

@end

@implementation LSComposeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.defaultRect = frame;
        self.backgroundColor = [LSUIConstants veryLightGrayColor];
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
    if (!self.textView) {
        self.textView = [[UITextView alloc] init];
        self.textView.delegate = self;
    }
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:16];
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.accessibilityLabel = @"Compose TextView";
    [self addSubview:self.textView];
}

- (void)initializeCameraButton
{
    if (!self.cameraButton){
        self.cameraButton = [[LSButton alloc] initWithText:@""];
    }
    [self.cameraButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.cameraButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraButton];
}

- (void)initializeSendButton
{
    if (!self.sendButton) {
        self.sendButton = [[LSButton alloc] initWithText:@"Send"];
    }
    [self.sendButton setFont:[UIFont fontWithName:[LSUIConstants layerMediumFont] size:16]];
    [self.sendButton setTextColor:[UIColor whiteColor]];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)configureDefaultViewConstraints
{
    self.frame = self.defaultRect;
    self.textView.frame = CGRectMake(50, self.frame.size.height - 42, 200, 36);
    self.cameraButton.frame = CGRectMake(6, self.frame.size.height - 42, 38, 36);
    [self addCameraIconToButton:self.cameraButton];
    self.sendButton.frame = CGRectMake(self.frame.size.width -58, self.frame.size.height - 42, 52, 36);
}

- (void)addCameraIconToButton:(LSButton *)button
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width - 20, button.frame.size.height - 20)];
    imageView.image = [UIImage imageNamed:@"camera"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.center = button.center;
    [self addSubview:imageView];
}

- (void)configurePhotoViewConstraints
{
    if (self.frame.size.height < self.defaultRect.size.height + 50) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 50, self.frame.size.width, self.frame.size.height + 50);
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.frame.size.height - 92, self.textView.frame.size.width, self.textView.frame.size.height + 50);
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
    [self.textView resignFirstResponder];
    
    if (self.images.count > 0) {
        for (UIImage *image in self.images) {
            [self.delegate composeView:self sendMessageWithImage:image];
        }
    } else {
        [self.delegate composeView:self sendMessageWithText:self.textView.text];
        [self.textView setText:@""];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self configureDefaultViewConstraints];
    }];
}

- (void)updateWithImage:(UIImage *)image
{
    [self.images addObject:image];
    
    [self configurePhotoViewConstraints];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    
    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
    
    textAttachment.image = image;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withAttributedString:attrStringWithImage];
    
    self.textView.attributedText = attrStringWithImage;
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
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
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
