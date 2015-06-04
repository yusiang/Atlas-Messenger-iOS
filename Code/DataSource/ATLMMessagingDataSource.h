//
//  ATLMConversationDataSouce.h
//  Pods
//
//  Created by Kevin Coleman on 6/3/15.
//
//

#import <Foundation/Foundation.h>
#import "ATLConversationViewController.h"
#import "ATLMPersistenceManager.h"

@interface ATLMMessagingDataSource : NSObject

+ (instancetype)dataSourceWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager;

- (NSString *)cellTitleForConversation:(LYRConversation *)conversation;

- (NSString *)titleForConversation:(LYRConversation *)conversation;

- (id<ATLParticipant>)participantForIdentifier:(NSString *)identifier;

- (NSAttributedString *)attributedStringForDisplayOfDate:(NSDate *)date;

- (NSAttributedString *)attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;

@end
 