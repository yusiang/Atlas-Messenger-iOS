//
//  ATLMConversationListInterfaceController.m
//  Pods
//
//  Created by Kevin Coleman on 6/3/15.
//
//

#import "ATLMConversationListInterfaceController.h"
#import "ATLMApplicationController.h"
#import "ATLMMessagingDataSource.h"
#import "ATLMConstants.h"

@interface ATLMConversationListInterfaceController () <ATLConversationListInterfaceControllerDataSource, ATLConversationListInterfaceControllerDelegate>

@property (nonatomic) ATLMPersistenceManager *persistenceManager;
@property (nonatomic) ATLMApplicationController *applicationController;
@property (nonatomic) ATLMMessagingDataSource *messagingDataSource;

@end

@implementation ATLMConversationListInterfaceController

- (void)awakeWithContext:(id)context
{
    self.delegate = self;
    self.dataSource = self;
    
    [super awakeWithContext:context];
    
    ATLMApplicationController *applicationController = context[ATLMApplicationControllerKey];
    self.applicationController = applicationController;
    self.messagingDataSource = [ATLMMessagingDataSource dataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    [self configureConversationListController];
}

- (void)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController didSelectConversation:(LYRConversation *)conversation
{
    [self pushControllerWithName:@"conversationController" context:@{ ATLMApplicationControllerKey: self.applicationController, ATLLayerClientKey : self.layerClient, ATLLayerConversationKey : conversation }];
}


- (NSString *)conversationListInterfaceController:(ATLConversationListInterfaceController *)conversationListInterfaceController titleForConversation:(LYRConversation *)conversation
{
    return  [self.messagingDataSource cellTitleForConversation:conversation];
}

@end
