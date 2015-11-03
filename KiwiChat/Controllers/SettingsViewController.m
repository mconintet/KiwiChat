//
//  SettingsViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/28/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "SettingsViewController.h"
#import "macro.h"
#import "UIButton+SetBackgroundColor.h"
#import "UserModel.h"
#import "NSMutableDictionary+Path.h"
#import "MessageRouter.h"
#import "MOIToast.h"
#import "LoginViewController.h"
#import "MOIRefreshControl.h"
#import "MOIRefreshControlDefaultSubView.h"
#import "NSMutableDictionary+Path.h"

#define STV_NICKNAME_FONT_SIZE 16
#define STV_UID_FONT_SIZE 14

#define STV_LOGOUT_BUTTON_BACKGROUND_COLOR 0x366EEC
#define STV_LOGOUT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT 0x2583D8
#define STV_LOGOUT_BUTTON_FONT_SIZE 14

@interface SettingsViewController ()
@property (nonatomic, strong) UIScrollView* scrollView;
@property (strong, nonatomic) MOIRefreshControl* refreshCtrl;

@property (nonatomic, strong) UIImageView* avatarImage;
@property (nonatomic, strong) UILabel* nicknameLabel;
@property (nonatomic, strong) UILabel* uidLabel;
@property (nonatomic, strong) UIView* infoContainer;

@property (nonatomic, strong) UIButton* btnLogout;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UICOLOR_FROM_RGB(0xF1F1F8);

    _scrollView = ({
        UIScrollView* sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        //sv.translatesAutoresizingMaskIntoConstraints = NO;
        sv.alwaysBounceVertical = YES;
        [self.view addSubview:sv];
        sv;
    });

    _infoContainer = ({
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
        [_scrollView addSubview:view];
        view.backgroundColor = UICOLOR_FROM_RGB(0xFBFBFB);
        view;
    });

    _avatarImage = ({
        UIImageView* imageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, 0, 70, 70)];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 70 * 0.5;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoContainer addSubview:imageView];
        imageView;
    });

    _nicknameLabel = ({
        UILabel* label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:STV_NICKNAME_FONT_SIZE];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoContainer addSubview:label];
        label;
    });

    _uidLabel = ({
        UILabel* label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:STV_UID_FONT_SIZE];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoContainer addSubview:label];
        label;
    });

    _btnLogout = ({
        UIButton* btn = [[UIButton alloc] init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:STV_LOGOUT_BUTTON_FONT_SIZE];
        btn.backgroundColor = UICOLOR_FROM_RGB(STV_LOGOUT_BUTTON_BACKGROUND_COLOR);
        [btn setTitle:@"Logout" forState:UIControlStateNormal];
        [btn setBackgroundColor:UICOLOR_FROM_RGB(STV_LOGOUT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT)
                       forState:UIControlStateHighlighted];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3.0f;
        [self.view addSubview:btn];
        btn;
    });
    [_btnLogout addTarget:self action:@selector(btnLogoutClicked:) forControlEvents:UIControlEventTouchUpInside];

    MOIRefreshControlDefaultSubView* view = [[MOIRefreshControlDefaultSubView alloc]
        initWithFont:[UIFont systemFontOfSize:14]
               label:nil];
    view.textLabel.backgroundColor = UICOLOR_FROM_RGB(0xF1F1F8);

    _refreshCtrl = [[MOIRefreshControl alloc] initWithSubView:view
                                                 inScrollView:_scrollView];
    [_refreshCtrl addTarget:self action:@selector(refreshing:) forControlEvents:UIControlEventValueChanged];

    [MessageRouter addPattern:@"get-user-info-return" target:self action:@selector(getUserInfoReturn:)];
    [MessageRouter addPattern:@"logout-return" target:self action:@selector(logoutReturn:)];
    [self setupConstraints];
}

- (void)getUserInfoReturn:(NSDictionary*)msg
{
    DLOG(@"getUserInfoReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] != MR_RESP_ERR_CODE_NONE) {
        [_refreshCtrl endRefreshingWithDuration:0.3
                                     completion:nil];

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
                              top:YES
                           margin:74
                            title:nil
                          message:[msg objectForKey:@"errMsg"]
                         duration:1
                          timeout:3
                       completion:nil];
        }
        return;
    }

    UserModel* user = [UserModel getCurrent];
    user.nickname = [msg objectForKey:@"nickname"];
    [user setAvatarByBase64:[msg objectForKey:@"avatar"]];
    [user save];

    MOIRefreshControlDefaultSubView* view = (MOIRefreshControlDefaultSubView*)_refreshCtrl.subView;
    [view.loadingView startAnimating];
    [_refreshCtrl endRefreshingWithDuration:0.3
                                 completion:^(void) {
                                     [view.loadingView stopAnimating];
                                     [self updateInfo];
                                 }];
}

