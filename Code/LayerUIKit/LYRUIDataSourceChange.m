//
//  LYRUIDataSourceChange.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIDataSourceChange.h"

@interface LYRUIDataSourceChange ()

@end

@implementation LYRUIDataSourceChange

+ (instancetype)changeWithType:(LYRUIDataSourceChangeType)type newIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex
{
    return [[self alloc] initWithChangeType:type newIndex:newIndex oldIndex:oldIndex];
}

- (id)initWithChangeType:(LYRUIDataSourceChangeType)type newIndex:(NSUInteger)newIndex oldIndex:(NSUInteger)oldIndex
{
    self = [super init];
    if (self) {
        
        _type = type;
        _newIndex = newIndex;
        oldIndex = oldIndex;
        
    }
    return self;
}

+ (instancetype)insertChangeWithIndex:(NSInteger)index
{
    return [LYRUIDataSourceChange changeWithType:LYRUIDataSourceChangeTypeInsert newIndex:index oldIndex:0];
}

+ (instancetype)updateChangeWithIndex:(NSInteger)index
{
    return [LYRUIDataSourceChange changeWithType:LYRUIDataSourceChangeTypeUpdate newIndex:index oldIndex:0];
}

+ (instancetype)moveChangeWithOldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex
{
    return [LYRUIDataSourceChange changeWithType:LYRUIDataSourceChangeTypeMove newIndex:newIndex oldIndex:oldIndex];
}

+ (instancetype)deleteChangeWithIndex:(NSInteger)index
{
    return [LYRUIDataSourceChange changeWithType:LYRUIDataSourceChangeTypeDelete newIndex:index oldIndex:0];
}

+ (instancetype)deleteAllChange
{
    return [LYRUIDataSourceChange changeWithType:LYRUIDataSourceChangeTypeDeleteAll newIndex:0 oldIndex:0];
}

- (NSString *)description
{
    NSString *stringChangeType = [NSString new];
    if (self.type == LYRUIDataSourceChangeTypeInsert) {
        stringChangeType = @"insert";
    } else if (self.type == LYRUIDataSourceChangeTypeUpdate) {
        stringChangeType = @"update";
    } else if (self.type == LYRUIDataSourceChangeTypeDelete) {
        stringChangeType = @"delete";
    } else if (self.type == LYRUIDataSourceChangeTypeMove) {
        stringChangeType = @"move";
    } else if (self.type == LYRUIDataSourceChangeTypeDeleteAll) {
        stringChangeType = @"truncate";
    }
    return [NSString stringWithFormat:@"<%@:%p type:%@ index:%ld oldIndex:%ld>", self.class, self, stringChangeType, (long)self.newIndex, (long)self.oldIndex];
}

@end
