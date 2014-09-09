//
//  LYRUIUtilities.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIUtilities.h"

CGSize LYRUITextPlainSize(NSString *string, UIFont *font)
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(240, 900)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    return rect.size;
}

CGSize LYRUIImageSize(UIImage *image, CGRect rect)
{
    CGSize itemSize;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (imageView.frame.size.height > imageView.frame.size.width) {
        itemSize = CGSizeMake(rect.size.width, 300);
    } else {
        CGFloat ratio = ((rect.size.width * .75) / imageView.frame.size.width);
        itemSize = CGSizeMake(rect.size.width, imageView.frame.size.height * ratio);
    }
    return itemSize;
}
