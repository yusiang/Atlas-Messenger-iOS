//
//  LYRContactViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactViewController.h"
//#import "LSContactPresenter.h"

@interface LYRContactViewController ()

@property (nonatomic, strong) id<LYRContactPresenter>presenter;

@end

@implementation LYRContactViewController

static NSString *LYRContactHeaderReuseIdentifier = @"contactHeaderReuseIdentifier";
static NSString *LYRContactDetailReuseIdentifier = @"contactDetailReuseIdentifier";
static NSString *LYRContactActionReuseIdentifier = @"contactActionReuseIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.contentInset = UIEdgeInsetsMake(-40.0f, 0.0f, 0.0f, 0.0);
    
    [self.tableView registerClass:[LYRContactHeaderCell class] forCellReuseIdentifier:LYRContactHeaderReuseIdentifier];
    [self.tableView registerClass:[LYRContactDetailCell class] forCellReuseIdentifier:LYRContactDetailReuseIdentifier];
    [self.tableView registerClass:[LYRContactActionCell class] forCellReuseIdentifier:LYRContactActionReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchContactContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)fetchContactContent
{
    self.presenter = [self.dataSource presenterForContactViewController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [[self.presenter contactPhoneNumbers] allObjects].count;
            break;
        case 2:
            return [[self.presenter contactEmailAddresses] allObjects].count;
            break;
        case 3:
            return [[self.presenter contactActionItems] allObjects].count;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 180;
            break;
        case 1:
            return 60;
            break;
        case 2:
            return 60;
            break;
        case 3:
            return 80;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRContactHeaderCell *headerCell = [self.tableView dequeueReusableCellWithIdentifier:LYRContactHeaderReuseIdentifier];
    LYRContactDetailCell *detailCell = [self.tableView dequeueReusableCellWithIdentifier:LYRContactDetailReuseIdentifier];
    LYRContactActionCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:LYRContactActionReuseIdentifier];
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            [headerCell updateWithPresenter:self.presenter];
            cell = headerCell;
            break;
        case 1:
            [detailCell updateWithContentType:LYRContactCellContentTypePhone content:[[[self.presenter contactPhoneNumbers] allObjects] objectAtIndex:indexPath.row]];
            cell = detailCell;
            break;
        case 2:
            [detailCell updateWithContentType:LYRContactCellContentTypeEmail content:[[[self.presenter contactEmailAddresses] allObjects] objectAtIndex:indexPath.row]];
            cell = detailCell;
            break;
        case 3:
            [actionCell updateWithActionTitle:[[[self.presenter contactActionItems] allObjects] objectAtIndex:indexPath.row]];
            cell = actionCell;
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            [self.delegate contactViewController:self didSelectCellWithType:LYRContactViewCellPhoneType atIndex:indexPath.section];
            break;
        case 2:
            [self.delegate contactViewController:self didSelectCellWithType:LYRContactViewCellEmailType atIndex:indexPath.section];
            break;
        case 3:
            [self.delegate contactViewController:self didSelectCellWithType:LYRContactViewCellActionType atIndex:indexPath.section];
            break;
        default:
            break;
    }
}

@end
