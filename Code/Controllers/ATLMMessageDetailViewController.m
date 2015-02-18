//
//  ATLMMessageDetailViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMMessageDetailViewController.h"
#import "ATLMStyleValue1TableViewCell.h"

typedef NS_ENUM(NSInteger, ATLMMessageDetailTableSection) {
    ATLMMessageDetailTableSectionMetadata,
    ATLMMessageDetailTableSectionRecipientStatus,
    ATLMMessageDetailTableSectionCount,
};

typedef NS_ENUM(NSInteger, ATLMMessageMetadataTableRow) {
    ATLMMessageMetadataTableRowParts,
    ATLMMessageMetadataTableRowSentAt,
    ATLMMessageMetadataTableRowReceivedAt,
    ATLMMessageMetadataTableRowIsSent,
    ATLMMessageMetadataTableRowIsDeleted,
    ATLMMessageMetadataTableRowSentBy,
    ATLMMessageMetadataTableRowCount,
};

@interface ATLMMessageDetailViewController ()

@property (nonatomic) ATLMApplicationController *applicationController;
@property (nonatomic) LYRMessage *message;
@property (nonatomic) NSArray *recipientUserIDs;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ATLMMessageDetailViewController

NSString *const ATLMMessageDetailViewControllerAccessibilityLabel = @"Message Detail View Controller";
NSString *const ATLMMessageDetailViewControllerTitle = @"Message Detail";
static NSString *const ATLMMessageDetailCellIdentifier = @"messageDetailCell";

+ (instancetype)messageDetailViewControllerWithMessage:(LYRMessage *)message applicationController:(ATLMApplicationController *)applicationController;
{
    return [[self alloc] initWithMessage:message applicationController:applicationController];
}

- (id)initWithMessage:(LYRMessage *)message applicationController:(ATLMApplicationController *)applicationController
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
    
    self.title = ATLMMessageDetailViewControllerTitle;
    self.accessibilityLabel = ATLMMessageDetailViewControllerAccessibilityLabel;
    
    [self.tableView registerClass:[ATLMStyleValue1TableViewCell class] forCellReuseIdentifier:ATLMMessageDetailCellIdentifier];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTapped)];
    doneButton.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ATLMMessageDetailTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((ATLMMessageDetailTableSection)section) {
        case ATLMMessageDetailTableSectionMetadata:
            return ATLMMessageMetadataTableRowCount;
            
        case ATLMMessageDetailTableSectionRecipientStatus:
            return self.recipientUserIDs.count;
            
        case ATLMMessageDetailTableSectionCount:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATLMMessageDetailCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch ((ATLMMessageDetailTableSection)indexPath.section) {
        case ATLMMessageDetailTableSectionMetadata:
            switch ((ATLMMessageMetadataTableRow)indexPath.row) {
                case ATLMMessageMetadataTableRowParts:
                    cell.textLabel.text = [NSString stringWithFormat:@"Number of Parts:"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.message.parts.count];
                    break;

                case ATLMMessageMetadataTableRowSentAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent At:"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.message.sentAt];
                    break;
                
                case ATLMMessageMetadataTableRowReceivedAt:
                    cell.textLabel.text = [NSString stringWithFormat:@"Received At:"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.message.receivedAt];
                    break;
                    
                case ATLMMessageMetadataTableRowIsSent:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Sent:"];
                    cell.detailTextLabel.text = self.message.isSent ? @"Yes" : @"No";
                    break;
                    
                case ATLMMessageMetadataTableRowIsDeleted:
                    cell.textLabel.text = [NSString stringWithFormat:@"Is Deleted:"];
                    cell.detailTextLabel.text = self.message.isDeleted ? @"Yes" : @"No";
                    break;
                    
                case ATLMMessageMetadataTableRowSentBy:
                    cell.textLabel.text = [NSString stringWithFormat:@"Sent By:"];
                    cell.detailTextLabel.text = [self recipientNameForUserID:self.message.sentByUserID];
                    break;
                    
                case ATLMMessageMetadataTableRowCount:
                    break;
            }
            break;

        case ATLMMessageDetailTableSectionRecipientStatus:
            cell.textLabel.text = [self recipientNameForUserID:self.recipientUserIDs[indexPath.row]];
            cell.detailTextLabel.text = [self recipientStateForUserID:self.recipientUserIDs[indexPath.row]];
            break;

        case ATLMMessageDetailTableSectionCount:
            break;
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((ATLMMessageDetailTableSection)section) {
        case ATLMMessageDetailTableSectionMetadata:
            return @"Message Detail";
            
        case ATLMMessageDetailTableSectionRecipientStatus:
            return @"Recipient Status";

        case ATLMMessageDetailTableSectionCount:
            return nil;
    }
}

#pragma mark - Helpers

- (NSString *)recipientNameForUserID:(NSString *)userID
{
    ATLMUser *user = [self.applicationController.persistenceManager userForIdentifier:userID];
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
