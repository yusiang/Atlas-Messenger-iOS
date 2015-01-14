//
//  LSNavigationController.m
//  LayerSample
//
//  Created by Ben Blakley on 1/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LSNavigationController.h"

@interface LSNavigationController () <UINavigationControllerDelegate>

@property (nonatomic) NSMutableArray *animationCompletionHandlers;
@property (nonatomic, getter=isAnimating) BOOL animating;

@end

@implementation LSNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        _animationCompletionHandlers = [NSMutableArray new];
    }
    return self;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (delegate != self) [NSException raise:NSInternalInconsistencyException format:@"LSNavigationController must act as its own delegate."];
    [super setDelegate:delegate];
}

- (void)notifyWhenCompletionEndsUsingBlock:(void (^)())handler
{
    if (!handler) return;

    if (!self.isAnimating) {
        handler();
        return;
    }

    [self.animationCompletionHandlers addObject:[handler copy]];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) return;
    self.animating = YES;

    [[self transitionCoordinator] animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (![context isCancelled]) return;
        self.animating = NO;
        [self notifyAnimationCompletionHandlers];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.animating = NO;
    [self notifyAnimationCompletionHandlers];
}

#pragma mark - Helpers

- (void)notifyAnimationCompletionHandlers
{
    while (!self.isAnimating && self.animationCompletionHandlers.count > 0) {
        void (^handler)() = self.animationCompletionHandlers.firstObject;
        [self.animationCompletionHandlers removeObjectAtIndex:0];
        handler();
    }
}

@end

@implementation UIViewController (LSNavigationController)

- (LSNavigationController *)ls_navigationController
{
    if (![self.navigationController isKindOfClass:[LSNavigationController class]]) return nil;

    return (LSNavigationController *)self.navigationController;
}

@end
