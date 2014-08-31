//
//  LYRConversationListViewController.h
//  LayerSample
//
//  Created by Zac White on 8/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRConversationPresenter.h"

@class LYRConversationListViewController;

@protocol LYRConversationListViewControllerDataSource <NSObject>

@required

/**
 *  Asks the data source for the number of conversations to display in the LYRConversationListViewController.
 *
 *  @param conversationListViewController An object representing the conversation list view controller requesting this information.
 *
 *  @return The number of conversations to display.
 */
- (NSUInteger)numberOfConversationsInViewController:(LYRConversationListViewController *)conversationListViewController;

/**
 *  Asks the data source for a cell presenter object for a conversation at an index.
 *
 *  @param conversationListViewcontroller An object representing the conversation list view controller requesting this information.
 *  @param index                          The index of the conversation.
 *
 *  @return An instance conforming to the LYRConversationPresenter protocol.
 */
- (id<LYRConversationCellPresenter>)conversationListViewController:(LYRConversationListViewController *)conversationListViewController presenterForConversationAtIndex:(NSUInteger)index;

@optional

/**
 *  Called when the conversation list view controller will begin a search. This should be used as an indication that all calls to the data source methods should return information about the search results.
 *
 *  @param conversationListViewController The conversation list view controller beginning the search.
 */
- (void)conversationListViewControllerWillBeginSearch:(LYRConversationListViewController *)conversationListViewController;

/**
 *  Called when the conversation list view controller did end a search. This should be used as an indication that all calls to the data source methods should return information about the full data set.
 *
 *  @param conversationListViewController The conversation list view controller that just finished search.
 */
- (void)conversationListViewControllerDidEndSearch:(LYRConversationListViewController *)conversationListViewController;

/**
 *  Informs the data source that a search has been made with the following search string. After the completion block is called, the `comversationListViewController:presenterForConversationAtIndex:` method will be called for each search result.
 *
 *  @param conversationListViewController An object representing the conversation list view controller.
 *  @param searchString                   The search string that was just used for search.
 *  @param completion                     The completion block that should be called when the results are fetched from the search.
 */
- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion;

/**
 *  Called when the user deletes a conversation at a given index. The conversation should be deleted from the data source and not represented in any subsequent data source calls.
 *
 *  @param conversationListViewController The conversation list view controller which the user used to delete a conversation.
 *  @param index                          The index of the conversation that was just deleted.
 */
- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewController deleteConversationAtIndex:(NSUInteger)index;

/**
 *  Asks the delegate if deletion should be enabled for the specific conversation
 *
 *  @param conversationListViewController The conversation list view controller which the user used to attempt deletion of a conversation.
 *  @param index                          The index of the conversation that is attempting to be deleted.
 *
 *  @return A boolean value telling to the controller wether or not the conversation is eligible for deletion
 */
- (BOOL)conversationListViewController:(LYRConversationListViewController *)conversationListViewController shouldDeleteConversationAtIndex:(NSUInteger)index;

@end

@protocol LYRConversationListViewControllerDelegate <NSObject>

@optional

/**
 *  Called on the delegate when a conversation is selected.
 *
 *  @param conversationListViewcontroller The conversation list view controller object informing the delegate of the conversation selection.
 *  @param index                          The index of the selected conversation.
 */
- (void)conversationListViewController:(LYRConversationListViewController *)conversationListViewcontroller didSelectConversationAtIndex:(NSUInteger)index;

/**
 *  Returns a height used for the conversation at the index.
 *
 *  @param conversationListViewcontroller The conversation list view controller object asking for a height for a conversation at an index.
 *  @param index                          The index of the conversation.
 *
 *  @return The height of the conversation at the index.
 */
- (CGFloat)conversationListViewController:(LYRConversationListViewController *)conversationListViewcontroller heightForConversationAtIndex:(NSUInteger)index;

@end

@interface LYRConversationListViewController : UITableViewController

/// YES if the search is currently active and the search results are expected to be returned in the data source methods.
@property (readonly, nonatomic) BOOL isSearching;

/// The search bar used for search.
@property (readonly, nonatomic) UISearchBar *searchBar;

/// An object conforming to the LYRConversationListViewControllerDelegate protocol.
@property (weak, nonatomic) id<LYRConversationListViewControllerDelegate> delegate;

/// An object conforming to the LYRConversationListViewControllerDataSource protocol that can provide data to be displayed.
@property (weak, nonatomic) id<LYRConversationListViewControllerDataSource> dataSource;

/**
 *  Forces an unanimated reload of all conversations.
 */
- (void)reloadConversations;

/**
 *  Applies an array of LYRDataSourceChange objects to the list. The list will animate to its new state.
 *
 *  @param changes The LYRDataSourceChange objects representing conversation changes to apply to the conversation list.
 */
- (void)applyConversationChanges:(NSArray *)changes;

@end