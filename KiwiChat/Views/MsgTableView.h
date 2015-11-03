//
//  MsgTableView.h
//  kiwi-chat
//
//  Created by mconintet on 10/13/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOIRefreshControl.h"
#import "MOIRefreshControlDefaultSubView.h"
#import "UITableView+ScrollToTop.h"

@interface MsgTableView : UITableView
@property (strong, nonatomic) MOIRefreshControl* refreshCtrl;
@end
