//
//  LSContactListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactListViewController.h"
#import "LYRContactTableViewCell.h"
#import "LSContactCellPresenter.h"
#import "LSContactViewController.h"
#import "LYRSelectionIndicator.h"

@interface LSContactListViewController () <LYRContactListDataSource, LYRContactListDelegate>

@property (nonatomic) NSDictionary *contacts;
@property (nonatomic) NSMutableSet *selectedContacts;
@property (nonatomic, strong) NSDictionary *filteredContacts;

@end

@implementation LSContactListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.title = @"Contacts";
    self.accessibilityLabel = @"Contacts";
    
    // Make sure the applicationController object is not nil
    NSAssert(self.applicationController, @"`self.applicationController` cannot be nil");
    
    // Left bar button item is the text Cancel
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelButtonTapped:)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    // Right bar button item is the text Done
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneButtonTapped:)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadContacts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactData) name:@"contactsPersited" object:nil];
    
    [self fetchContacts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchContacts
{
    NSError *error = nil;
    NSMutableSet *contacts = [NSMutableSet setWithSet:[self.applicationController.persistenceManager persistedUsersWithError:&error]];
    [contacts removeObject:self.applicationController.APIManager.authenticatedSession.user];
    
    // Sort contacts in alphabetical order by firstName
    NSArray *sortedContacts = [[contacts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
    
    self.contacts = [self groupContactsAlphabetically:sortedContacts];
    
    // Filtered contacts should start out as all contacts
    self.filteredContacts = self.contacts;
    
    // Initialize placeholder set for multi-selection
    self.selectedContacts = [[NSMutableSet alloc] init];
    
    // Load up the table view
    [self.tableView reloadData];
}

//Groups users into arrays based on the fist letter of their first name.
//Then creates a dictionary with Letters as keys and user arrays as objects
- (NSDictionary *)groupContactsAlphabetically:(NSArray *)contacts
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

// Returns the data array. self.filteredContacts is for search
- (NSDictionary *)currentDataArray
{
    if (self.isSearching) {
        return self.filteredContacts;
    }
    return self.contacts;
}

// Return the number of unique sections to display. Section correspond to an individual letter
- (NSUInteger)numberOfSectionsInViewController:(LYRContactListViewController *)contactListViewController
{
    return [[[self currentDataArray] allKeys] count];
}

// Return number of contacts for each alphabetical section
- (NSUInteger)contactListViewController:(LYRContactListViewController *)contactListViewController numberOfContactsInSection:(NSUInteger )section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[[self currentDataArray] objectForKey:key] count];
}

// Return the presenter for each user
- (id<LYRContactCellPresenter>)contactListViewController:(LYRContactListViewController *)contactListViewController presenterForContactAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    return [LSContactCellPresenter presenterWithUser:user];
}

// Return the selection indicator for display
- (UIControl *)contactListViewController:(LYRContactListViewController *)contactListViewController selectionIndicatorForContactAtIndexPath:(NSIndexPath *)indexPath
{
    return [LYRSelectionIndicator initWithDiameter:30];
}

// Where possible, contact search should occur in the model layer
- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion
{
    [self.applicationController.persistenceManager performContactSearchWithString:searchString completion:^(NSSet *contacts, NSError *error) {
        NSArray *sortedContacts = [[contacts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
        self.filteredContacts = [self groupContactsAlphabetically:sortedContacts];
        completion();
    }];
}

// For multi-selection, we check to see if the participant exists in the selected array. If no, we add...if yes, we remove.
- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSelectContactAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    //
    //    if ([self.selectedContacts containsObject:user]) {
    //        [self.selectedContacts removeObject:user];
    //    } else {
    //        [self.selectedContacts addObject:user];
    //    }
    LSContactViewController *controller = [LSContactViewController new];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:TRUE];
}

// Returns the appropriate letter cooresponding to each section
- (NSString *)contactListViewController:(LYRContactListViewController *)contactListViewController letterForContactsInSection:(NSUInteger)section
{
    return [[self sortedContactKeys] objectAtIndex:section];
}

// Default height is 58
- (CGFloat)contactListViewController:(LYRContactListViewController *)contactListViewController heightForContactAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 58;
}

//
- (NSArray *)sortedContactKeys
{
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[[self currentDataArray] allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    return mutableKeys;
}

- (void)reloadContactData
{
    [self fetchContacts];
    [self.tableView reloadData];
}

- (void)cancelButtonTapped:(id)sender
{
    [self.selectionDelegate contactsSelectionViewControllerDidCancel:self];
}

- (void)doneButtonTapped:(id)sender
{
    [self.selectionDelegate contactsSelectionViewController:self didSelectContacts:self.selectedContacts];
}

@end
