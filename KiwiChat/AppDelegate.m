//
//  AppDelegate.m
//  KiwiChat
//
//  Created by mconintet on 10/20/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "AppDelegate.h"
#import "macro.h"
#import "UserModel.h"
#import "MessageRouter.h"
#import "MainTabBarViewController.h"
#import "NSMutableDictionary+Path.h"
#import "LoginViewController.h"
#import "MOINetworkState.h"

#define NAV_BAR_FONT_SIZE 16

#define KIWI_SERVER_ADDRESS @"ws://127.0.0.1:9876"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    _window = ({
        MainTabBarViewController* vc = [[MainTabBarViewController alloc] init];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
        NSDictionary* attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:NAV_BAR_FONT_SIZE]
                                                               forKey:NSFontAttributeName];
        [nav.navigationBar setTitleTextAttributes:attributes];

        UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = nav;
        window.backgroundColor = [UIColor whiteColor];
        [window makeKeyAndVisible];

        window;
    });

    NSDictionary* attrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:14.0]
    };
    id appearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[ [UINavigationBar class] ]];
    [appearance setTitleTextAttributes:attrs
                              forState:UIControlStateNormal];

    [MessageRouter addPattern:@"check-token-return" target:self action:@selector(checkTokenReturn:)];

    return YES;
}

- (void)setupKWSConn
{
    if (_kwsConn != nil) {
        return;
    }

    DLOG(@"connectting to %@", KIWI_SERVER_ADDRESS);
    _kwsConn = [[KWSConnection alloc] initWithURL:[NSURL URLWithString:KIWI_SERVER_ADDRESS]];

    __weak typeof(self) weakSelf = self;
    _kwsConn.onOpenHandler = ^BOOL(KWSConnection* conn) {
        DLOG(@"onOpenHandler");
        if ([weakSelf isNeedLogin]) {
            // goto login
            DLOG(@"goto login");
        }
        return true;
    };

    _kwsConn.onMessageHandler = ^BOOL(KWSMessage* msg, KWSConnection* conn) {
        DLOG(@"onMessageHandler");
        NSString* msgStr = [msg newString];
        DLOG(@"received msg: %@", msgStr);
        [MessageRouter routeMessage:msg conn:conn];
        return true;
    };

    __block BOOL timeout = false;
    _kwsConn.onClosedHandler = ^(void) {
        DLOG(@"onClosedHandler");
        _kwsConn = nil;

        if (timeout) {
            return;
        }

        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:@"Connection lost"
                             message:@"Connection is lost, please reopen app to reconnect."
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction
            actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                    handler:nil];

        [alert addAction:defaultAction];
        [weakSelf.window.rootViewController
            presentViewController:alert
                         animated:YES
                       completion:nil];
    };

    _kwsConn.onTimeoutHandler = ^(void) {
        DLOG(@"connection timeout");
        timeout = true;

        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:@"Connection timeout"
                             message:@"Connection is timeout, please reopen app to reconnect."
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction
            actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                    handler:nil];

        [alert addAction:defaultAction];
        [weakSelf.window.rootViewController
            presentViewController:alert
                         animated:YES
                       completion:nil];
    };

    [_kwsConn connectWithTimeout:10];
    [_kwsConn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (BOOL)isNeedLogin
{
    UserModel* user = [UserModel getCurrent];
    if ([user._id integerValue] == 0) {
        return true;
    }

    if (user.token == nil || [user.token isEqualToString:@""]) {
        return true;
    }

    // check token
    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
    [action setObject:@"check-token" forPath:@"action"];
    [action setObject:user.uid forPath:@"uid"];
    [action setObject:user.token forPath:@"token"];
    [action setObject:[NSNumber numberWithInteger:[MOINetworkState currentState]] forPath:@"network"];

    [_kwsConn.messageSender sendMessage:makeKWSMessage(action)];
    return false;
}

- (void)checkTokenReturn:(NSDictionary*)msg
{
    DLOG(@"checkTokenReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] != MR_RESP_ERR_CODE_NONE) {
        LoginViewController* login = [[LoginViewController alloc] init];
        [CURRENT_NAV pushViewController:login animated:YES];
    }
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setupKWSConn];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_kwsConn close];
}

@end
