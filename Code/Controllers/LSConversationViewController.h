//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSPersistenceManager.h"


///---------------------
/// @name Object Changes
///---------------------

/**
 The Layer client provides a flexible notification system for informing applications when changes have
 occured on domain objects in response to synchronization activities. The system is designed to be general
 purpose and models changes as the creation, update, or deletion of an object. Changes are modeled as simple
 dictionaries with a fixed key space that is defined below.
 */

/**
 @abstract Defines the types of changes that can occur for an object.
 */
typedef NS_ENUM(NSInteger, LYRObjectChangeType) {
    LYRObjectChangeTypeCreate,  // Object was newly created on the device.
    LYRObjectChangeTypeUpdate,  // A property has changed.
    LYRObjectChangeTypeDelete,  // Object has been deleted.
};

/**
 @abstract A key into a change dictionary describing the change type. @see `LYRObjectChangeType` for possible types.
 */
NSString *const LYRObjectChangeTypeKey; // Expect values defined in the enum `LYRObjectChangeType` as `NSNumber` integer values.

/**
 @abstract A key into a change dictionary for the object that was created, updated, or deleted.
 */
NSString *const LYRObjectChangeObjectKey; // The `LYRConversation` or `LYRMessage` that changed.

// Only applicable to `LYRObjectChangeTypeUpdate`
NSString *const LYRObjectChangePropertyNameKey; // i.e. participants, metadata, userInfo, index
NSString *const LYRObjectChangeOldValueKey; // The value before synchronization
NSString *const LYRObjectChangeNewValueKey; // The value after synchronization

///---------------------------
/// @name Change Notifications
///---------------------------

/**
 @abstract Posted when the objects for a client have changed due to synchronization activities.
 @discussion The object for the notification is the `LYRClient`
 */
NSString *const LYRClientObjectsDidChangeNotification;
NSString *const LYRClientObjectChangesUserInfoKey; // key into the `userInfo` of a `LYRClientObjectsDidChangeNotification` notification

///------------------------------
/// @name Client Change Reporting
///------------------------------


@interface LSConversationViewController : UIViewController

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) LSPersistenceManager *persistanceManager;

@end
