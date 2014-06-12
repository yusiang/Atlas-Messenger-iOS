//
//  LYRUUIDData.h
//  LayerKit
//
//  Created by Klemen Verdnik on 18/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Converts an @c NSUUID object into a binary @c NSData format.

 @param UUID A @c NSUUID formatted UUID to be converted in an @c NSData format.
 @return The data converted in the @c NSData format or `nil` if it could not be converted.
 */
NSData *LYRDataFromUUID(NSUUID *UUID);

/**
 Converts an @c NSData representation of UUID into a native @c NSUUID format.

 @param data A @c NSData formatted UUID to be converted in an @c NSUUID format.
 @return The UUID converted in the @c NSUUID format or `nil` if it could not be converted.
 */
NSUUID *LYRUUIDFromData(NSData *data);
