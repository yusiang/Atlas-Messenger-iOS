//
//  LSContactsViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSConversationViewController.h"

@interface LSContactsViewController : UITableViewController

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, strong) NSArray *contacts; // SBW: Is this ever set externally? It appears to be loaded internally

@end
