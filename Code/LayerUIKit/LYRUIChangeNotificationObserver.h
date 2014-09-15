//
//  LYRUIChangeNotificationObserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@class LYRUIChangeNotificationObserver;

@protocol LYRUIChangeNotificationObserverDelegate<NSObject>

@optional

- (void)observerWillChangeContent:(LYRUIChangeNotificationObserver *)observer;

- (void)observer:(LYRUIChangeNotificationObserver *)observer didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(LYRObjectChangeType)changeType newIndexPath:(NSUInteger)newIndex;

- (void)observerDidChangeContent:(LYRUIChangeNotificationObserver *)observer;

@end

@interface LYRUIChangeNotificationObserver : NSObject

@property (nonatomic, weak) id<LYRUIChangeNotificationObserverDelegate>delegate;

- (id) initWithClient:(LYRClient *)layerClient conversations:(NSArray *)conversations;

- (void)setConversations:(NSArray *)conversations;

@end
