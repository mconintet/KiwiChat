//
//  MainTabBarViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "macro.h"
#import "font_icon.h"
#import "ChatsViewController.h"
#import "ContactsViewController.h"
#import "SettingsViewController.h"

#define MTV_NAV_BAR_FONT_SIZE 14

@interface MainTabBarViewController ()
@property (nonatomic, strong) ChatsViewController* chats;
@property (nonatomic, strong) ContactsViewController* contacts;
@property (nonatomic, strong) SettingsViewController* settings;
@end

@implementation MainTabBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    NSDictionary* attributes = [NSDictionary
        dictionaryWithObject:[UIFont boldSystemFontOfSize:MTV_NAV_BAR_FONT_SIZE]
                      forKey:NSFontAttributeName];

    _chats = ({
        ChatsViewController* vc = [[ChatsViewController alloc] init];

        UINavigationController* nav = [[UINavigationController alloc]
            initWithRootViewController:vc];
        [nav.navigationBar setTitleTextAttributes:attributes];

        UITabBarItem* tabBarItem = [[UITabBarItem alloc]
            initWithTitle:@"Chats"
                    image:FONT_UIIMAGE(FONT_ICON_COMMENT, 22, 0xFFFFFF)
                      tag:0];
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        nav.tabBarItem = tabBarItem;
        [self addChildViewController:nav];

        vc;
    });

    _contacts = ({
        ContactsViewController* vc = [[ContactsViewController alloc] init];

        UINavigationController* nav = [[UINavigationController alloc]
            initWithRootViewController:vc];
        [nav.navigationBar setTitleTextAttributes:attributes];

        UITabBarItem* tabBarItem = [[UITabBarItem alloc]
            initWithTitle:@"Contacts"
                    image:FONT_UIIMAGE(FONT_ICON_USER, 22, 0xFFFFFF)
                      tag:1];
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        nav.tabBarItem = tabBarItem;
        [self addChildViewController:nav];

        vc;
    });

    _settings = ({
        SettingsViewController* vc = [[SettingsViewController alloc] init];

        UINavigationController* nav = [[UINavigationController alloc]
            initWithRootViewController:vc];
        [nav.navigationBar setTitleTextAttributes:attributes];

        UITabBarItem* tabBarItem = [[UITabBarItem alloc]
            initWithTitle:@"Settings"
                    image:FONT_UIIMAGE(FONT_ICON_COG, 22, 0xFFFFFF)
                      tag:2];
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        nav.tabBarItem = tabBarItem;
        [self addChildViewController:nav];

        vc;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
