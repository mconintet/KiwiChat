//
//  ChatViewController.h
//  kiwi-chat
//
//  Created by mconintet on 10/14/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import "BuddyModel.h"

@interface ChatViewController : UIViewController <ChatViewDelegate,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UIScrollViewDelegate>

@property (nonatomic, strong) BuddyModel* buddy;

@end
