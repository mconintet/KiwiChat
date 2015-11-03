//
//  AddBuddyViewController.m
//  KiwiChat
//
//  Created by hsiaosiyuan on 10/29/15.
//  Copyright © 2015 mconintet. All rights reserved.
//

#import "AddBuddyViewController.h"
#import "macro.h"
#import "UIButton+SetBackgroundColor.h"
#import "NSString+Validation.h"
#import "MOIToast.h"
#import "UserModel.h"
#import "NSMutableDictionary+Path.h"
#import "MessageRouter.h"
#import "BuddyModel.h"
#import "UserBuddyModel.h"

#define ABV_TEXT_FIELD_FONT_SIZE 14

#define ABV_SUBMIT_BUTTON_BACKGROUND_COLOR 0x366EEC
#define ABV_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT 0x2583D8
#define ABV_SUBMIT_BUTTON_FONT_SIZE 14

@interface AddBuddyViewController ()
@property (nonatomic, strong) UITextField* uidTextField;
@property (nonatomic, strong) UIButton* submitBtn;
@end

@implementation AddBuddyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _uidTextField = ({
        UITextField* tf = [[UITextField alloc] init];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.font = [UIFont systemFontOfSize:ABV_TEXT_FIELD_FONT_SIZE];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.placeholder = @"Buddy ID";
        [self.view addSubview:tf];
        tf;
    });

    _submitBtn = ({
        UIButton* btn = [[UIButton alloc] init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:ABV_SUBMIT_BUTTON_FONT_SIZE];
        btn.backgroundColor = UICOLOR_FROM_RGB(ABV_SUBMIT_BUTTON_BACKGROUND_COLOR);
        [btn setTitle:@"Submit" forState:UIControlStateNormal];
        [btn setBackgroundColor:UICOLOR_FROM_RGB(ABV_SUBMIT_BUTTON_BACKGROUND_COLOR_HIGHLIGHT) forState:UIControlStateHighlighted];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3.0f;
        [self.view addSubview:btn];
        btn;
    });

    [self setupConstraints];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSingleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];

    self.view.backgroundColor = [UIColor whiteColor];

    [MessageRouter addPattern:@"add-buddy-return" target:self action:@selector(addBuddyReturn:)];

    [_submitBtn addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupConstraints
{
    NSArray* constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[uid]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"uid" : _uidTextField }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-20-[btnSubmit]-20-|"
                            options:0
                            metrics:nil
                              views:@{ @"btnSubmit" : _submitBtn }];
    [self.view addConstraints:constraints];

    constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-90-[uid]-20-[btnSubmit(>=30)]"
                            options:0
                            metrics:nil
                              views:@{
                                  @"uid" : _uidTextField,
                                  @"btnSubmit" : _submitBtn
                              }];
    [self.view addConstraints:constraints];
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

- (void)addBuddyReturn:(NSDictionary*)msg
{
    DLOG(@"addBuddyReturn");
    NSNumber* errCode = [msg objectForKey:@"errCode"];
    DLOG(@"errCode: %@", errCode);

    if ([errCode integerValue] == MR_RESP_ERR_CODE_NONE) {
        NSDictionary* buddyDict = [msg objectForPath:@"buddy"];
        NSNumber* buddyID = [buddyDict objectForPath:@"uid"];
        BuddyModel* buddy = [BuddyModel loadByUID:buddyID];
        buddy.uid = buddyID;
        buddy.nickname = [buddyDict objectForPath:@"nickname"];
        buddy.network = [buddyDict objectForPath:@"network"];
        [buddy setAvatarByBase64:[buddyDict objectForPath:@"avatar"]];
        [buddy save];

        UserBuddyModel* ub = [UserBuddyModel loadByUID:[UserModel getCurrent].uid buddyID:buddy.uid];
        ub.uid = [UserModel getCurrent].uid;
        ub.buddyID = buddy.uid;
        [ub save];

        NSString* message = [NSString stringWithFormat:@"%@ is your friend now", buddy.nickname];
        [MOIToast successWithin:self.view
                            top:NO
                         margin:10
                          title:nil
                        message:message
                       duration:1
                        timeout:3
                     completion:nil];

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

#pragma mark submit button clicked
- (void)submitButtonClicked:(id)sender
{
    NSString* buddyId = [_uidTextField.text trim];
    if (![buddyId isDigits]) {
        [MOIToast errorWithin:self.view
                          top:NO
                       margin:10
                        title:nil
                      message:@"Please input a valid ID"
                     duration:1
                      timeout:30
                   completion:nil];
        return;
    }

    UserModel* user = [UserModel getCurrent];
    NSMutableDictionary* action = [[NSMutableDictionary alloc] init];
    [action setObject:@"add-buddy" forPath:@"action"];
    [action setObject:user.uid forPath:@"uid"];
    [action setObject:user.token forPath:@"token"];
    [action setObject:[NSNumber numberWithInteger:[buddyId integerValue]] forPath:@"buddyID"];

    [APP_DELEGATE.kwsConn.messageSender sendMessage:makeKWSMessage(action)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
