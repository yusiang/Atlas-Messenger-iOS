//
//  ATLMNavigationController.h
//  Atlas Messenger
//
//  Created by Ben Blakley on 1/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLMNavigationController : UINavigationController

@property (nonatomic, getter=isAnimating, readonly) BOOL animating;

- (void)notifyWhenCompletionEndsUsingBlock:(void (^)())handler;

@end

@interface UIViewController (ATLMNavigationController)

@property (nonatomic, readonly) ATLMNavigationController *ATLM_navigationController;

@end
