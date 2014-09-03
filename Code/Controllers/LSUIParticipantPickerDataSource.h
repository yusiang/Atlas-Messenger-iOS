//
//  LSUIParticipantPickerDataSource.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipantPickerController.h"
#import "LSPersistenceManager.h"

@interface LSUIParticipantPickerDataSource : NSObject <LYRUIParticipantPickerDataSource>

+ (instancetype)participantPickerDataSourceWithPersistenceManager:(LSPersistenceManager *)persistenceManager;

@end
