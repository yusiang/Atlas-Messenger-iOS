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
        case LSConversationDetailTableSectionParticipants:
            return indexPath.row < self.participantIdentifiers.count;

        case LSConversationDetailTableSectionMetadata:
        case LSConversationDetailTableSectionLocation:
        case LSConversationDetailTableSectionDeletion:
        case LSConversationDetailTableSectionCount:
            return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;

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
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
            [self deleteConversation];
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
