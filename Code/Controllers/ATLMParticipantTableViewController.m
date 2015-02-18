//
//  ATLMParticipantTableViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 2/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMParticipantTableViewController.h"

@interface ATLMParticipantTableViewController ()

@end

@implementation ATLMParticipantTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTap)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
}
- (void)handleCancelTap
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
