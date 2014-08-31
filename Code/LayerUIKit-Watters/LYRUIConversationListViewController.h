//
//  LYRUIConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIConversationTableViewCell.h"

@class LYRUIConversationListViewController;

@protocol LYRUIConversationListViewControllerDelegate <NSObject>

/**
 @abstract Tells the delegate that a conversation was selected from a conversation list.
 @param conversationListViewController The conversation list in which the selection occurred.
 @param conversation The conversation that was selected.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation;

//TODO Discuss if this is necessary
/**
 @abstract Tells the delegate that the conversation list was dismissed without making a selection.
 @param conversationListViewController The conversation list that was dismissed.
 */
- (void)conversationListViewControllerDidCancel:(LYRUIConversationListViewController *)conversationListViewController;

/**
 @abstract Asks the delegate for the Conversation Label for a given set of participants in a conversation.
 @param participants The identifiers for participants in a conversation within the conversation list.
 @param conversationListViewController The conversation list in which the participant appears.
 @return The conversation label to be displayed for a given conversation in the conversation list.
 */
- (NSString *)conversationLabelForParticipants:(NSSet *)participants inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController;

@end

/**
 @abstract The `LYRUIConversationListViewController` class presents an interface allowing
 for the display, selection, and searching of Layer conversations.
 */
@interface LYRUIConversationListViewController : UITableViewController

///---------------------------------------
/// @name Initializing a Conversation List
///---------------------------------------

/**
 @abstract Creates and returns a new conversation list initialized with the given Layer client.
 @param layerClient The Layer client from which to retrieve the conversations for display.
 @return A new conversation list controller.
 */
+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient;

/**
 @abstract The delegate for the receiver.
 */
@property (nonatomic, weak) id<LYRUIConversationListViewControllerDelegate> delegate;

///----------------------------------------
/// @name Customizing the Conversation List
///----------------------------------------

/**
 @abstract A Boolean value that determines if editing is enabled.
 @discussion When `YES`, an Edit button item will be displayed on the left hand side of the
 receiver's navigation item that toggles the editing state of the receiver.
 @default `YES`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL allowsEditing;

/**
 @abstract The table view cell class for customizing the display of the conversations.
 @default `[LYRUIConversationTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIConversationPresenting> cellClass;

/**
 @abstract Sets the height for cells within the receiver.
 @default `80.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

@end
