//
//  LYRSyncableChange.m
//  LayerKit
//
//  Created by Klemen Verdnik on 07/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRSyncableChange.h"

NSString *const LYRSyncableChangeTableNameConversations = @"conversations";
NSString *const LYRSyncableChangeTableNameConversationParticipants = @"conversation_participants";
NSString *const LYRSyncableChangeTableNameMessages = @"messages";
NSString *const LYRSyncableChangeTableNameValues = @"values";
NSString *const LYRSyncableChangeTableNameKeyedValues = @"keyed_values";

@interface LYRSyncableChange ()

@property (nonatomic) LYRSequence changeIdentifier;
@property (nonatomic) NSString *tableName;
@property (nonatomic) LYRSequence rowIdentifier;
@property (nonatomic) LYRSyncableChangeType changeType;
@property (nonatomic) NSString *columnName;

@end

@implementation LYRSyncableChange

- (id)init
{
    self = [super init];
    if (self) {
        self.changeIdentifier = LYRSequenceNotDefined;
        self.rowIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)initWithChangeID:(LYRSequence)changeID tableName:(NSString *)tableName rowID:(LYRSequence)rowID changeType:(LYRSyncableChangeType)changeType columnName:(NSString *)columnName
{
    self = [super init];
    if (self) {
        self.changeIdentifier = changeID;
        self.tableName = tableName;
        self.rowIdentifier = rowID;
        self.changeType = changeType;
        self.columnName = columnName;
    }
    return self;
}

+ (id)syncableChangeWithChangeID:(LYRSequence)changeID tableName:(NSString *)tableName rowID:(LYRSequence)rowID changeType:(LYRSyncableChangeType)changeType columnName:(NSString *)columnName
{
    return [[[self class] alloc] initWithChangeID:changeID tableName:tableName rowID:rowID changeType:changeType columnName:columnName];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRSyncableChange class]]) return NO;
    if (self == object) return YES;

    LYRSyncableChange *obj = object;

    BOOL isChangeIDEqual = self.changeIdentifier == obj.changeIdentifier;
    BOOL isTableNameEqual = self.tableName == obj.tableName || [self.tableName isEqualToString:obj.tableName];
    BOOL isRowIDEqual = self.rowIdentifier == obj.rowIdentifier;
    BOOL isChangeTypeEqual = self.changeType == obj.changeType;
    BOOL isColumnNameEqual = self.columnName == obj.columnName || [self.columnName isEqualToString:obj.columnName];

    return isChangeIDEqual &&
           isTableNameEqual &&
           isRowIDEqual &&
           isChangeTypeEqual &&
           isColumnNameEqual;
}

- (NSUInteger)hash
{
    return (NSUInteger)self.changeIdentifier ^ self.tableName.hash ^ (NSUInteger)self.rowIdentifier ^ (NSUInteger)self.changeType ^ self.columnName.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %lx> changeID:%u tableName:'%@' rowID:%u changeType:%@ columnName:'%@'", [self class], (unsigned long)self, self.changeIdentifier, self.tableName, self.rowIdentifier, self.changeType == LYRSyncableChangeTypeInsert ? @"LYRSyncableChangeTypeInsert" : self.changeType == LYRSyncableChangeTypeUpdate ? @"LYRSyncableChangeTypeUpdate" : @"LYRSyncableChangeTypeDelete", self.columnName];
}

@end
