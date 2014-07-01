//
//  LSContactsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactsSelectionViewController.h"
#import "LSContactTableViewCell.h"

@interface LSContactsSelectionViewController ()

@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableSet *selectedContacts;

@end

@implementation LSContactsSelectionViewController

NSString *const LSContactCellIdentifier = @"contactCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _selectedContacts = [NSMutableSet set];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Contacts";
    self.accessibilityLabel = @"Contacts";
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:LSContactCellIdentifier];
    
    NSError *error = nil;
    NSSet *contacts = [self filterContacts:[self.persistenceManager persistedUsersWithError:&error]];
    self.contacts = [contacts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES] ]];
    
    if (!self.contacts.count > 0) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"No Contacts";
        label.accessibilityLabel = @"No Contacts";
        [label sizeToFit];
        label.center = self.view.center;
        [self.view addSubview:label];
    }
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelButtonTapped:)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(doneButtonTapped:)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    self.tableView.accessibilityLabel = @"Contact List";
}

- (NSSet *)filterContacts:(NSSet *)contacts
{
    NSMutableSet *contactsToEvaluate = [NSMutableSet setWithSet:contacts];
    
    LSSession *session = self.APIManager.authenticatedSession;
    LSUser *authenticatedUser = session.user;
    
    [contactsToEvaluate removeObject:authenticatedUser];
    return contactsToEvaluate;
}

#pragma mark - Actions

- (void)cancelButtonTapped:(id)sender
{
    [self.delegate contactsSelectionViewControllerDidCancel:self];
}

- (void)doneButtonTapped:(id)sender
{
    [self.delegate contactsSelectionViewController:self didSelectContacts:self.selectedContacts];
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
    if ([self.selectedContacts containsObject:user]) {
        [self.selectedContacts removeObject:user];
    } else {
        [self.selectedContacts addObject:user];
    }
}

@end
