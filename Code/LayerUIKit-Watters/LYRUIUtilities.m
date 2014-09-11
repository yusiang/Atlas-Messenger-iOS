//
//  LYRUIUtilities.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIUtilities.h"

CGSize LYRUITextPlainSize(NSString *text, UIFont *font)
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){240, CGFLOAT_MAX}
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       context:nil];
    return rect.size;
}

CGSize LYRUIImageSize(UIImage *image)
{
    CGSize itemSize;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (imageView.frame.size.height > imageView.frame.size.width) {
        itemSize = CGSizeMake(240, 300);
    } else {
        CGFloat ratio = ((240 * .75) / imageView.frame.size.width);
        itemSize = CGSizeMake(240, imageView.frame.size.height * ratio);
    }
    return itemSize;
}
