//
//  ATLMConversationInterfaceController.m
//  Pods
//
//  Created by Kevin Coleman on 6/3/15.
//
//

#import "ATLMConversationInterfaceController.h"
#import "ATLMMessagingDataSource.h"
#import "ATLMPersistenceManager.h"
#import "ATLMApplicationController.h"
#import "ATLMConstants.h"

@interface ATLMConversationInterfaceController () <ATLConversationInterfaceControllerDelegate, ATLConversationInterfaceControllerDataSource>

@property (nonatomic) ATLMMessagingDataSource *messagingDataSource;

@end

@implementation ATLMConversationInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    self.dataSource = self;
    self.delegate = self;
    
    ATLMApplicationController *applicationController = context[ATLMApplicationControllerKey];
    self.messagingDataSource = [ATLMMessagingDataSource dataSourceWithPersistenceManager:applicationController.persistenceManager];
    
    [self configureConversationViewController];
}

#pragma mark - Conversation Interface Controller Delegate

- (void)conversationInterfaceController:(ATLConversationInterfaceController *)viewController didSendMessage:(LYRMessage *)message
{
    
}

- (void)conversationInterfaceController:(ATLConversationInterfaceController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error
{
    
}

- (void)conversationInterfaceController:(ATLConversationInterfaceController *)viewController didSelectMessage:(LYRMessage *)message
{
    
}

- (NSOrderedSet *)conversationInterfaceController:(ATLConversationInterfaceController *)viewController messagesForMediaAttachments:(NSArray *)mediaAttachments
{
    return nil;
}

#pragma mark - Conversation Interface Controller Data Source

- (id<ATLParticipant>)conversationInterfaceController:(ATLConversationInterfaceController *)conversationInterfaceController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.messagingDataSource participantForIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationInterfaceController:(ATLConversationInterfaceController *)conversationInterfaceController attributedStringForDisplayOfDate:(NSDate *)date
{
    return [self.messagingDataSource attributedStringForDisplayOfDate:date];
}

- (NSAttributedString *)conversationInterfaceController:(ATLConversationInterfaceController *)conversationInterfaceController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    return [self.messagingDataSource attributedStringForDisplayOfRecipientStatus:recipientStatus];
}


@end
