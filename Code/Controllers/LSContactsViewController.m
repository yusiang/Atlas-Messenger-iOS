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
#import "LSUserManager.h"

@interface LSContactsViewController ()

@property (nonatomic, strong) NSArray *contacts; // SBW: Is this ever set externally? It appears to be loaded internally
@property (nonatomic, strong) NSMutableArray *participants;

@end

@implementation LSContactsViewController

NSString *const LSContactCellIdentifier = @"contactCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SBW: Move to `viewDidLoad`
    self.title = @"Contacts";
    self.accessibilityLabel = @"Contact List";
    
    [self fetchContacts];
    [self initializeBarButton];
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:LSContactCellIdentifier];
    
    // SBW: I'd add an `NSAssert` that `self.contacts` is not `nil`
    // SBW: I'd add an `NSAssert` that `self.layerController` is not `nil`
    NSAssert(self.contacts, @"`self.contacts` cannont be nil");
    NSAssert(self.layerController, @"`self.layerController` cannot be nil");
    
}

- (void)fetchContacts
{
    LSUserManager *manager = [[LSUserManager alloc] init];
    self.contacts = [manager contactsForUser:[manager loggedInUser]];
    self.participants = [NSMutableArray new]; // SBW: [NSMutableArray new] == [[NSMutableArray alloc] init]
}

- (void)initializeBarButton
{
    // SBW: name things consistently with type: newConversationButton
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newConversationTapped)];
    newConversationButton.accessibilityLabel = @"start";
    [self.navigationItem setRightBarButtonItem:newConversationButton];
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
    // SBW: You don't want to use an `NSDictionary` in place of a domain model
    LSUser *user = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = user.fullName;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@", user.fullName];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell updateWithSelectionIndicator:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

#pragma mark
#pragma mark Participant List Management Methods

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    LSUser *user = [self.contacts objectAtIndex:indexPath.row];
    
    if([self.participants containsObject:user]) {
        [self.participants removeObject:user];
    } else {
        [self.participants addObject:user];
    }
}

- (void)newConversationTapped
{
    LSConversationViewController *controller = [[LSConversationViewController alloc] init];
    
    LYRConversation *conversation = [self.layerController conversationForParticipants:self.participants];
    controller.conversation = conversation;
    controller.layerController = self.layerController;
    [self.navigationController pushViewController:controller animated:YES]; // SBW: It's more idiomatic to use `YES` instead of `TRUE`
    
    //Remove Controller From Navigation Stack
    // SBW: You probably want to use `popToViewController:XXXX animated:NO` instead of directly manipulating the stack like this
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex: 1];
    self.navigationController.viewControllers = navigationArray;
}


@end
