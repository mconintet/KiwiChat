//
//  ChatView.h
//  kiwi-chat
//
//  Created by mconintet on 10/14/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgTableView.h"
#import "MsgInputView.h"

@class ChatView;

@protocol ChatViewDelegate <NSObject>
- (void)sendMsgButtonClicked:(NSString*)msg;
@end

@interface ChatView : UIView <MsgInputViewDelegate>
@property (nonatomic, strong) MsgTableView* msgTable;
@property (nonatomic, strong) MsgInputView* msgInput;
@property (nonatomic, weak) id<ChatViewDelegate> delegate;
@end