- (void)refreshing:(id)sender
{
    MOIRefreshControlDefaultSubView* view = (MOIRefreshControlDefaultSubView*)_refreshCtrl.subView;
    [view.loadingView startAnimating];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
        dispatch_get_main_queue(), ^(void) {
            UserModel* user = [UserModel getCurrent];
            NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
            [action setObject:@"get-user-info" forPath:@"action"];
            [action setObject:user.uid forPath:@"uid"];
            [action setObject:user.token forPath:@"token"];

            [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
        });
}

- (void)updateInfo
{
    UserModel* user = [UserModel getCurrent];
    _nicknameLabel.text = user.nickname;
    _uidLabel.text = [NSString stringWithFormat:@"UID: %@", [user.uid stringValue]];

    UIImage* avatarImg = [user getAvatarAsUIImage];
    if (avatarImg == nil) {
        avatarImg = [UIImage imageWithColor:UICOLOR_FROM_RGB(0xDDDDDD) size:CGSizeMake(100, 100)];
    }
    _avatarImage.image = avatarImg;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = @"Settings";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;

    CALayer* bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, _infoContainer.frame.size.height, _infoContainer.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = UICOLOR_FROM_RGB(0xBCBAC1).CGColor;
    [_infoContainer.layer addSublayer:bottomBorder];

    CALayer* topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0, _infoContainer.frame.size.width, 0.5f);
    topBorder.backgroundColor = UICOLOR_FROM_RGB(0xBCBAC1).CGColor;
    [_infoContainer.layer addSublayer:topBorder];

    [self updateInfo];
}

- (void)setupConstraints
{
    NSArray* constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:[logout(>=30)]-70-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"logout" : _btnLogout
                              }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[logout]-20-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"logout" : _btnLogout
                              }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[avatar(70)]-20-[nickname]|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImage,
                                  @"nickname" : _nicknameLabel
                              }];
    [_infoContainer addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[avatar(70)]-20-[uid]|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImage,
                                  @"uid" : _uidLabel
                              }];
    [_infoContainer addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-5-[avatar(70)]-5-|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"avatar" : _avatarImage,
                              }];
    [_infoContainer addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-15-[nickname][uid]|"
                            options:0
                            metrics:nil
                              views:@{
                                  @"nickname" : _nicknameLabel,
                                  @"uid" : _uidLabel
                              }];
    [_infoContainer addConstraints:constraints];
}

- (void)btnLogoutClicked:(id)sender
{
    UIAlertController* alertController = [UIAlertController
        alertControllerWithTitle:@"Logout"
                         message:@"Are you sure?"
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancelAction = [UIAlertAction
        actionWithTitle:@"Cancel"
                  style:UIAlertActionStyleCancel
                handler:nil];

    UIAlertAction* okAction = [UIAlertAction
        actionWithTitle:@"OK"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction* ac) {
                    UserModel* user = [UserModel getCurrent];
                    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
                    [action setObject:@"logout" forPath:@"action"];
                    [action setObject:user.uid forPath:@"uid"];
                    [action setObject:user.token forPath:@"token"];

                    [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
                }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)logoutReturn:(NSDictionary*)msg
{
    DLOG(@"registerReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] == MR_RESP_ERR_CODE_NONE ||
        [errCode integerValue] == MR_RESP_ERR_CODE_INVALID_TOKEN) {

        [MOIToast successWithin:self.view
                            top:YES
                         margin:74
                          title:nil
                        message:@"Logout successfully"
                       duration:1
                        timeout:3
                     completion:^{
                         LoginViewController* login = [[LoginViewController alloc] init];
                         [CURRENT_NAV pushViewController:login animated:YES];
                     }];
        return;
    }

    [MOIToast errorWithin:self.view
                      top:NO
                   margin:70
                    title:nil
                  message:[msg objectForKey:@"errMsg"]
                 duration:1
                  timeout:3
               completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
