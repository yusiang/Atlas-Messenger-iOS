//
//  LYRUIConversationDetailViewController.m
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
#import "LYRUIAvatarImageView.h"
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
    
    [self configureForConversation];
    
    self.title = @"Details";
    self.accessibilityLabel = @"Details";
    
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.rowHeight = 48.0f;
    
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterContentCellIdentifier];
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LSParticipantCellIdentifier];
    [self.tableView registerClass:[LSInputTableViewCell  class] forCellReuseIdentifier:LSInputCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSDefaultCellIdentifier];
   
    [self configureAppearance];
}

#pragma mark - Table view data source

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
    UITableViewCell *cell;
    switch ((LSConversationDetailTableSection)indexPath.section) {
        case LSConversationDetailTableSectionMetadata: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:LSInputCellIdentifier];
            [(LSInputTableViewCell *)cell textField].delegate = self;
            [(LSInputTableViewCell *)cell setGuideText:@"Name:"];
            if ([self.conversation.metadata valueForKey:LSConversationMetadataNameKey]) {
                [[(LSInputTableViewCell *)cell textField] setText:[self.conversation.metadata valueForKey:LSConversationMetadataNameKey]];
            } else {
                [(LSInputTableViewCell *)cell setPlaceHolderText:@"Enter Conversation Name"];
            }
        }
            break;
        case LSConversationDetailTableSectionParticipants:
            if (indexPath.row < self.participantIdentifiers.count) {
                NSString *participantIdentifier = [self.participantIdentifiers objectAtIndex:indexPath.row];
                id<LYRUIParticipant>participant = [self.detailDataSource conversationDetailViewController:self participantForIdentifier:participantIdentifier];
                UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LSParticipantCellIdentifier forIndexPath:indexPath];
                [participantCell presentParticipant:participant withSortType:LYRUIParticipantPickerSortTypeFirstName shouldShowAvatarImage:YES];
                cell = participantCell;
            } else {
                cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = @"+ Add Participant";
                cell.textLabel.textColor = LYRUIBlueColor();
                cell.textLabel.font = LYRUIMediumFont(14);
            }
            break;
            
        case LSConversationDetailTableSectionLocation: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Share My Location";
            cell.textLabel.textColor = LYRUIBlueColor();
            cell.textLabel.font = LYRUIMediumFont(14);
        }
            break;
            
        case LSConversationDetailTableSectionDeletion: {
            LSCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LSCenterContentCellIdentifier];
            [centerCell setCenterText:@"Global Delete Conversation"];
            centerCell.centerTextLabel.textColor = LYRUIRedColor();
            return centerCell;
        }
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSConversationDetailTableSection)section) {
        case LSConversationDetailTableSectionMetadata:
            return @"Conversation Name";

        case LSConversationDetailTableSectionParticipants:
            return @"PARTICIPANTS";
            
        case LSConversationDetailTableSectionLocation:
            return @"LOCATION";
            
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((LSConversationDetailTableSection)indexPath.section) {
        case LSConversationDetailTableSectionParticipants:
            if (indexPath.row == self.participantIdentifiers.count) {
                self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
                self.participantPickerDataSource.excludedIdentifiers = self.conversation.participants;
                LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                                        sortType:LYRUIParticipantPickerSortTypeFirstName];
                controller.participantPickerDelegate = self;
                controller.allowsMultipleSelection = YES;
                [self presentViewController:controller animated:YES completion:nil];
            }
            break;
            
        case LSConversationDetailTableSectionLocation:
            [self startLocationManager];
            break;
        
        case LSConversationDetailTableSectionDeletion:
            [self.conversation delete:LYRDeletionModeAllParticipants error:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        default:
            break;
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
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.participantIdentifiers removeObjectAtIndex:indexPath.row];
        [self setConversationForParticipants:[NSSet setWithArray:self.participantIdentifiers]];
    }
}

#pragma mark - Location Manager Methods

- (void)startLocationManager
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (manager != self.locationManager) return;

    self.locationManager = nil;
    [manager stopUpdatingLocation];
    [self.detailDelegate conversationDetailViewController:self didShareLocation:locations.lastObject];
}

#pragma Participant Picker Delegate Methods

- (void)participantPickerControllerDidCancel:(LYRUIParticipantPickerController *)participantPickerController
{
    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    NSMutableSet *participants = [self.conversation.participants mutableCopy];
    [participants addObject:participant.participantIdentifier];
    [self setConversationForParticipants:participants];

    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setConversationForParticipants:(NSSet *)participants
{
    LYRConversation *conversation = [self.applicationController.layerClient conversationForParticipants:participants];
    if (!conversation) {
        conversation = [self.applicationController.layerClient newConversationWithParticipants:participants options:nil error:nil];
    }
    [self.detailDelegate conversationDetailViewController:self didChangeConversation:conversation];
    self.conversation = conversation;
    [self configureForConversation];
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text) {
        [self.conversation setValue:textField.text forMetadataAtKeyPath:LSConversationMetadataNameKey];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma Cell Appearance Configuration

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:LYRUIMediumFont(14)];
    [[LYRUIParticipantTableViewCell appearance] setBoldTitleFont:[UIFont systemFontOfSize:14]];
}

#pragma mark - Helpers

- (void)configureForConversation
{
    self.participantIdentifiers = [self.conversation.participants.allObjects mutableCopy];
    [self.participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
}

@end


