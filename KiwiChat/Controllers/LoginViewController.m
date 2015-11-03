//
//  LoginViewController.m
//  KiwiChat
//
//  Created by mconintet on 10/26/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "LoginViewController.h"
#import "macro.h"
#import "UIButton+SetBackgroundColor.h"
#import "RegisterViewController.h"
#import "NSString+Validation.h"
#import "MOIToast.h"
#import "NSMutableDictionary+Path.h"
#import "MessageRouter.h"
#import "UserModel.h"
#import "MainTabBarViewController.h"
#import "MOINetworkState.h"

#define LVC_REG_BAR_BTN_FONT_SIZE 13
#define LVC_REG_BAR_BTN_TEXT_COLOR 0x005BFF

#define LVC_TEXT_FIELD_FONT_SIZE 14

#define LVC_SUBMIT_BUTTON_BACKGROUND_COLOR 0x366EEC
#define LVC_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT 0x2583D8
#define LVC_SUBMIT_BUTTON_FONT_SIZE 14

@interface LoginViewController ()
@property (strong, nonatomic) UITextField* emailField;
@property (strong, nonatomic) UITextField* passwordField;
@property (strong, nonatomic) UIButton* submitButton;
@property (strong, nonatomic) UIBarButtonItem* registerBarButton;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Login";
    _registerBarButton = ({
        UIButton* btn = [[UIButton alloc] init];
        [btn setTitle:@"Register" forState:UIControlStateNormal];
        [btn setTitleColor:UICOLOR_FROM_RGB(LVC_REG_BAR_BTN_TEXT_COLOR) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:LVC_REG_BAR_BTN_FONT_SIZE];
        [btn sizeToFit];

        [btn addTarget:self action:@selector(registerBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = buttonItem;
        buttonItem;
    });

    _emailField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.font = [UIFont systemFontOfSize:LVC_TEXT_FIELD_FONT_SIZE];
        tf.keyboardType = UIKeyboardTypeASCIICapable;
        tf.placeholder = @"E-mail";
        tf;
    });
    [self.view addSubview:_emailField];

    _passwordField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.font = [UIFont systemFontOfSize:LVC_TEXT_FIELD_FONT_SIZE];
        tf.secureTextEntry = YES;
        tf.placeholder = @"Password";
        tf;
    });
    [self.view addSubview:_passwordField];

    _submitButton = ({
        UIButton* btn = [[UIButton alloc] init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:LVC_SUBMIT_BUTTON_FONT_SIZE];
        btn.backgroundColor = UICOLOR_FROM_RGB(LVC_SUBMIT_BUTTON_BACKGROUND_COLOR);
        [btn setTitle:@"Submit" forState:UIControlStateNormal];
        [btn setBackgroundColor:UICOLOR_FROM_RGB(LVC_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT)
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
    [self.navigationItem setHidesBackButton:YES animated:NO];

    [MessageRouter addPattern:@"login-return" target:self action:@selector(loginReturn:)];
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
        constraintsWithVisualFormat:@"H:|-20-[password]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"password" : _passwordField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[btnSubmit]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"btnSubmit" : _submitButton }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-90-[email]-20-[password]-20-[btnSubmit(>=30)]"
                            options:0
                            metrics:nil
                              views:@{
                                  @"email" : _emailField,
                                  @"password" : _passwordField,
                                  @"btnSubmit" : _submitButton
                              }];
    [self.view addConstraints:constraints];
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark registerBarButton clicked
- (void)registerBarButtonClicked:(id)sender
{
    DISMISS_KEYBOARD();
    RegisterViewController* registerViewController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

#pragma mark submit button clicked
- (void)submitButtonClicked:(id)sender
{
    NSString* email = [_emailField.text trim];
    NSString* password = [_passwordField.text trim];

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

    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
    [action setObject:@"login" forPath:@"action"];
    [action setObject:email forPath:@"email"];
    [action setObject:password forPath:@"password"];
    [action setObject:[NSNumber numberWithInteger:[MOINetworkState currentState]] forPath:@"network"];

    [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
}

- (void)loginReturn:(NSDictionary*)msg
{
    DLOG(@"registerReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] == MR_RESP_ERR_CODE_NONE) {
        NSNumber* uid = [msg objectForKey:@"uid"];
        UserModel* user = [[UserModel alloc] initWithWhereCondition:@"uid=:uid" bindParams:@{ @":uid" : uid }];

        if (user._id == nil) {
            user.uid = uid;
        }

        user.nickname = [msg objectForKey:@"nickname"];
        user.token = [msg objectForKey:@"token"];
        [user setAvatarByBase64:[msg objectForKey:@"avatar"]];
        user.is_current = [NSNumber numberWithInt:1];

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
