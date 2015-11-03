//
//  ChatViewController.m
//  kiwi-chat
//
//  Created by mconintet on 10/14/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "ChatViewController.h"
#import "macro.h"
#import "KWSConnection.h"
#import "MsgTableView.h"
#import "MsgTableViewCell.h"
#import "MessageModel.h"
#import "UserModel.h"
#import "ChatModel.h"
#import "MessageRouter.h"
#import "NSMutableDictionary+Path.h"
#import "MOIToast.h"
#import "LoginViewController.h"

#define CVC_LOAD_MORE_TASK_QUEUE_NAME "com.mconintet.cvc.loadMore"

@interface ChatViewController ()
@property (nonatomic, strong) ChatView* chatView;
@property (nonatomic, strong) NSMutableArray* msgArray;
@property (nonatomic, strong) dispatch_queue_t loadMoreTaskQueue;
@end

static int pageIdx = 0;
static int pageSize = 10;

static NSInteger compareHour = -1;
static NSDate* prevMsgDate = nil;

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _msgArray = [[NSMutableArray alloc] init];

    _chatView = [[ChatView alloc] initWithFrame:self.view.bounds];
    _chatView.delegate = self;
    [self.view addSubview:_chatView];

    [_chatView.msgTable.refreshCtrl addTarget:self
                                       action:@selector(loadHistory:)
                             forControlEvents:UIControlEventValueChanged];

    _chatView.msgTable.dataSource = self;
    _chatView.msgTable.delegate = self;

    _loadMoreTaskQueue = dispatch_queue_create(CVC_LOAD_MORE_TASK_QUEUE_NAME, 0);

    [MessageRouter addPattern:@"send-message-return" target:self action:@selector(sendMessageReturn:)];
}

- (void)viewDidAppear:(BOOL)animated
{
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

    // update UI
    [_msgArray addObject:msgModel];
    NSArray* indexPaths = @[ [NSIndexPath indexPathForRow:[_msgArray count] - 1 inSection:0] ];
    [_chatView.msgTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_chatView.msgTable scrollToBottom];
}

- (void)sendMessageReturn:(NSDictionary*)msg
{
    DLOG(@"newMessage");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] == MR_RESP_ERR_CODE_UNREACHABLE) {
        [MOIToast errorWithin:self.view
                          top:YES
                       margin:74
                        title:nil
                      message:@"Your buddy is offline now :("
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }
}

- (NSArray*)insertDate2MsgArray:(NSArray*)msgArray
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];

    for (int i = 0; i < [msgArray count]; i++) {
        MessageModel* msg = (MessageModel*)[msgArray objectAtIndex:i];
        NSDate* msgDate = [NSDate dateWithTimeIntervalSince1970:[msg.add_time doubleValue]];

        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitHour fromDate:msgDate];
        NSInteger hour = [components hour];

        [ret addObject:[msgArray objectAtIndex:i]];

        if (compareHour == -1) {
            compareHour = hour;
            prevMsgDate = msgDate;
            continue;
        }

        if (compareHour != hour) {
            [ret addObject:prevMsgDate];
            prevMsgDate = msgDate;
            compareHour = hour;
        }
    }
    if ([msgArray count] == 0 && prevMsgDate != nil) {
        [ret addObject:prevMsgDate];
        prevMsgDate = nil;
    }
    return ret;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = _buddy.nickname;

    compareHour = -1;
    prevMsgDate = nil;
    pageIdx = 0;

    [super viewWillAppear:animated];
    [self loadMoreThen:^(NSArray* results) {
        NSUInteger count = [results count];
        if (count) {
            NSMutableArray* indexArray = [[NSMutableArray alloc] initWithCapacity:count];
            for (NSInteger i = count - 1; i >= 0; i--) {
                [_msgArray addObject:[results objectAtIndex:i]];
                [indexArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.chatView.msgTable insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)loadMoreThen:(void (^)(NSArray*))completion
{
    // previous controller must set buddy to chat with at first
    if (_buddy == nil) {
        return;
    }

    NSNumber* uid = [UserModel getCurrent].uid;

    void (^task)(void) = ^{
        NSArray* results = [MessageModel
            newModelsWithWhereCondition:@"(`uid`=:uid AND `to`=:buddyID) OR (`uid`=:uid AND `from`=:buddyID)"
                             bindParams:@{
                                 @":uid" : uid,
                                 @":buddyID" : _buddy.uid
                             }
                                orderBy:@"_id"
                                    asc:false
                                  limit:pageSize
                                 offset:pageIdx * pageSize];
        DLOG(@"results count %lu", (unsigned long)[results count]);
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray* insertedDate = [self insertDate2MsgArray:results];
                completion(insertedDate);
                ++pageIdx;
            });
        }
    };

    dispatch_async(_loadMoreTaskQueue, task);
}

- (void)loadHistory:(id)sender
{
    __block MOIRefreshControl* refreshCtrl = (MOIRefreshControl*)sender;
    MOIRefreshControlDefaultSubView* view = (MOIRefreshControlDefaultSubView*)refreshCtrl.subView;
    [view setLabel:@"loading..."];
    [view.loadingView startAnimating];

    void (^completion)(NSArray*) = ^(NSArray* results) {
        [view setLabel:@"load more"];
        NSUInteger count = [results count];
        if (count) {
            NSMutableArray* indexArray = [[NSMutableArray alloc] initWithCapacity:count];
            for (NSInteger i = count - 1; i >= 0; i--) {
                [self.msgArray insertObject:[results objectAtIndex:i] atIndex:count - 1 - i];
                [indexArray addObject:[NSIndexPath indexPathForRow:count - 1 - i inSection:0]];
            }
            [_chatView.msgTable beginUpdates];
            [_chatView.msgTable insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [_chatView.msgTable endUpdates];
        }
    };

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC),
        dispatch_get_main_queue(), ^(void) {
            [self loadMoreThen:^(NSArray* results) {
                [view.loadingView stopAnimating];
                [refreshCtrl endRefreshingWithDuration:0.3
                                            completion:^{
                                                completion(results);
                                            }];
            }];
        });
}

