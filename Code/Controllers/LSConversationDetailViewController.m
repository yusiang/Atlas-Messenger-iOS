//
//  LSConversationDetailViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationDetailViewController.h"
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUIParticipantPickerController.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LSUtilities.h"
#import "LSCenterTextTableViewCell.h"
#import "LSInputTableViewCell.h"
#import "SVProgressHUD.h"

typedef NS_ENUM(NSInteger, LSConversationDetailTableSection) {
    LSConversationDetailTableSectionMetadata,
    LSConversationDetailTableSectionParticipants,
    LSConversationDetailTableSectionLocation,
    LSConversationDetailTableSectionDeletion,
    LSConversationDetailTableSectionCount,
};

@interface LSConversationDetailViewController () <LYRUIParticipantPickerControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) NSMutableArray *participantIdentifiers;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;
@property (nonatomic) LYRPolicy *blockPolicy;
@end

@implementation LSConversationDetailViewController

NSString *const LSConversationDetailViewControllerTitle = @"Details";
NSString *const LSAddParticipantsAccessibilityLabel = @"Add Participants";
NSString *const LSConversationNamePlaceholderText = @"Enter Conversation Name";
NSString *const LSConversationMetadataNameKey = @"conversationName";

static NSString *const LSParticipantCellIdentifier = @"participantCell";
static NSString *const LSDefaultCellIdentifier = @"defaultCellIdentifier";
static NSString *const LSInputCellIdentifier = @"inputCell";
static NSString *const LSCenterContentCellIdentifier = @"centerContentCellIdentifier";

+ (instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation
{
    return [[self alloc] initWithConversation:conversation];
}

- (id)initWithConversation:(LYRConversation *)conversation
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _conversation = conversation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LSConversationDetailViewControllerTitle;
    [self configureForConversation];
    
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.rowHeight = 48.0f;
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterContentCellIdentifier];
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LSParticipantCellIdentifier];
    [self.tableView registerClass:[LSInputTableViewCell class] forCellReuseIdentifier:LSInputCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSDefaultCellIdentifier];
    
    [self configureAppearance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conversationMetadataDidChange:)
                                                 name:LSConversationMetadataDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conversationParticipantsDidChange:)
                                                 name:LSConversationParticipantsDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LSConversationDetailTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((LSConversationDetailTableSection)section) {
        case LSConversationDetailTableSectionMetadata:
            return 1;
            
        case LSConversationDetailTableSectionParticipants:
            return self.participantIdentifiers.count + 1;
            
        case LSConversationDetailTableSectionLocation:
            return 1;
            
        case LSConversationDetailTableSectionDeletion:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSConversationDetailTableSection)indexPath.section) {
        case LSConversationDetailTableSectionMetadata: {
            LSInputTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSInputCellIdentifier forIndexPath:indexPath];
            [self configureConversationNameCell:cell];
            return cell;
        }
            
        case LSConversationDetailTableSectionParticipants:
            if (indexPath.row < self.participantIdentifiers.count) {
                NSString *participantIdentifier = [self.participantIdentifiers objectAtIndex:indexPath.row];
                id<LYRUIParticipant>participant = [self.detailDataSource conversationDetailViewController:self participantForIdentifier:participantIdentifier];
                LYRUIParticipantTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSParticipantCellIdentifier forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if ([self blockedParticipantAtIndexPath:indexPath]) {
                    UILabel *blockLabel = [[UILabel alloc] init];
                    blockLabel.text = @"Blocked";
                    blockLabel.textColor = [UIColor redColor];
                    blockLabel.font = [UIFont systemFontOfSize:12];
                    [blockLabel sizeToFit];
                    cell.accessoryView = blockLabel;
                }
                [cell presentParticipant:participant withSortType:LYRUIParticipantPickerSortTypeFirstName shouldShowAvatarImage:YES];
                return cell;
            } else {
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = @"+ Add Participant";
                cell.accessibilityLabel = LSAddParticipantsAccessibilityLabel;
                cell.textLabel.textColor = LYRUIBlueColor();
                cell.textLabel.font = LYRUIMediumFont(14);
                return cell;
            }
            
        case LSConversationDetailTableSectionLocation: {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Share My Location";
            cell.textLabel.textColor = LYRUIBlueColor();
            cell.textLabel.font = LYRUIMediumFont(14);
            return cell;
        }
            
        case LSConversationDetailTableSectionDeletion: {
            LSCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterContentCellIdentifier];
            cell.centerTextLabel.text = @"Global Delete Conversation";
            cell.centerTextLabel.textColor = LYRUIRedColor();
            return cell;
        }
            
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSConversationDetailTableSection)section) {
        case LSConversationDetailTableSectionMetadata:
            return @"Conversation Name";
            
        case LSConversationDetailTableSectionParticipants:
            return @"Participants";
            
        case LSConversationDetailTableSectionLocation:
            return @"Location";
            
        default:
            return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSConversationDetailTableSection)indexPath.section) {
        case LSConversationDetailTableSectionParticipants: {
            BOOL canEdit = indexPath.row < self.participantIdentifiers.count;
            return canEdit;
        }
        case LSConversationDetailTableSectionMetadata:
        case LSConversationDetailTableSectionLocation:
        case LSConversationDetailTableSectionDeletion:
        case LSConversationDetailTableSectionCount:
            return NO;
    }
    return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self removeParticipantAtIndexPath:indexPath];
    }];
    removeAction.backgroundColor = [UIColor lightGrayColor];
    
    NSString *blockString = [self blockedParticipantAtIndexPath:indexPath] ? @"Unblock" : @"Block";
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:blockString handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self blockParticipantAtIndexPath:indexPath];
    }];
    
    blockAction.backgroundColor = [UIColor redColor];
    return @[removeAction, blockAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO - Handle on iOS 7
}

