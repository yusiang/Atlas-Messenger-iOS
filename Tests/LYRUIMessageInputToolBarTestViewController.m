//
//  LYUIMessageInputToolBarTestViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageInputToolBarTestViewController.h"

@interface LYRUIMessageInputToolBarTestViewController ()

@property (nonatomic) UIView *inputAccessoryView;

@end

@implementation LYRUIMessageInputToolBarTestViewController

- (id)init
{
    self = [super init];
    if (self) {
        _toolBar =  [LYRUIMessageInputToolbar new];
        [_toolBar sizeToFit];
        _inputAccessoryView = _toolBar;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
