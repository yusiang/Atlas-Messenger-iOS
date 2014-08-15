//
//  LSContactsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactsSelectionViewController.h"
#import "LSContactTableViewCell.h"
#import "LSUIConstants.h"
#import "LSContactListHeader.h"

@interface LSContactsSelectionViewController ()

@property (nonatomic) NSDictionary *contacts;
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadContacts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactData) name:@"contactsPersited" object:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.title = @"Select Contacts";
    self.accessibilityLabel = @"Contacts";
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:LSContactCellIdentifier];
    
    [self fetchContacts];
    
    if (!self.contacts.count > 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyContacts"]];
        imageView.center = self.view.center;
        imageView.accessibilityLabel = @"Empty Contacts";
        [self.view addSubview:imageView];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchContacts
{
    NSSet *filteredContacts = [self filteredContacts];
    NSArray *sortedContacts = [[filteredContacts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
    self.contacts = [self sortContactsAlphabetically:sortedContacts];
}

//Removes the currently authenticated user from the contacts array
- (NSSet *)filteredContacts
{
    NSError *error = nil;
    NSMutableSet *contactsToEvaluate = [NSMutableSet setWithSet:[self.persistenceManager persistedUsersWithError:&error]];
    [contactsToEvaluate removeObject:self.APIManager.authenticatedSession.user];
    return contactsToEvaluate;
}

//Groups users into arrays based on the fist letter of their first name.
//Then creates a dictionary with Letters as keys and user arrays as objects
- (NSDictionary *)sortContactsAlphabetically:(NSArray *)contacts
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (LSUser *user in contacts) {
        NSString *firstName = user.firstName;
        NSString *firstLetter = [[firstName substringToIndex:1] uppercaseString];
        NSMutableArray *letterList = [dict objectForKey:firstLetter];
        if (!letterList) {
            letterList = [NSMutableArray array];
        }
        [letterList addObject:user];
        [dict setObject:letterList forKey:firstLetter];
    }
    return dict;
}

- (void)reloadContactData
{
    [self fetchContacts];
    [self.tableView reloadData];
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
    return [[self.contacts allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[self.contacts objectForKey:key] count];
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (LSContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSContactCellIdentifier];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LSContactTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
    cell.textLabel.text = user.fullName;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@", user.fullName];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]) {
        [cell updateWithSelectionIndicator:YES];
    } else {
        [cell updateWithSelectionIndicator:NO];
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[LSContactListHeader alloc] initWithKey:key];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self sortedContactKeys];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 0;
}

#pragma mark
#pragma mark Participant List Management Methods

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]) {
        [self.selectedContacts removeObject:user];
    } else {
        [self.selectedContacts addObject:user];
    }
}

- (NSArray *)sortedContactKeys
{
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[self.contacts allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    return mutableKeys;
}


@end
