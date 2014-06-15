//
//  LSContactsViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactsViewController.h"
#import "LSContactTableViewCell.h"
#import "LSConversationViewController.h"
#import "LYRSampleConversation.h"
#import "LSUserManager.h"

@interface LSContactsViewController ()

@property (nonatomic, strong) NSMutableArray *participants;

@end

@implementation LSContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Contacts";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadContacts];
    [self addCancelBarButton];
    [self addDoneBarButton];
    [self.tableView registerClass:[LSContactTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) loadContacts
{
    self.contacts = [LSUserManager fetchContacts];
    self.participants = [[NSMutableArray alloc] init];
}

- (void)addCancelBarButton
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    cancel.accessibilityLabel = @"cancel";
    [self.navigationItem setLeftBarButtonItem:cancel];
}

- (void)addDoneBarButton
{
    UIBarButtonItem *newConversation = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(newConversationTapped)];
    newConversation.accessibilityLabel = @"start";
    [self.navigationItem setRightBarButtonItem:newConversation];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (LSContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell updateWithSelectionIndicator:FALSE];
    
    NSDictionary *userInfo = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [userInfo objectForKey:@"fullName"];
    [cell setAccessibilityLabel:[NSString stringWithFormat:@"contactCell+%@", [userInfo objectForKey:@"userID"]]];
    NSLog(@"Contact Cell String %@",[NSString stringWithFormat:@"contactCell+%@", [userInfo objectForKey:@"userID"]]);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateParticpantListWithSelectionAtIndex:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(LSContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell updateWithSelectionIndicator:FALSE];
}

- (void)updateParticpantListWithSelectionAtIndex:(NSIndexPath *)indexPath
{
    NSDictionary *userInfo = [self.contacts objectAtIndex:indexPath.row];
    
    if([self.participants containsObject:userInfo]) {
        [self.participants removeObject:userInfo];
    } else {
        [self.participants addObject:userInfo];
    }
}

- (void)cancelTapped
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        //
    }];
}

- (void) newConversationTapped
{
    LSConversationViewController *controller = [[LSConversationViewController alloc] init];
    controller.conversation = [self.layerController conversationForParticipants:self.participants];
    controller.layerController = self.layerController;
    [self.navigationController pushViewController:controller animated:TRUE];
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    
    [navigationArray removeObjectAtIndex: 1];  // You can pass your index here
    self.navigationController.viewControllers = navigationArray;
}


@end