- (void)removeParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *participantIdentifier = self.participantIdentifiers[indexPath.row];
    if (self.changingParticipantsMutatesConversation) {
        NSError *error;
        BOOL success = [self.conversation removeParticipants:[NSSet setWithObject:participantIdentifier] error:&error];
        if (!success) {
            LSAlertWithError(error);
            return;
        }
        [self.participantIdentifiers removeObjectAtIndex:indexPath.row];
    } else {
        [self.participantIdentifiers removeObjectAtIndex:indexPath.row];
        [self switchToConversationForParticipants];
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)blockParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.participantIdentifiers objectAtIndex:indexPath.row];
    LYRPolicy *policy =  [self blockedParticipantAtIndexPath:indexPath];
    
    if (policy) {
        NSError *error;
        [self.applicationController.layerClient removePolicy:policy error:&error];
        if (error) {
            NSLog(@"Falied to remove policy with error: %@", error);
        }
    } else {
        [self blockParticipantWithIdentifier:identifier];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)blockParticipantWithIdentifier:(NSString *)identitifer
{
    LYRPolicy *blockPolicy = [LYRPolicy policyWithType:LYRPolicyTypeBlock];
    blockPolicy.sentByUserID = identitifer;
    
    NSError *error;
    [self.applicationController.layerClient addPolicy:blockPolicy error:&error];
    if (error) {
        NSLog(@"Failed adding policy with error %@", error);
    }
    self.blockPolicy = blockPolicy;
    [SVProgressHUD showSuccessWithStatus:@"Participant Blocked"];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSConversationDetailTableSection)indexPath.section) {
        case LSConversationDetailTableSectionParticipants:
            if (indexPath.row == self.participantIdentifiers.count) {
                [self chooseParticipantToAdd];
            }
            break;
            
        case LSConversationDetailTableSectionLocation:
            [self shareLocation];
            break;
            
        case LSConversationDetailTableSectionDeletion:
            switch (indexPath.row) {
                case 0:
                    [self deleteConversation];
                    break;
                    
                case 1:
                    [self blockParticipantAtIndexPath:indexPath];
                    break;
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions

- (void)shareLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Required"
                                                            message:@"To share your location, enable location services in the Privacy section of the Settings app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Access Required"
                                                                message:@"To share your location, enable location services for this app in the Privacy section of the Settings app."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            return;
            
        default:
            break;
    }
    
    if (self.locationManager) return;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)chooseParticipantToAdd
{
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    self.participantPickerDataSource.excludedIdentifiers = self.conversation.participants;
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource sortType:LYRUIParticipantPickerSortTypeFirstName];
    controller.participantPickerDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)deleteConversation
{
    [self.conversation delete:LYRDeletionModeAllParticipants error:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (manager != self.locationManager) return;
    
    self.locationManager = nil;
    [manager stopUpdatingLocation];
    [self.detailDelegate conversationDetailViewController:self didShareLocation:locations.lastObject];
}

#pragma mark - LYRUIParticipantPickerControllerDelegate

- (void)participantPickerControllerDidCancel:(LYRUIParticipantPickerController *)participantPickerController
{
    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
    self.participantPickerDataSource = nil;
}

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
    self.participantPickerDataSource = nil;
    
    if ([self.participantIdentifiers containsObject:participant.participantIdentifier]) return;
    
    NSString *authenticatedUserID = self.applicationController.layerClient.authenticatedUserID;
    if ([participant.participantIdentifier isEqualToString:authenticatedUserID]) return;
    
    if (self.changingParticipantsMutatesConversation) {
        NSError *error;
        BOOL success = [self.conversation addParticipants:[NSSet setWithObject:participant.participantIdentifier] error:&error];
        if (!success) {
            LSAlertWithError(error);
            return;
        }
        [self.participantIdentifiers addObject:participant.participantIdentifier];
    } else {
        [self.participantIdentifiers addObject:participant.participantIdentifier];
        [self switchToConversationForParticipants];
    }
    [self.tableView reloadData];
}

