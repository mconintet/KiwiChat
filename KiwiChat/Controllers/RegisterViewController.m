//
//  RegisterViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/26/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "RegisterViewController.h"
#import "macro.h"
#import "UIButton+SetBackgroundColor.h"
#import "NSString+Validation.h"
#import "NSMutableDictionary+Path.h"
#import "MessageRouter.h"
#import "MOIToast.h"
#import "UserModel.h"
#import "MainTabBarViewController.h"
#import "MOIToast.h"
#import "MOINetworkState.h"

@import CoreTelephony;

@interface RegisterViewController ()
@property (strong, nonatomic) UITextField* emailField;
@property (strong, nonatomic) UITextField* nicknameField;
@property (strong, nonatomic) UITextField* passwordField;
@property (strong, nonatomic) UITextField* rePasswordField;
@property (strong, nonatomic) UIButton* submitButton;
@end

#define RV_LOGIN_BAR_BTN_FONT_SIZE 14
#define RV_LOGIN_BAR_BTN_TEXT_COLOR 0x005BFF

#define RV_TEXT_FIELD_FONT_SIZE 14

#define RV_SUBMIT_BUTTON_BACKGROUND_COLOR 0x366EEC
#define RV_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT 0x2583D8
#define RV_SUBMIT_BUTTON_FONT_SIZE 14

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Register";

    _emailField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.font = [UIFont systemFontOfSize:RV_TEXT_FIELD_FONT_SIZE];
        tf.keyboardType = UIKeyboardTypeASCIICapable;
        tf.placeholder = @"E-mail";
        tf;
    });
    [self.view addSubview:_emailField];

    _nicknameField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.font = [UIFont systemFontOfSize:RV_TEXT_FIELD_FONT_SIZE];
        tf.keyboardType = UIKeyboardTypeASCIICapable;
        tf.placeholder = @"Nickname";
        tf;
    });
    [self.view addSubview:_nicknameField];

    _passwordField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.font = [UIFont systemFontOfSize:RV_TEXT_FIELD_FONT_SIZE];
        tf.secureTextEntry = YES;
        tf.placeholder = @"Password";
        tf;
    });
    [self.view addSubview:_passwordField];

    _rePasswordField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.font = [UIFont systemFontOfSize:RV_TEXT_FIELD_FONT_SIZE];
        tf.secureTextEntry = YES;
        tf.placeholder = @"Re-Password";
        tf;
    });
    [self.view addSubview:_rePasswordField];

    _submitButton = ({
        UIButton* btn = [[UIButton alloc] init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:RV_SUBMIT_BUTTON_FONT_SIZE];
        btn.backgroundColor = UICOLOR_FROM_RGB(RV_SUBMIT_BUTTON_BACKGROUND_COLOR);
        [btn setTitle:@"Submit" forState:UIControlStateNormal];
        [btn setBackgroundColor:UICOLOR_FROM_RGB(RV_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT)
                       forState:UIControlStateHighlighted];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3.0f;
        btn;
    });
    [self.view addSubview:_submitButton];

    [self setupConstraints];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSingleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];

    [_submitButton addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor whiteColor];

    [MessageRouter addPattern:@"register-return" target:self action:@selector(registerReturn:)];
}

- (void)setupConstraints
{
    NSArray* constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[email]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"email" : _emailField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[nickname]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"nickname" : _nicknameField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[password]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"password" : _passwordField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[rePassword]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"rePassword" : _rePasswordField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[btnSubmit]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"btnSubmit" : _submitButton }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-90-[email]-20-[nickname]-20-[password]-20-[rePassword]-20-[btnSubmit(>=30)]"
                            options:0
                            metrics:nil
                              views:@{
                                  @"email" : _emailField,
                                  @"nickname" : _nicknameField,
                                  @"password" : _passwordField,
                                  @"rePassword" : _rePasswordField,
                                  @"btnSubmit" : _submitButton
                              }];
    [self.view addConstraints:constraints];
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark submit button clicked
- (void)submitButtonClicked:(id)sender
{
    NSString* email = [_emailField.text trim];
    NSString* nickname = [_nicknameField.text trim];
    NSString* password = [_passwordField.text trim];
    NSString* rePassword = [_rePasswordField.text trim];

    if ([email isEmpty]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input email"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    if ([nickname isEmpty]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input nickname"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    if ([password isEmpty]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input password"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    if ([rePassword isEmpty]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input re-password"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    if ([password length] < 6) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input password length great than 6"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    if (![password isEqualToString:rePassword]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Passwords doesn't match"
                     duration:1
                      timeout:3
                   completion:nil];
        return;
    }

    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
    [action setObject:@"register" forPath:@"action"];
    [action setObject:email forPath:@"email"];
    [action setObject:nickname forPath:@"nickname"];
    [action setObject:password forPath:@"password"];
    [action setObject:[NSNumber numberWithInteger:[MOINetworkState currentState]] forPath:@"network"];

    [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
}

- (void)registerReturn:(NSDictionary*)msg
{
    DLOG(@"registerReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] == MR_RESP_ERR_CODE_NONE) {
        UserModel* user = [[UserModel alloc] init];
        user.nickname = [msg objectForKey:@"nickname"];
        user.uid = [msg objectForKey:@"uid"];
        user.token = [msg objectForKey:@"token"];
        user.is_current = [NSNumber numberWithInt:1];
        [user setAvatarByBase64:[msg objectForKey:@"avatar"]];

        [user save];
        [user setLoggedIn];

        MainTabBarViewController* main = [[MainTabBarViewController alloc] init];
        [CURRENT_NAV pushViewController:main animated:YES];
        return;
    }

    [MOIToast errorWithin:self.view
                      top:NO
                   margin:10
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
