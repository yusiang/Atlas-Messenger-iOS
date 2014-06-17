//
//  LSComposeView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSComposeView.h"
#import "LSMediaAttachement.h"

@implementation LSComposeView

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initizlizeSubviews];
        self.textField.delegate = self;
        self.accessibilityLabel = @"composeView";
    }
    return self;
}

- (void)initizlizeSubviews
{
    [self addBackingTextView];
    [self addTextField];
    [self addCameraButton];
    [self addSendButton];
}

- (void)addBackingTextView
{
    
}

- (void)addTextField
{
    if (!self.textField) {
        self.textField = [[UITextView alloc] init];
    }
    self.textField.frame = CGRectMake(50, self.frame.size.height - 42, 200, 36);
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 4.0f;
    [self.textField setAccessibilityLabel:@"composeTextView"];
    
//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 36)];
//    self.textField.leftView = paddingView;
//    self.textField.leftViewMode = UITextFieldViewModeAlways;
//    
//    self.textField.placeholder = @"Enter A Message";
    [self addSubview:self.textField];
}

- (void)addCameraButton
{
    if (!self.cameraButton){
        self.cameraButton = [[LSButton alloc] init];
    }
    self.cameraButton.frame = CGRectMake(6, self.frame.size.height - 42, 38, 36);
    [self.cameraButton setFont:[UIFont fontWithName:kLayerFont size:10]];
    self.cameraButton.layer.cornerRadius = 4;
    [self.cameraButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setBackgroundColor:[UIColor redColor]];
    [self.cameraButton setAccessibilityLabel:@"cameraButton"];
    [self addSubview:self.cameraButton];
}

- (void)addSendButton
{
    if (self.sendButton) {
        self.sendButton = [[LSButton alloc] init];
    }
    self.sendButton.frame = CGRectMake(self.frame.size.width -58, self.frame.size.height - 42, 52, 36);
    [self.sendButton setFont:[UIFont fontWithName:kLayerFont size:10]];
    self.sendButton.layer.cornerRadius = 4;
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setText:@"Send"];
    [self.sendButton setBackgroundColor:kLayerColor];
    [self.sendButton setAccessibilityLabel:@"sendButton"];
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
    if ([self.textField.attributedText isKindOfClass:[UIImageView class]]) {
        
    }
}

- (void)updateWithImage:(UIImage *)image
{
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
