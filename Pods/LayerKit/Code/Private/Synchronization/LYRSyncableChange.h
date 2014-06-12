//
//  LYRSyncableChange.h
//  LayerKit
//
//  Created by Klemen Verdnik on 07/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LYRSyncableChangeType) {
    LYRSyncableChangeTypeInsert = 0,
    LYRSyncableChangeTypeUpdate = 1,
    LYRSyncableChangeTypeDelete = 2,
};

extern NSString *const LYRSyncableChangeTableNameConversations;
extern NSString *const LYRSyncableChangeTableNameConversationParticipants;
extern NSString *const LYRSyncableChangeTableNameMessages;
extern NSString *const LYRSyncableChangeTableNameValues;
extern NSString *const LYRSyncableChangeTableNameKeyedValues;

@interface LYRSyncableChange : NSObject

@property (nonatomic, readonly) LYRSequence changeIdentifier;
@property (nonatomic, readonly) NSString *tableName;
@property (nonatomic, readonly) LYRSequence rowIdentifier;
@property (nonatomic, readonly) LYRSyncableChangeType changeType;
@property (nonatomic, readonly) NSString *columnName;

+ (id)syncableChangeWithChangeID:(LYRSequence)changeID tableName:(NSString *)tableName rowID:(LYRSequence)rowID changeType:(LYRSyncableChangeType)changeType columnName:(NSString *)columnName;

@end
