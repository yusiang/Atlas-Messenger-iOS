//
//  LSConversationDetailViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIParticipant.h"
#import "LSApplicationController.h"
#import <CoreLocation/CoreLocation.h>

extern NSString *const LYRUIConversationNameTag;

@class LSConversationDetailViewController;

/**
 @abstract The `LSConversationDetailViewControllerDelegate` notifies its receiver of events that occur within the controller.
 */
@protocol LSConversationDetailViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that a user has elected to share the application's current location.
 @param conversationDetailViewController The `LSConversationDetailViewController` in which the selection occurred.
 @param location The `CLLocation` object representing the application's current location.
 */
- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didShareLocation:(CLLocation *)location;

/**
 @abstract Informs the delegate that a user has elected to switch the conversation.
 @param conversationDetailViewController The `LSConversationDetailViewController` in which the selection occurred.
 @param conversation The new `LYRConversation` object.
 @discussion The user changes the `LYRConversation` object in response to adding or deleting participants from a conversation. 
 If the user mutates the participant list, the application checks to see if a Layer conversation exists with the new participant
 list. If one exists, it is provided. If not, a new conversation object is created and provided.
 */
- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation;

@end

/**
 @abstract The `LSConversationDetailViewControllerDataSource` supplies information to be displayed within the controller.
 */
@protocol LSConversationDetailViewControllerDataSource <NSObject>

/**
 @abstract Requests an object conforming to `LYRUIParticipant` for a given identifier.
 @param conversationDetailViewController The `LSConversationDetailViewController` requesting the object.
 @param participantIdentifier An `NSString` object representing a participant.
 */
- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier;

@end

/**
 @abstract The `LSConversationDetailViewController` presents a user interface that displays information about a given
 conversation. It also provides for adding/removing participants to/from a conversation and sharing the user's location.
 */
@interface LSConversationDetailViewController : UITableViewController

///-------------------------------
/// @name Designated Initializer
///-------------------------------

+(instancetype)conversationDetailViewControllerLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

/**
 @abstract The `LSConversationDetailViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<LSConversationDetailViewControllerDelegate> detailDelegate;

/**
 @abstract The `LSConversationDetailViewControllerDataSource` object for the controller.
 */
@property (nonatomic) id<LSConversationDetailViewControllerDataSource> detailsDataSource;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

@end
