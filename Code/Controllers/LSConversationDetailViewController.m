//
//  LYRUIConversationDetailViewController.m
//  Pods
//
//  Created by Kevin Coleman on 10/2/14.
//
//

#import "LSConversationDetailViewController.h"
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUISelectionIndicator.h"
#import "LYRUIParticipantPickerController.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LSUtilities.h"
#import "LYRUIConversationDataSource.h"
#import "LSDetailHeaderView.h"
#import "LYRUIAvatarImageView.h"
#import "LSCenterTextTableViewCell.h"

@interface LSConversationDetailViewController () <LYRUIParticipantPickerDataSource, LYRUIParticipantPickerControllerDelegate, LYRUIConversationDataSourceDelegate, CLLocationManagerDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *participantIdentifiers;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;

@end

@implementation LSConversationDetailViewController

@synthesize participants = _participants;

static NSString *const LYRUIParticipantCellIdentifier = @"participantCell";
static NSString *const LYRUIDefaultCellIdentifier = @"defaultCellIdentifier";
static NSString *const LYRUICenterContentCellIdentifier = @"centerContentCellIdentifier";

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
        _participantIdentifiers = [[conversation.participants allObjects] mutableCopy];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0.0f;
    
    [self.tableView registerClass:[LSCenterTextTableViewCell class] forCellReuseIdentifier:LYRUICenterContentCellIdentifier];
    [self.tableView registerClass:[LYRUIParticipantTableViewCell class] forCellReuseIdentifier:LYRUIParticipantCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LYRUIDefaultCellIdentifier];
    [self configureAppearance];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.participantIdentifiers.count + 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
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
        case 0:
            if (indexPath.row > self.conversation.participants.count - 1 ) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:LYRUIDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = @"+ Add Participant";
                cell.textLabel.textColor = LSBlueColor();
                cell.textLabel.font = LSMediumFont(14);
            } else {
                NSString *participantIdentifier = [self.participantIdentifiers objectAtIndex:indexPath.row];
                id<LYRUIParticipant>participant = [self.detailDelegate conversationDetailViewController:self participantForIdentifier:participantIdentifier];
                UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LYRUIParticipantCellIdentifier forIndexPath:indexPath];
                [participantCell presentParticipant:participant];
                [participantCell shouldDisplaySelectionIndicator:NO];
                [participantCell shouldShowAvatarImage:YES];
                cell = participantCell;
            }
            break;
        case 1: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:LYRUIDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Share Location";
            cell.textLabel.textColor = LSBlueColor();
            cell.textLabel.font = LSMediumFont(14);
        }
            break;
        case 2: {
            LSCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LYRUICenterContentCellIdentifier];
            [centerCell setCenterText:@"Global Delete Conversation"];
            centerCell.centerTextLabel.textColor = LSRedColor();
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
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [LSDetailHeaderView initWithTitle:@"PARTICIPANTS"];
            break;
        case 1:
            return [LSDetailHeaderView initWithTitle:@"LOCATION"];
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == self.participantIdentifiers.count) {
                LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                                        sortType:LYRUIParticipantPickerControllerSortTypeFirst];
                controller.participantPickerDelegate = self;
                controller.allowsMultipleSelection = YES;
                [self presentViewController:controller animated:YES completion:nil];
            }
            break;
        case 1: {
            NSError *error = [NSError errorWithDomain:@"Domain" code:100 userInfo:@{ NSLocalizedDescriptionKey : @"Feature Not Implemented"}];
            LSAlertWithError(error);
            //[self startLocationManager];
            break;
        }
        case 2:
            [self.applicationController.layerClient deleteConversation:self.conversation mode:LYRDeletionModeAllParticipants error:nil];
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
        NSString *particpantID = [self.participantIdentifiers objectAtIndex:indexPath.row];
        [self.participantIdentifiers removeObjectAtIndex:indexPath.row];
        [self.applicationController.layerClient removeParticipants:[NSSet setWithObject:particpantID] fromConversation:self.conversation error:nil];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Location Manager Methods

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    [self.detailDelegate conversationDetailViewController:self didShareLocation:[locations lastObject]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma Participant Picker Delegate Methods

- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSSet *participantIdentifiers = [participants valueForKey:@"userID"];
        NSError *error;
        [self.layerClient addParticipants:participantIdentifiers toConversation:self.conversation error:&error];
    }];
}

- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    completion(nil);
}

#pragma Cell Appearance Configuration

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:LSMediumFont(14)];
}


@end