#pragma mark ChatViewDelegate
- (void)sendMsgButtonClicked:(NSString*)msg
{
    if ([msg isEqualToString:@""]) {
        return;
    }

    // update chat table
    UserModel* currentUser = [UserModel getCurrent];
    NSNumber* uid = currentUser.uid;
    NSNumber* buddyID = _buddy.uid;

    ChatModel* chat = [ChatModel loadByUID:uid buddyID:buddyID];
    chat.uid = uid;
    chat.buddyID = buddyID;
    [chat save];

    // save message to message table
    MessageModel* msgModel = [[MessageModel alloc] init];
    msgModel.uid = uid;
    msgModel.in_out = MessageModelIOType_Out;
    msgModel.to = buddyID;
    msgModel.type = MessageModelType_Text;
    msgModel.text = msg;
    msgModel.add_time = [NSNumber numberWithInteger:(NSInteger)[NSDate date].timeIntervalSince1970];
    [msgModel save];

    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
    [action setObject:@"send-message" forPath:@"action"];
    [action setObject:currentUser.token forPath:@"token"];
    [action setObject:uid forPath:@"from"];
    [action setObject:buddyID forPath:@"to"];
    [action setObject:msgModel._id forPath:@"msgID"];
    [action setObject:MessageModelType_Text forPath:@"msgType"];
    [action setObject:msg forPath:@"msgContent"];

    [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];

    [_msgArray addObject:msgModel];
    NSArray* indexPaths = @[ [NSIndexPath indexPathForRow:[_msgArray count] - 1 inSection:0] ];
    [_chatView.msgTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_chatView.msgTable scrollToBottom];

    [_chatView.msgInput.textView triggerDidChangeAfterSetText:@""];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id row = [_msgArray objectAtIndex:indexPath.row];
    if ([row isKindOfClass:[MessageModel class]]) {
        MessageModel* msg = (MessageModel*)row;
        return [MsgTableViewCell calcHeightWithText:msg.text];
    }
    else if ([row isKindOfClass:[NSDate class]]) {
        return [MsgTableViewCell calcHeightWithDate];
    }
    return 0;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DLOG(@"didSelectRowAtIndexPath");
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.msgArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellId = @"cellId";
    MsgTableViewCell* cell = (MsgTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil) {
        DLOG(@"%ld", (long)indexPath.row);
        cell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId];
    }

    NSObject* row = [_msgArray objectAtIndex:indexPath.row];
    if ([row isKindOfClass:[MessageModel class]]) {
        MessageModel* msg = (MessageModel*)row;
        if (msg.in_out == MessageModelIOType_Out) {
            [cell setText:msg.text date:nil ownershipType:MsgTableViewCellOwnershipTypeMe];
        }
        else {
            [cell setText:msg.text date:nil ownershipType:MsgTableViewCellOwnershipTypeOther];
        }
    }
    else if ([row isKindOfClass:[NSDate class]]) {
        [cell setDate:(NSDate*)row];
    }

    return cell;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [_chatView.msgTable.refreshCtrl scrollViewWillBeginDragging:_chatView.msgTable];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView
{
    [_chatView.msgTable.refreshCtrl scrollViewWillBeginDecelerating:_chatView.msgTable];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [_chatView.msgTable.refreshCtrl scrollViewDidScroll:_chatView.msgTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
