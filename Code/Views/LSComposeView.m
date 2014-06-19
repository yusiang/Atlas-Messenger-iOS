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

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation LSComposeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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
}

- (void)initializeTextField
{
    if (!self.textField) {
        self.textField = [[UITextView alloc] init];
        self.textField.delegate = self;
    }
    self.textField.frame = CGRectMake(50, self.frame.size.height - 42, 200, 36);
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 4.0f;
    self.textField.font = [UIFont fontWithName:[LSUIConstants layerMediumFont] size:14];
    self.textField.accessibilityLabel = @"Compose TextView";
    [self addSubview:self.textField];
}

- (void)initializeCameraButton
{
    if (!self.cameraButton){
        self.cameraButton = [[LSButton alloc] initWithText:@"Cam"];
        [self.cameraButton setBackgroundColor:[UIColor redColor]];
    }
    self.cameraButton.frame = CGRectMake(6, self.frame.size.height - 42, 38, 36);
    [self.cameraButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraButton];
}

- (void)initializeSendButton
{
    if (!self.sendButton) {
        self.sendButton = [[LSButton alloc] initWithText:@"Send"];
    }
    self.sendButton.frame = CGRectMake(self.frame.size.width -58, self.frame.size.height - 42, 52, 36);
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)cameraTapped
{
    [self.delegate cameraTapped];
}

- (void)sendMessage
{
    if (self.textField.text) {
        [self.delegate sendMessageWithText:self.textField.text];
        [self.textField setText:@""];
    }
    
    if (self.images.count > 0) {
        for (UIImage *image in self.images) {
            [self.delegate sendMessageWithImage:image];
            [self adjustFramePostImageSend];
        }
    }
}

- (void)updateWithImage:(UIImage *)image
{
    [self.images addObject:image];
    [self adjustFrameForImage];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"a"];
    
    LSMediaAttachement *textAttachment = [[LSMediaAttachement alloc] init];
    
    textAttachment.image = image;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
    self.textField.attributedText = attributedString;
}

-(void)adjustFrameForImage
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 50, self.frame.size.width, self.frame.size.height + 50);
    [self initizlizeSubviews];
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y - 50, self.textField.frame.size.width, self.textField.frame.size.height + 50);
}

-(void)adjustFramePostImageSend
{
    [self initizlizeSubviews];
}

#pragma mark
#pragma mark TextViewDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return TRUE;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return TRUE;
}

@end
