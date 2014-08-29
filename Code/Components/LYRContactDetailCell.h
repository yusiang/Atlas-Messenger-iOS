//
//  LYRContactDetailCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRContactPresenter.h"

typedef enum {
    LYRContactCellContentTypeEmail,
    LYRContactCellContentTypePhone,
}LYRContactCellContentType;

@interface LYRContactDetailCell : UITableViewCell

- (void)updateWithContentType:(LYRContactCellContentType)contentType content:(NSString *)content;

@end
