//
//  LSContactsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactsViewController.h"
#import "LSContactTableViewCell.h"
#import "LSConversationViewController.h"
#import "LYRSampleConversation.h"

@interface LSContactsViewController ()

@property (nonatomic, strong) NSMutableArray *participants;

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
    [self addCancelBarButton];
    [self addDoneBarButton];
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addCancelBarButton
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    [self.navigationItem setLeftBarButtonItem:cancel];
}

- (void)addDoneBarButton
{
    UIBarButtonItem *newConversation = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    [self.navigationItem setRightBarButtonItem:newConversation];
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
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell updateWithSelectionIndicator:FALSE];
}

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    NSString *contact = [self.participants objectAtIndex:indexPath.row];
    if([self.participants containsObject:contact]) {
        [self.participants removeObject:contact];
    } else {
        [self.participants addObject:contact];
    }
}

- (void)cancelTapped
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        //
    }];
}

- (void) newConversationTapped
{
    LYRSampleConversation *conversation = [[[LYRSampleConversation sampleConversations] allObjects] objectAtIndex:0];
    LSConversationViewController *controller = [[LSConversationViewController alloc] init];
    controller.layerController = self.layerController;
    [self.navigationController pushViewController:controller animated:TRUE];
}


@end
