//
//  AppDelegate.h
//  KiwiChat
//
//  Created by mconintet on 10/20/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWSConnection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) UIWindow* window;
@property (nonatomic, strong) KWSConnection* kwsConn;
@end
