//
//  LSSplashView.m
//  
//
//  Created by Kevin Coleman on 9/24/14.
//
//

#import "LSSplashView.h"

@implementation LSSplashView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        logoImage.center = CGPointMake(self.center.x, 200);
        logoImage.alpha = 0.10;
        [self addSubview:logoImage];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
        spinner.center = self.center;
        spinner.color = [UIColor blackColor];
        [spinner startAnimating];
        [self addSubview:spinner];
    }
    
    return self;
}

@end
