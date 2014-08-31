//
//  LYRDataSourceChange.m
//  LayerSample
//
//  Created by Zac White on 8/13/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRDataSourceChange.h"

@interface LYRDataSourceChange ()

@property (readwrite, nonatomic) LYRDataSourceChangeType type;
@property (readwrite, nonatomic) NSInteger newIndex;
@property (readwrite, nonatomic) NSInteger oldIndex;

@end

@implementation LYRDataSourceChange

+ (instancetype)changeWithType:(LYRDataSourceChangeType)type newIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex
{
    LYRDataSourceChange *change = [LYRDataSourceChange new];
    change.type = type;
    change.newIndex = newIndex;
    change.oldIndex = oldIndex;
    return change;
}

+ (instancetype)insertChangeWithIndex:(NSInteger)index
{
    return [LYRDataSourceChange changeWithType:LYRDataSourceChangeTypeInsert newIndex:index oldIndex:0];
}

+ (instancetype)updateChangeWithIndex:(NSInteger)index
{
    return [LYRDataSourceChange changeWithType:LYRDataSourceChangeTypeUpdate newIndex:index oldIndex:0];
}

+ (instancetype)moveChangeWithOldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex
{
    return [LYRDataSourceChange changeWithType:LYRDataSourceChangeTypeMove newIndex:newIndex oldIndex:oldIndex];
}

+ (instancetype)deleteChangeWithIndex:(NSInteger)index
{
    return [LYRDataSourceChange changeWithType:LYRDataSourceChangeTypeDelete newIndex:index oldIndex:0];
}

+ (instancetype)truncateChange
{
    return [LYRDataSourceChange changeWithType:LYRDataSourceChangeTypeTruncate newIndex:0 oldIndex:0];
}

- (NSString *)description
{
    NSString *stringChangeType;
    if (self.type == LYRDataSourceChangeTypeInsert) {
        stringChangeType = @"insert";
    } else if (self.type == LYRDataSourceChangeTypeUpdate) {
        stringChangeType = @"update";
    } else if (self.type == LYRDataSourceChangeTypeDelete) {
        stringChangeType = @"delete";
    } else if (self.type == LYRDataSourceChangeTypeMove) {
        stringChangeType = @"move";
    } else if (self.type == LYRDataSourceChangeTypeTruncate) {
        stringChangeType = @"truncate";
    }
    return [NSString stringWithFormat:@"<%@:%p type:%@ index:%ld oldIndex:%ld>", self.class, self, stringChangeType, (long)self.newIndex, (long)self.oldIndex];
}

@end
