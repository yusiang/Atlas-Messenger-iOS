//
//  LSContactsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactsViewController.h"
#import "LSContactTableViewCell.h"

@interface LSContactsViewController ()

@end

@implementation LSContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:@"cell"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (LSContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell updateWithSelectionIndicator:FALSE];
    cell.textLabel.text = @"Name";
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSContactTableViewCell *cell = (LSContactTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell updateWithSelectionIndicator:YES];
}
@end
