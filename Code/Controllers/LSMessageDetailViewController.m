//
//  LSMessageDetailViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageDetailViewController.h"
#import "LSStyleValue1TableViewCell.h"

typedef NS_ENUM(NSInteger, LSMessageDetailTableSection) {
    LSMessageDetailTableSectionMetadata,
    LSMessageDetailTableSectionRecipientStatus,
    LSMessageDetailTableSectionCount,
};

typedef NS_ENUM(NSInteger, LSMessageMetadataTableRow) {
    LSMessageMetadataTableRowParts,
    LSMessageMetadataTableRowSentAt,
    LSMessageMetadataTableRowReceivedAt,
    LSMessageMetadataTableRowIsSent,
    LSMessageMetadataTableRowIsDeleted,
    LSMessageMetadataTableRowSentBy,
    LSMessageMetadataTableRowCount,
};

@interface LSMessageDetailViewController ()

@property (nonatomic) LSApplicationController *applicationController;
@property (nonatomic) LYRMessage *message;
@property (nonatomic) NSArray *recipientUserIDs;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LSMessageDetailViewController

NSString *const LSMessageDetailViewControllerAccessibilityLabel = @"Message Detail View Controller";
NSString *const LSMessageDetailViewControllerTitle = @"Message Detail";
static NSString *const LSMessageDetailCellIdentifier = @"messageDetailCell";

+ (instancetype)messageDetailViewControllerWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController;
{
    return [[self alloc] initWithMessage:message applicationController:applicationController];
}

- (id)initWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _applicationController = applicationController;
        _message = message;
        _recipientUserIDs = message.recipientStatusByUserID.allKeys;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.doesRelativeDateFormatting = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LSMessageDetailViewControllerTitle;
    self.accessibilityLabel = LSMessageDetailViewControllerAccessibilityLabel;
    
    [self.tableView registerClass:[LSStyleValue1TableViewCell class] forCellReuseIdentifier:LSMessageDetailCellIdentifier];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTapped)];
    doneButton.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LSMessageDetailTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((LSMessageDetailTableSection)section) {
        case LSMessageDetailTableSectionMetadata:
            return LSMessageMetadataTableRowCount;
            
        case LSMessageDetailTableSectionRecipientStatus:
            return self.recipientUserIDs.count;
            
        case LSMessageDetailTableSectionCount:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LSMessageDetailCellIdentifier];
    
    switch ((LSMessageDetailTableSection)indexPath.section) {
        case LSMessageDetailTableSectionMetadata:
            switch ((LSMessageMetadataTableRow)indexPath.row) {
                case LSMessageMetadataTableRowParts:
                    cell.textLabel.text = [NSString stringWithFormat:@"Number of Parts:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.message.parts.count];
                    break;

                case LSMessageMetadataTableRowSentAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent At:"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.message.sentAt];
                    break;
                
                case LSMessageMetadataTableRowReceivedAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Received At:"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.message.receivedAt];
                    break;
                    
                case LSMessageMetadataTableRowIsSent:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Sent:"];
                    cell.detailTextLabel.text = self.message.isSent ? @"Yes" : @"No";
                    break;
                    
                case LSMessageMetadataTableRowIsDeleted:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Deleted:"];
                    cell.detailTextLabel.text = self.message.isDeleted ? @"Yes" : @"No";
                    break;
                    
                case LSMessageMetadataTableRowSentBy:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent By:"];
                    cell.detailTextLabel.text = [self recipientNameForUserID:self.message.sentByUserID];
                    break;
                    
                case LSMessageMetadataTableRowCount:
                    break;
            }
            break;

        case LSMessageDetailTableSectionRecipientStatus:
            cell.textLabel.text = [self recipientNameForUserID:self.recipientUserIDs[indexPath.row]];
            cell.detailTextLabel.text = [self recipientStateForUserID:self.recipientUserIDs[indexPath.row]];
            break;

        case LSMessageDetailTableSectionCount:
            break;
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((LSMessageDetailTableSection)section) {
        case LSMessageDetailTableSectionMetadata:
            return @"Message Detail";
            
        case LSMessageDetailTableSectionRecipientStatus:
            return @"Recipient Status";

        case LSMessageDetailTableSectionCount:
            return nil;
    }
}

#pragma mark - Helpers

- (NSString *)recipientNameForUserID:(NSString *)userID
{
    LSUser *user = [self.applicationController.persistenceManager userForIdentifier:userID];
    return user.fullName;
}

- (NSString *)recipientStateForUserID:(NSString *)userID
{
    switch ([self.message recipientStatusForUserID:userID]) {
        case LYRRecipientStatusSent:
            return @"Sent";
            
        case LYRRecipientStatusDelivered:
            return @"Delivered";
            
        case LYRRecipientStatusRead:
            return @"Read";
            
        case LYRRecipientStatusInvalid:
            return @"Invalid";
            
        default:
            return nil;
    }
}

#pragma mark - Actions

- (void)doneButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
