//
//  LYRUUIDData.m
//  LayerKit
//
//  Created by Klemen Verdnik on 18/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRUUIDData.h"

NSData *LYRDataFromUUID(NSUUID *UUID)
{
    uint8_t UUIDBytes[16];
    [UUID getUUIDBytes:UUIDBytes];
    return [NSData dataWithBytes:UUIDBytes length:sizeof(UUIDBytes)];
}

NSUUID *LYRUUIDFromData(NSData *data)
{
    uint8_t UUIDBytes[16];
    [data getBytes:UUIDBytes length:sizeof(UUIDBytes)];
    return [[NSUUID alloc] initWithUUIDBytes:UUIDBytes];
}
