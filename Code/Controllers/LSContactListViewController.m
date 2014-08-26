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

@interface LSContactListViewController ()

@property (nonatomic) NSDictionary *contacts;
@property (nonatomic) NSMutableSet *selectedContacts;
@end

@implementation LSContactListViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadContacts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactData) name:@"contactsPersited" object:nil];
    
    self.title = @"Select Contacts";
    self.accessibilityLabel = @"Contacts";
    
    
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchContacts];
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
    [self.tableView reloadData];
}

//Removes the currently authenticated user from the contacts array
- (NSSet *)filteredContacts
{
    NSError *error = nil;
    NSMutableSet *contactsToEvaluate = [NSMutableSet setWithSet:[self.applicationController.persistenceManager persistedUsersWithError:&error]];
    [contactsToEvaluate removeObject:self.applicationController.APIManager.authenticatedSession.user];
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

- (NSUInteger)numberOfSectionsInViewController:(LYRContactListViewController *)contactListViewController
{
    return [[self.contacts allKeys] count];
}

- (NSUInteger)contactListViewController:(LYRContactListViewController *)contactListViewController numberOfContactsInSection:(NSUInteger )section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[self.contacts objectForKey:key] count];
}

- (id<LYRContactPresenter>)contactListViewController:(LYRContactListViewController *)contactListViewController presenterForContactAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    LSUser *user = [[self.contacts objectForKey:key] objectAtIndex:indexPath.row];
    return [LSContactCellPresenter presenterWithUser:user];
}

- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion
{
    NSString *wildcard = [NSString stringWithFormat:@"*%@*", searchString];
    
//    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(fullName like[cd] %@)", wildcard];
//    NSArray *resultArray = [[self.contacts allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(key1 == %@) AND (key2==%@)", @"tt",@"vv"]];
//    NSSet *filteredUsers = [allUsers filteredSetUsingPredicate:filterPredicate];
//    NSSet *filteredUserIDs = [filteredUsers valueForKey:@"userID"];
//    
//    NSMutableOrderedSet *filteredConversations = [NSMutableOrderedSet orderedSet];
//    for (LYRConversation *conversation in self.conversations) {
//        for (NSString *participantID in filteredUserIDs) {
//            if ([conversation.participants containsObject:participantID]) {
//                [filteredConversations addObject:conversation];
//            }
//        }
//    }
//    
//    // do a filter of the search
//    self.filteredConversations = [filteredConversations array];
    completion();
}

- (void)contactListViewController:(LYRContactListViewController *)contactListViewController didSelectContactAtIndex:(NSIndexPath *)indexPath
{
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

- (NSUInteger)contactListViewController:(LYRContactListViewController *)contactListViewController heightForContactAtIndex:(NSUInteger)index
{
    return 48;
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

- (void)reloadContactData
{
    [self fetchContacts];
    [self.tableView reloadData];
}

- (void)cancelButtonTapped:(id)sender
{
   // [self.delegate contactsSelectionViewControllerDidCancel:self];
}

- (void)doneButtonTapped:(id)sender
{
   // [self.delegate contactsSelectionViewController:self didSelectContacts:self.selectedContacts];
}

@end
