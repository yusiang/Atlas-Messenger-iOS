//
//  LSComposeView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSComposeView.h"
#import "LSButton.h"

@implementation LSComposeView

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addTextField];
        [self addCameraButton];
        [self addSendButton];
        self.textField.delegate = self;
        self.accessibilityLabel = @"composeView";
    }
    return self;
}

- (void)addTextField
{
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 6, 200, 36)];
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 4.0f;
    [self.textField setAccessibilityLabel:@"composeTextView"];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 36)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.placeholder = @"Enter A Message";
    [self addSubview:self.textField];
}

- (void)addCameraButton
{
    LSButton *button = [[LSButton alloc] initWithFrame:CGRectMake(6, 6, 38, 36)];
    [button setFont:[UIFont fontWithName:kLayerFont size:10]];
    button.layer.cornerRadius = 4;
    [button addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor redColor]];
    [button setAccessibilityLabel:@"sendButton"];
    [self addSubview:button];
}

- (void)addSendButton
{
    LSButton *button = [[LSButton alloc] initWithFrame:CGRectMake(self.frame.size.width -58, 6, 52, 36)];
    [button setFont:[UIFont fontWithName:kLayerFont size:10]];
    button.layer.cornerRadius = 4;
    [button addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [button setText:@"Send"];
    [button setBackgroundColor:kLayerColor];
    [button setAccessibilityLabel:@"sendButton"];
    [self addSubview:button];
}

- (void)cameraTapped
{
    [self.delegate cameraTapped];
}

- (void)sendMessage
{
    if (self.textField.text) {
        [self.delegate sendMessageWithText:self.textField.text];
    }
    [self.textField setText:@""];
    [self textFieldShouldReturn:self.textField];
}

- (void)updateWithImage:(UIImage *)image
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 50, self.frame.size.width, self.frame.size.height + 50);
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y - 50, self.textField.frame.size.width, self.textField.frame.size.height + 50);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    imageView.image = image;
    [self.textField setLeftView:imageView];
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
