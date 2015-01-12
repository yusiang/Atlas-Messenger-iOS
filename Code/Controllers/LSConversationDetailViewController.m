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

@interface LSConversationDetailViewController () <LYRUIParticipantPickerControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *participantIdentifiers;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;
@property (nonatomic) BOOL locationShared;
@property (nonatomic) BOOL authenticatedUserIsConversationMember;

@end

@implementation LSConversationDetailViewController

NSString *const LSConversationMetadataNameKey = @"conversationName";
static NSString *const LSParticipantCellIdentifier = @"participantCell";
static NSString *const LSDefaultCellIdentifier = @"defaultCellIdentifier";
static NSString *const LSInputCellIdentifier = @"inputCell";
static NSString *const LSCenterContentCellIdentifier = @"centerContentCellIdentifier";

+ (instancetype)conversationDetailViewControllerLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    return [[self alloc] initWithLayerClient:layerClient conversation:conversation];
}

- (id)initWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _layerClient = layerClient;
        _conversation = conversation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureForConversation];
    
    //VC Title
    self.title = @"Details";
    self.accessibilityLabel = @"Details";
    
    // Table View Setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0.0f;
    
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LSCenterContentCellIdentifier];
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LSParticipantCellIdentifier];
    [self.tableView registerClass:[LSInputTableViewCell  class] forCellReuseIdentifier:LSInputCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSDefaultCellIdentifier];
   
    // Setup UI
    [self configureAppearance];
    
    self.locationShared = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.authenticatedUserIsConversationMember) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            if (self.authenticatedUserIsConversationMember){
                return self.participantIdentifiers.count + 1;
            } else {
                return self.participantIdentifiers.count;
            }
            break;
            
        case 2:
            return 1;
            break;
            
        case 3:
            return 1;
            break;
            
        default:
            break;
            
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0: {
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
        case 1:
            if (indexPath.row > self.participantIdentifiers.count - 1 ) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = @"+ Add Participant";
                cell.textLabel.textColor = LYRUIBlueColor();
                cell.textLabel.font = LYRUIMediumFont(14);
            } else {
                NSString *participantIdentifier = [self.participantIdentifiers objectAtIndex:indexPath.row];
                id<LYRUIParticipant>participant = [self.detailDataSource conversationDetailViewController:self participantForIdentifier:participantIdentifier];
                UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LSParticipantCellIdentifier forIndexPath:indexPath];
                [participantCell presentParticipant:participant withSortType:LYRUIParticipantPickerSortTypeFirstName shouldShowAvatarImage:YES];
                cell = participantCell;
            }
            break;
            
        case 2: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:LSDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Share My Location";
            cell.textLabel.textColor = LYRUIBlueColor();
            cell.textLabel.font = LYRUIMediumFont(14);
        }
            break;
            
        case 3: {
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Conversation Name";
            break;

        case 1:
            return @"PARTICIPANTS";
            break;
            
        case 2:
            return @"LOCATION";
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
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
            
        case 2:
            [self startLocationManager];
            break;
        
        case 3:
            [self.conversation delete:LYRDeletionModeAllParticipants error:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    if (!self.locationShared) {
        self.locationShared = YES;
        [self.detailDelegate conversationDetailViewController:self didShareLocation:[locations lastObject]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

#pragma Participant Picker Delegate Methods

- (void)participantPickerControllerDidCancel:(LYRUIParticipantPickerController *)participantPickerController
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSMutableSet *participants = [self.conversation.participants mutableCopy];
        [participants addObject:participant.participantIdentifier];
        [self setConversationForParticipants:participants];
    }];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text) {
        [self.conversation setValue:textField.text forMetadataAtKeyPath:LSConversationMetadataNameKey];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Setup metadata here
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
    if ([self.participantIdentifiers containsObject:self.layerClient.authenticatedUserID]) {
        self.authenticatedUserIsConversationMember = YES;
    } else {
        [self.participantIdentifiers addObject:self.layerClient.authenticatedUserID];
        self.authenticatedUserIsConversationMember = NO;
    }
}

@end


