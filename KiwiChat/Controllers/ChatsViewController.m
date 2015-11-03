//
//  ChatsViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ChatsViewController.h"
#import "ChatsTableViewCell.h"
#import "ChatViewController.h"
#import "macro.h"
#import "ChatModel.h"
#import "UserModel.h"
#import "MessageRouter.h"
#import "NSMutableDictionary+Path.h"
#import "MOIToast.h"
#import "LoginViewController.h"

@interface ChatsViewController ()

@end

@implementation ChatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.backgroundColor = UICOLOR_FROM_RGB(0xF1F1F8);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = @"Chats";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];

    [MessageRouter addPattern:@"new-message" target:self action:@selector(newMessage:)];
}

- (void)newMessage:(NSDictionary*)msg
{
    DLOG(@"newMessage");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] != MR_RESP_ERR_CODE_NONE) {
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
                              top:NO
                           margin:10
                            title:nil
                          message:[msg objectForKey:@"errMsg"]
                         duration:1
                          timeout:3
                       completion:nil];
        }
        return;
    }

    UserModel* currentUser = [UserModel getCurrent];
    NSNumber* uid = currentUser.uid;

    // save reveived message into db
    MessageModel* msgModel = [[MessageModel alloc] init];
    msgModel.uid = uid;
    msgModel.in_out = MessageModelIOType_In;
    msgModel.from = [msg objectForKey:@"from"];
    msgModel.type = [msg objectForKey:@"msgType"];
    if (msgModel.type == MessageModelType_Text) {
        msgModel.text = [msg objectForKey:@"msgContent"];
    }
    msgModel.add_time = [NSNumber numberWithInteger:(NSInteger)[NSDate date].timeIntervalSince1970];
    [msgModel save];

    ChatModel* chat = [ChatModel loadByUID:uid buddyID:msgModel.from];
    chat.uid = uid;
    chat.buddyID = msgModel.from;
    [chat save];

    [self.tableView reloadData];
}

- (NSArray*)getChats
{
    return [ChatModel loadArrayByUID:[UserModel getCurrent].uid];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getChats] count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellId = @"cellId";
    ChatsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ChatsTableViewCell alloc] initWithReuseIdentifier:cellId];
    }

    NSArray* chats = [self getChats];
    ChatModel* chat = [chats objectAtIndex:indexPath.row];
    BuddyModel* buddy = [chat getBuddy];
    MessageModel* lastMessage = [chat getLastMessage];

    cell.nicknameLabel.text = buddy.nickname;
    cell.avatarImageView.image = [buddy getAvatarAsUIImage];
    if (lastMessage.type == MessageModelType_Text) {
        cell.lastMessageLabel.text = lastMessage.text;
    }
    else {
        cell.lastMessageLabel.text = @"[Image]";
    }

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString* dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[lastMessage.add_time doubleValue]]];
    cell.lastMessageTimeLabel.text = dateStr;

    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [ChatsTableViewCell height];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    ChatViewController* controller = [[ChatViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;

    ChatModel* chat = [[self getChats] objectAtIndex:indexPath.row];
    controller.buddy = [chat getBuddy];

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

#pragma mark make it to be editable
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (NSArray*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"editActionsForRowAtIndexPath");
    UITableViewRowAction* deleteAction = [UITableViewRowAction
        rowActionWithStyle:UITableViewRowActionStyleDestructive
                     title:@"Delete"
                   handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                       ChatModel* chat = [[self getChats] objectAtIndex:indexPath.row];
                       [chat remove];
                       [self.tableView reloadData];
                   }];

    return @[ deleteAction ];
}

- (void)tableView:(UITableView*)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // implement this mehtod to enable swipe-to-delete feature
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
