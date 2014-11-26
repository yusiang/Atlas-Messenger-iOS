//
//  LSTestObserver.h
//  LayerSample
//
//  Created by Kevin Coleman on 11/15/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h> 

@class LSTestObserver;

@protocol LSTestObserverDelegate <NSObject>

- (void)testObserver:(LSTestObserver *)testObserver objectDidChange:(NSDictionary *)change;

@end

@interface LSTestObserver : NSObject

@property (nonatomic) id<LSTestObserverDelegate>delegate;

+ (instancetype)initWithClass:(Class)class changeType:(LYRObjectChangeType)changeType property:(NSString *)property;

@end
