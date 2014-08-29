//
//  LSConversationListTVC.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationListTVC.h"

@implementation LSConversationListTVC

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    // Dont Care
}

- (void)conversationListViewControllerDidCancel:(LYRUIConversationListViewController *)conversationListViewController
{
    //Dont Care
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participants inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController
{
    return @"Kevin Coleman, Blake Watters";
}

@end
