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
#import "LSUserManager.h"

@interface LSContactsViewController ()

@property (nonatomic, strong) NSMutableArray *participants;

@end

@implementation LSContactsViewController

NSString *const LSContactCellIdentifier = @"contactCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Contacts";
        self.accessibilityLabel = @"Contact List";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContacts];
    [self initializeBarButton];
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:LSContactCellIdentifier];
}

- (void)fetchContacts
{
    self.contacts = [LSUserManager fetchContacts];
    self.participants = [[NSMutableArray alloc] init];
}

- (void)initializeBarButton
{
    UIBarButtonItem *newConversation = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    newConversation.accessibilityLabel = @"start";
    [self.navigationItem setRightBarButtonItem:newConversation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (LSContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSContactCellIdentifier];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSContactTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userInfo = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [userInfo objectForKey:@"fullName"];
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"fullName"]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell updateWithSelectionIndicator:FALSE];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

#pragma mark
#pragma mark Participant List Management Methods

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    NSDictionary *userInfo = [self.contacts objectAtIndex:indexPath.row];
    
    if([self.participants containsObject:userInfo]) {
        [self.participants removeObject:userInfo];
    } else {
        [self.participants addObject:userInfo];
    }
}

- (void)newConversationTapped
{
    LSConversationViewController *controller = [[LSConversationViewController alloc] init];
    
    LYRConversation *conversation = [self.layerController conversationForParticipants:self.participants];
    controller.conversation = conversation;
    controller.layerController = self.layerController;
    [self.navigationController pushViewController:controller animated:TRUE];
    
    //Remove Controller From Navigation Stack
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex: 1];
    self.navigationController.viewControllers = navigationArray;
}


@end
