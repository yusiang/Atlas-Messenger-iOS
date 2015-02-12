//
//  LSParticipantViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 2/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LSParticipantTableViewController.h"

@interface LSParticipantTableViewController ()

@end

@implementation LSParticipantTableViewController

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
