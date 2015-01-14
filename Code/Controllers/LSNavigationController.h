//
//  LSNavigationController.h
//  LayerSample
//
//  Created by Ben Blakley on 1/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSNavigationController : UINavigationController

@property (nonatomic, getter=isAnimating, readonly) BOOL animating;

- (void)notifyWhenCompletionEndsUsingBlock:(void (^)())handler;

@end

@interface UIViewController (LSNavigationController)

@property (nonatomic, readonly) LSNavigationController *ls_navigationController;

@end
