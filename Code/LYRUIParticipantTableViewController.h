//
//  LYRUIParticipantListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantTableViewCell.h"

@class LYRUIParticipantTableViewController;

@protocol LYRUIParticipantTableViewControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the user has selected a set of participants from a participant selection view.
 @param participantSelectionViewController The participant selection view in which the selection was made.
 @param participants The set of participants that was selected.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant;

/**
 *  Informs the data source that a search has been made with the following search string. After the completion block is called, the `contactListViewController:presenterForContactAtIndex:` method will be called for each search result.
 *
 *  @param contactListViewController An object representing the contact list view controller.
 *  @param searchString              The search string that was just used for search.
 *  @param completion                The completion block that should be called when the results are fetched from the search.
 */

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSDictionary *filteredParticipants))completion;

- (void)participantTableViewControllerDidSelectCancelButton;

- (void)participantTableViewControllerDidSelectDoneButton;
@end

@interface LYRUIParticipantTableViewController : UITableViewController

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> participantCellClass;

@property (nonatomic, weak) id<LYRUIParticipantTableViewControllerDelegate>delegate;

@property (nonatomic, strong) NSDictionary *participants;

@end
