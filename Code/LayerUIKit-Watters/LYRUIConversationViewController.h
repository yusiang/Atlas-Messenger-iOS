//
//  LYRUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIParticipant.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIComposeViewController.h"

/**
 Required Reading:
 * https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS
 * http://www.objc.io/issue-3/collection-view-layouts.html
 * https://github.com/objcio/issue-3-collection-view-layouts
 * http://skeuo.com/uicollectionview-custom-layout-tutorial
 */


@class LYRUIConversationViewController;

@protocol LYRUIConversationViewControllerDataSource <NSObject>


- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier;

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date;

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;

@end

/**
 Expectations:
 * Uses collection view
 * Messages are grouped into sections by time. When a new time period is encountered you create a section. I'm guessing we use intervals of like 15-30 mins (maybe configurable)
 */
@interface LYRUIConversationViewController : UIViewController

+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;

@property (nonatomic, weak) id<LYRUIConversationViewControllerDataSource> dataSource;
@property (nonatomic, strong) LYRUIComposeViewController *composeViewController;
@property (nonatomic, assign) BOOL allowsEditing;

@end


