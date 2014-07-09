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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.title = @"Select Contacts";
    self.accessibilityLabel = @"Contacts";
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:LSContactCellIdentifier];
    
    NSError *error = nil;
    NSSet *contacts = [self filterContacts:[self.persistenceManager persistedUsersWithError:&error]];
    NSArray *sortedContacts = [[contacts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
    self.contacts = [self sortContactsAlphabetically:sortedContacts];
    
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
    NSLog(@"%@", dict);
    return dict;
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
    NSString *key = [[self.contacts allKeys] objectAtIndex:section];
    return [[self.contacts objectForKey:key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *seperator = [[UIView alloc] init];
    seperator.backgroundColor = LSGrayColor();
    seperator.frame = CGRectMake(16, 25, 304, 1);
    [view addSubview:seperator];
    
    
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[self.contacts allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    NSString *key = [mutableKeys objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = LSMediumFont(14);
    label.text = key;
    label.textColor = LSGrayColor();
    [label sizeToFit];
    label.center = CGPointMake(20, 14);
    [view addSubview:label];
    
    return view;
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
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[self.contacts allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    NSString *key = [mutableKeys objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
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

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [self.contacts allKeys];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return 1;
//}

#pragma mark
#pragma mark Participant List Management Methods

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    NSString *key = [[self.contacts allKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
    if ([self.selectedContacts containsObject:user]) {
        [self.selectedContacts removeObject:user];
    } else {
        [self.selectedContacts addObject:user];
    }
}



@end
