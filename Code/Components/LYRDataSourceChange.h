//
//  LYRDataSourceChange.h
//  LayerSample
//
//  Created by Zac White on 8/13/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An enum that defines the change type.
 */
typedef NS_ENUM(NSInteger, LYRDataSourceChangeType) {
    /**
     *  The item was inserted. The `newIndex` will be the index in which it was inserted.
     */
    LYRDataSourceChangeTypeInsert,
    /**
     *  The item was moved from `oldIndex` to `newIndex`.
     */
    LYRDataSourceChangeTypeMove,
    /**
     *  The item was updated.
     */
    LYRDataSourceChangeTypeUpdate,
    /**
     *  The item was deleted.
     */
    LYRDataSourceChangeTypeDelete,
    /**
     *  All items were deleted.
     */
    LYRDataSourceChangeTypeTruncate,
};

@interface LYRDataSourceChange : NSObject

@property (readonly, nonatomic) LYRDataSourceChangeType type;
@property (readonly, nonatomic) NSInteger newIndex;
@property (readonly, nonatomic) NSInteger oldIndex;

+ (instancetype)insertChangeWithIndex:(NSInteger)index;
+ (instancetype)updateChangeWithIndex:(NSInteger)index;
+ (instancetype)moveChangeWithOldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex;
+ (instancetype)deleteChangeWithIndex:(NSInteger)index;
+ (instancetype)truncateChange;

@end