#pragma mark - Conversation Configuration

- (void)switchToConversationForParticipants
{
    NSSet *participants = [NSSet setWithArray:self.participantIdentifiers];
    LYRConversation *conversation = [self.applicationController.layerClient conversationForParticipants:participants];
    if (!conversation) {
        conversation = [self.applicationController.layerClient newConversationWithParticipants:participants options:nil error:nil];
    }
    [self.detailDelegate conversationDetailViewController:self didChangeConversation:conversation];
    self.conversation = conversation;
    
    NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:LSConversationDetailTableSectionMetadata];
    LSInputTableViewCell *nameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:nameIndexPath];
    if (nameCell) {
        [self configureConversationNameCell:nameCell];
    }
}

- (void)configureForConversation
{
    self.participantIdentifiers = [self.conversation.participants.allObjects mutableCopy];
    [self.participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
}

- (LYRPolicy *)blockedParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    NSOrderedSet *policies = self.applicationController.layerClient.policies;
    NSString *participant = self.participantIdentifiers[indexPath.row];
    NSPredicate *policyPredicate = [NSPredicate predicateWithFormat:@"SELF.sentByUserID = %@", participant];
    NSOrderedSet *filteredPolicies = [policies filteredOrderedSetUsingPredicate:policyPredicate];
    if (filteredPolicies.count) {
        return filteredPolicies.firstObject;
    } else {
        return nil;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self.conversation setValue:textField.text forMetadataAtKeyPath:LSConversationMetadataNameKey];
    } else {
        [self.conversation deleteValueForMetadataAtKeyPath:LSConversationMetadataNameKey];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification Handlers

- (void)conversationMetadataDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;
    
    NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:LSConversationDetailTableSectionMetadata];
    LSInputTableViewCell *nameCell = (LSInputTableViewCell *)[self.tableView cellForRowAtIndexPath:nameIndexPath];
    if (!nameCell) return;
    if ([nameCell.textField isFirstResponder]) return;
    
    [self configureConversationNameCell:nameCell];
}

- (void)conversationParticipantsDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;
    
    [self.tableView beginUpdates];
    
    NSSet *existingIdentifiers = [NSSet setWithArray:self.participantIdentifiers];
    
    NSMutableArray *deletedIndexPaths = [NSMutableArray new];
    NSMutableIndexSet *deletedIndexSet = [NSMutableIndexSet new];
    NSMutableSet *deletedIdentifiers = [existingIdentifiers mutableCopy];
    [deletedIdentifiers minusSet:self.conversation.participants];
    for (NSString *deletedIdentifier in deletedIdentifiers) {
        NSUInteger row = [self.participantIdentifiers indexOfObject:deletedIdentifier];
        [deletedIndexSet addIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:LSConversationDetailTableSectionParticipants];
        [deletedIndexPaths addObject:indexPath];
    }
    [self.participantIdentifiers removeObjectsAtIndexes:deletedIndexSet];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSMutableArray *insertedIndexPaths = [NSMutableArray new];
    NSMutableSet *insertedIdentifiers = [self.conversation.participants mutableCopy];
    NSString *authenticatedUserID = self.applicationController.layerClient.authenticatedUserID;
    if (authenticatedUserID) [insertedIdentifiers removeObject:authenticatedUserID];
    [insertedIdentifiers minusSet:existingIdentifiers];
    for (NSString *identifier in insertedIdentifiers) {
        [self.participantIdentifiers addObject:identifier];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.participantIdentifiers.count - 1 inSection:LSConversationDetailTableSectionParticipants];
        [insertedIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

#pragma mark - Cell Configuration

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleFont:LYRUIMediumFont(14)];
    [[LYRUIParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setBoldTitleFont:[UIFont systemFontOfSize:14]];
}

- (void)configureConversationNameCell:(LSInputTableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textField.delegate = self;
    [cell setGuideText:@"Name:"];
    [cell setPlaceHolderText:@"Enter Conversation Name"];
    NSString *conversationName = [self.conversation.metadata valueForKey:LSConversationMetadataNameKey];
    cell.textField.text = conversationName;
}

@end