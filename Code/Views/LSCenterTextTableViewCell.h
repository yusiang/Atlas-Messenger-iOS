//
//  LSCenterTextTableViewCell.h
//  
//
//  Created by Kevin Coleman on 10/24/14.
//
//

#import <UIKit/UIKit.h>

@interface LSCenterTextTableViewCell : UITableViewCell

@property (nonatomic) UILabel *centerTextLabel;

- (void)setCenterText:(NSString *)text;

@end
