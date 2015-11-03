//
//  ContactsViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactsTableViewCell.h"
#import "macro.h"
#import "font_icon.h"
#import "MOIRefreshControl.h"
#import "MOIRefreshControlDefaultSubView.h"
#import "MessageRouter.h"
#import "NSMutableDictionary+Path.h"
#import "UserModel.h"
#import "AddBuddyViewController.h"
#import "UITableView+ScrollToTop.h"
#import "BuddyModel.h"
#import "UserBuddyModel.h"
#import "ChatViewController.h"
#import "MOIToast.h"
#import "LoginViewController.h"

@interface ContactsViewController ()
@property (strong, nonatomic) UIBarButtonItem* addBuddyButton;
@property (strong, nonatomic) MOIRefreshControl* refreshCtrl;
@end

@implementation ContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _addBuddyButton = ({
        UIImage* image = FONT_UIIMAGE(FONT_ICON_USER_ADD, 20, 0x0);
        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc]
            initWithImage:image
                    style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(addBuddyButtonClicked:)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        barButtonItem;
    });

    MOIRefreshControlDefaultSubView* view = [[MOIRefreshControlDefaultSubView alloc]
        initWithFont:[UIFont systemFontOfSize:14]
               label:@"load more"];
    view.textLabel.backgroundColor = UICOLOR_FROM_RGB(0xF1F1F8);

    _refreshCtrl = [[MOIRefreshControl alloc] initWithSubView:view
                                                 inScrollView:self.tableView];

    [MessageRouter addPattern:@"get-buddies-return" target:self action:@selector(getBuddiesReturn:)];
    [_refreshCtrl addTarget:self action:@selector(refreshing:) forControlEvents:UIControlEventValueChanged];

    self.tableView.delegate = self;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.backgroundColor = UICOLOR_FROM_RGB(0xF1F1F8);
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getBuddiesReload:true];
    [self.tableView reloadData];
}

- (NSArray*)getBuddiesReload:(BOOL)reload
{
    static NSArray* buddies = nil;
    if (buddies == nil || reload) {
        buddies = [[UserModel getCurrent] getBuddies];
    }
    return buddies;
}

- (void)getBuddiesReturn:(NSDictionary*)msg
{
    DLOG(@"getBuddiesReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] != MR_RESP_ERR_CODE_NONE) {
        [_refreshCtrl endRefreshingWithDuration:0.3
                                     completion:nil];

        if ([errCode integerValue] == MR_RESP_ERR_CODE_INVALID_TOKEN) {
            [MOIToast errorWithin:self.view
                              top:YES
                           margin:74
                            title:nil
                          message:@"Invalid login info"
                         duration:1
                          timeout:3
                       completion:^{
                           LoginViewController* login = [[LoginViewController alloc] init];
                           [CURRENT_NAV pushViewController:login animated:YES];
                       }];
        }
        else {
            [MOIToast errorWithin:self.view
                              top:YES
                           margin:74
                            title:nil
                          message:[msg objectForKey:@"errMsg"]
                         duration:1
                          timeout:3
                       completion:nil];
        }
        return;
    }

    // update local buddies
    NSArray* buddies = [msg objectForKey:@"buddies"];
    for (NSDictionary* buddyDict in buddies) {
        NSNumber* buddyUid = [buddyDict objectForKey:@"uid"];
        BuddyModel* buddy = [BuddyModel loadByUID:buddyUid];
        if (buddy._id == nil) {
            buddy.uid = buddyUid;
        }
        buddy.nickname = [buddyDict objectForKey:@"nickname"];
        buddy.network = [buddyDict objectForKey:@"network"];
        [buddy setAvatarByBase64:[buddyDict objectForKey:@"avatar"]];
        [buddy save];

        // update relation
        NSNumber* currentUid = [UserModel getCurrent].uid;
        UserBuddyModel* ub = [UserBuddyModel loadByUID:currentUid buddyID:buddyUid];
        if (ub._id == nil) {
            ub.uid = currentUid;
            ub.buddyID = buddyUid;
            [ub save];
        }
    }

    MOIRefreshControlDefaultSubView* view = (MOIRefreshControlDefaultSubView*)_refreshCtrl.subView;
    [_refreshCtrl endRefreshingWithDuration:0.3
                                 completion:^(void) {
                                     [view.loadingView stopAnimating];
                                     [self getBuddiesReload:true];
                                     [self.tableView reloadData];
                                     [view setLabel:@"load more"];
                                 }];
}

- (void)refreshing:(id)sender
{
    MOIRefreshControlDefaultSubView* view = (MOIRefreshControlDefaultSubView*)_refreshCtrl.subView;
    [view setLabel:@"loading..."];
    [view.loadingView startAnimating];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
        dispatch_get_main_queue(), ^(void) {
            UserModel* user = [UserModel getCurrent];

            NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
            [action setObject:@"get-buddies" forPath:@"action"];
            [action setObject:user.uid forPath:@"uid"];
            [action setObject:user.token forPath:@"token"];

            [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
        });
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = @"Contacts";
    self.tabBarController.navigationItem.rightBarButtonItem = _addBuddyButton;
}

- (void)addBuddyButtonClicked:(id)sender
{
    AddBuddyViewController* controller = [[AddBuddyViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getBuddiesReload:false] count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellId = @"cellId";
    ContactsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ContactsTableViewCell alloc] initWithReuseIdentifier:cellId];
    }

    BuddyModel* buddy = (BuddyModel*)[[self getBuddiesReload:false] objectAtIndex:indexPath.row];

    cell.nicknameLabel.text = buddy.nickname;
    cell.avatarImageView.image = [buddy getAvatarAsUIImage];
    [cell setNetworkState:[buddy network] ? [[buddy network] integerValue] : MOINetworkStateCodeNone];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [ContactsTableViewCell height];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    ChatViewController* controller = [[ChatViewController alloc] init];
    controller.buddy = (BuddyModel*)[[self getBuddiesReload:false] objectAtIndex:indexPath.row];
    controller.hidesBottomBarWhenPushed = YES;
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:UICOLOR_FROM_RGB(0xEEEEEE) ForCell:cell]; //highlight colour
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:UICOLOR_FROM_RGB(0xFBFBFB) ForCell:cell]; //normal color
}

- (void)setCellColor:(UIColor*)color ForCell:(UITableViewCell*)cell
{
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [_refreshCtrl scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView
{
    [_refreshCtrl scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [_refreshCtrl scrollViewDidScroll:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
