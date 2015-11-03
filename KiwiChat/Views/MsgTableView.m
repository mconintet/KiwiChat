//
//  MsgTableView.m
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MsgTableView.h"
#import "MsgTableViewCell.h"
#import "macro.h"

@interface MsgTableView ()

@end

@implementation MsgTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        MOIRefreshControlDefaultSubView* view = [[MOIRefreshControlDefaultSubView alloc]
            initWithFont:[UIFont systemFontOfSize:14]
                   label:@"load more"];

        _refreshCtrl = [[MOIRefreshControl alloc] initWithSubView:view
                                                     inScrollView:self];
    }
    return self;
}

@end
