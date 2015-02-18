//
//  ATLMConversationDetailViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import <Atlas/Atlas.h>
#import "ATLMApplicationController.h"
#import <CoreLocation/CoreLocation.h>

extern NSString *const ATLMConversationMetadataNameKey;

@class ATLMConversationDetailViewController;

/**
 @abstract The `ATLMConversationDetailViewControllerDelegate` notifies its receiver of events that occur within the controller.
 */
@protocol ATLMConversationDetailViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that a user has elected to share the application's current location.
 @param conversationDetailViewController The `ATLMConversationDetailViewController` in which the selection occurred.
 */
- (void)conversationDetailViewControllerDidSelectShareLocation:(ATLMConversationDetailViewController *)conversationDetailViewController;

/**
 @abstract Informs the delegate that a user has elected to switch the conversation.
 @param conversationDetailViewController The `ATLMConversationDetailViewController` in which the selection occurred.
 @param conversation The new `LYRConversation` object.
 @discussion The user changes the `LYRConversation` object in response to adding or deleting participants from a conversation. 
 If the user mutates the participant list, the application checks to see if a Layer conversation exists with the new participant
 list. If one exists, it is provided. If not, a new conversation object is created and provided.
 */
- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation;

@end

/**
 @abstract The `ATLMConversationDetailViewControllerDataSource` supplies information to be displayed within the controller.
 */
@protocol ATLMConversationDetailViewControllerDataSource <NSObject>

/**
 @abstract Requests an object conforming to `ATLMParticipant` for a given identifier.
 @param conversationDetailViewController The `ATLMConversationDetailViewController` requesting the object.
 @param participantIdentifier An `NSString` object representing a participant.
 */
- (id<ATLParticipant>)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier;

@end

/**
 @abstract The `ATLMConversationDetailViewController` presents a user interface that displays information about a given
 conversation. It also provides for adding/removing participants to/from a conversation and sharing the user's location.
 */
@interface ATLMConversationDetailViewController : UITableViewController

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+(instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation;

/**
 @abstract The `ATLMConversationDetailViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<ATLMConversationDetailViewControllerDelegate> detailDelegate;

/**
 @abstract The `ATLMConversationDetailViewControllerDataSource` object for the controller.
 */
@property (nonatomic) id<ATLMConversationDetailViewControllerDataSource> detailDataSource;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMApplicationController *applicationController;

/**
 @abstract Boolean value that determines whether adding/removing participants affects the conversation itself (`YES`) or switches to a different conversation (`NO`).
 */
@property (nonatomic) BOOL changingParticipantsMutatesConversation;

@end
