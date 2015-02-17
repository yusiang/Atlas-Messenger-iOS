//
//  LSConversationDetailViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationDetailViewController.h"
#import <Atlas/Atlas.h>
#import "LSParticipantDataSource.h"
#import "LSUtilities.h"
#import "LSCenterTextTableViewCell.h"
#import "LSInputTableViewCell.h"
#import "SVProgressHUD.h"
#import "LSParticipantTableViewController.h"

typedef NS_ENUM(NSInteger, LSConversationDetailTableSection) {
    LSConversationDetailTableSectionMetadata,
    LSConversationDetailTableSectionParticipants,
    LSConversationDetailTableSectionLocation,
    LSConversationDetailTableSectionLeave,
    LSConversationDetailTableSectionCount,
};

@interface LSConversationDetailViewController () <ATLParticipantTableViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) NSMutableArray *participantIdentifiers;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) LSParticipantDataSource *participantDataSource;

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
    [self.tableView registerClass:[ATLParticipantTableViewCell class] forCellReuseIdentifier:LSParticipantCellIdentifier];
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
            
        case LSConversationDetailTableSectionLeave:
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
                id<ATLParticipant>participant = [self.detailDataSource conversationDetailViewController:self participantForIdentifier:participantIdentifier];
                ATLParticipantTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSParticipantCellIdentifier forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if ([self blockedParticipantAtIndexPath:indexPath]) {
                    UILabel *blockLabel = [[UILabel alloc] init];
                    blockLabel.text = @"Blocked";
                    blockLabel.textColor = [UIColor redColor];
                    blockLabel.font = [UIFont systemFontOfSize:12];
                    [blockLabel sizeToFit];
                    cell.accessoryView = blockLabel;
                }
                [cell presentParticipant:participant withSortType:ATLParticipantPickerSortTypeFirstName shouldShowAvatarItem:YES];
                return cell;
            } else {
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.attributedText = [self addParticipantAttributedString];
                cell.accessibilityLabel = LSAddParticipantsAccessibilityLabel;
                cell.imageView.image = [UIImage imageNamed:@"AtlasResource.bundle/plus"];
                return cell;
            }
            
        case LSConversationDetailTableSectionLocation: {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Send My Current Location";
            cell.textLabel.textColor = ATLBlueColor();
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            return cell;
        }
            
        case LSConversationDetailTableSectionLeave: {
            LSCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterContentCellIdentifier];
            cell.centerTextLabel.textColor = ATLRedColor();
            cell.centerTextLabel.text = @"Leave Conversation";
            return cell;
        }
            
        default:
            return nil;
    }
}

- (NSAttributedString *)addParticipantAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Add Participant"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:ATLBlueColor() range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17]  range:NSMakeRange(0, attributedString.length)];
    return attributedString;
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
    if (indexPath.section == LSConversationDetailTableSectionParticipants) {
    // Prevent removal in 1 to 1 conversations.
        if (self.conversation.participants.count < 3) {
            return NO;
        }
        BOOL canEdit = indexPath.row < self.participantIdentifiers.count;
        return canEdit;
    }
    return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self removeParticipantAtIndexPath:indexPath];
    }];
    removeAction.backgroundColor = ATLGrayColor();
    
    NSString *blockString = [self blockedParticipantAtIndexPath:indexPath] ? @"Unblock" : @"Block";
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:blockString handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self blockParticipantAtIndexPath:indexPath];
    }];
    blockAction.backgroundColor = ATLRedColor();
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
            
        case LSConversationDetailTableSectionLeave:
            [self leaveConversation];
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions

- (void)shareLocation
{
    // Fix
}

- (void)chooseParticipantToAdd
{
    self.participantDataSource = [LSParticipantDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    self.participantDataSource.excludedIdentifiers = self.conversation.participants;
    LSParticipantTableViewController  *controller = [LSParticipantTableViewController participantTableViewControllerWithParticipants:self.participantDataSource.participants sortType:ATLParticipantPickerSortTypeFirstName];
    controller.delegate = self;
    controller.allowsMultipleSelection = NO;
    
    UINavigationController *navigationController =[[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)leaveConversation
{
    NSSet *participants = [NSSet setWithObject:self.applicationController.layerClient.authenticatedUserID];
    NSError *error;
    [self.conversation removeParticipants:participants error:&error];
    if (error) {
        NSLog(@"Failed removing participant from conversation with error: %@", error);
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - ATLParticipantTableViewControllerDelegate

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.participantDataSource = nil;
    
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

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.participantDataSource participantsMatchingSearchText:searchText completion:^(NSSet *participants) {
        completion(participants);
    }];
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
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleColor:[UIColor blackColor]];
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleFont:[UIFont systemFontOfSize:17]];
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setBoldTitleFont:[UIFont systemFontOfSize:17]];
    [[ATLAvatarImageView appearanceWhenContainedIn:[ATLParticipantTableViewCell class], nil] setAvatarImageViewDiameter:32];
}

- (void)configureConversationNameCell:(LSInputTableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textField.delegate = self;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [cell setGuideText:@"Name:"];
    [cell setPlaceHolderText:@"Enter Conversation Name"];
    NSString *conversationName = [self.conversation.metadata valueForKey:LSConversationMetadataNameKey];
    cell.textField.text = conversationName;
}

@end