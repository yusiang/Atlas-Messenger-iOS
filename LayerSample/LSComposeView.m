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
        [self addSendButton];
        self.textField.delegate = self;
    }
    return self;
}

- (void)addTextField
{
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(6, 6, 250, 36)];
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 4.0f;
    [self.textField setAccessibilityLabel:@"Compose TextView"];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 36)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.placeholder = @"Enter A Message";
    [self addSubview:self.textField];
}

- (void)addSendButton
{
    LSButton *button = [[LSButton alloc] initWithFrame:CGRectMake(self.frame.size.width -58, 6, 52, 36)];
    [button setFont:[UIFont fontWithName:kLayerFont size:10]];
    [button addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [button setText:@"Send"];
    [button setBackgroundColor:kLayerColor];
    [button setAccessibilityLabel:@"Button"];
    [self addSubview:button];
}

- (void)sendMessage
{
    NSString *string = self.textField.text;
    [self textFieldShouldReturn:self.textField];
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
