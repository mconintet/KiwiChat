//
//  UITableView+ScrollToTop.m
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/30/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "UITableView+ScrollToTop.h"

@implementation UITableView (ScrollToTop)

- (void)scrollToTop
{
    if ([self numberOfRowsInSection:0] == 0) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:YES];
        return;
    }

    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:YES];
}

- (void)scrollToBottom
{
    if ([self numberOfRowsInSection:0] == 0) {
        return;
    }

    NSInteger msgCount = [self.dataSource tableView:self numberOfRowsInSection:0];
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^(void) {
                        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgCount - 1 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:NO];
                    }
                    completion:nil];
}

@end
