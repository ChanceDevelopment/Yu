//
//  HeEnrollView.m
//  huobao
//
//  Created by Tony He on 14-5-13.
//  Copyright (c) 2014年 何 栋明. All rights reserved.
//

#import "HeEnrollView.h"
#import <SMS_SDK/SMSSDK.h>

@interface HeEnrollView ()

@end

@implementation HeEnrollView
@synthesize accountTF;
@synthesize getCheckCodeButton;
@synthesize loadSucceedFlag;
@synthesize protocolDetailLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"注  册";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.9) {
        self.navigationController.navigationBar.tintColor = [UIColor redColor];
    }
    else{
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self initializaiton];
    [self initView];
}

-(void)initializaiton
{
    UIView *spaceView = [[UIView alloc]init];
    spaceView.frame = CGRectMake(20, 0, 60, 40);
    
    UIImageView *accountSpaceView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phoneIcon.png"]];
    accountSpaceView.frame = CGRectMake(20, 5, 30, 30);
    [spaceView addSubview:accountSpaceView];
    
    [accountTF setLeftView:spaceView];
    [accountTF setLeftViewMode:UITextFieldViewModeAlways];
    
    
    accountTF.delegate = self;
    [getCheckCodeButton infoStyle];
    getCheckCodeButton.layer.borderColor = [[UIColor clearColor] CGColor];
    getCheckCodeButton.layer.borderWidth = 0;
    
    protocolDetailLabel.textColor = [UIColor blueColor];
    protocolDetailLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *scanProtocolGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserProtocol:)];
    scanProtocolGes.numberOfTapsRequired = 1;
    scanProtocolGes.numberOfTouchesRequired = 1;
    [protocolDetailLabel addGestureRecognizer:scanProtocolGes];
}

-(void)initView
{
    
}

/****取出首尾的空格****/
-(NSString *)trim:(NSString*)string
{
    NSString *trimString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimString;
}

//判断账号是否合法
-(BOOL)isAccountVaild:(NSString *)accountStr
{
    NSString *trimString = [self trim:accountStr];
    const char *account = [trimString UTF8String];
    NSInteger length = [trimString length];
    if ([accountStr isEqualToString:@""]) {
        [self showHint:@"账号不能为空"];
        return NO;
    }
    if (length != 11) {
        [self showHint:@"注册手机号格式有误"];
        return NO;
    }
    for (int i = 0; i<length; i++) {
        if (*(account+i)<48 || *(account+i) >57) {
            [self showHint:@"注册手机号格式有误"];
            return NO;
        }
    }
    return YES;
}


//判断密码是否合法
-(BOOL)isPasswordVaild:(NSString *)passwordstr
{
    NSString *trimString = [self trim:passwordstr];
    NSInteger length = [trimString length];
    if ([passwordstr isEqualToString:@""]) {
        [self showHint:@"密码不能为空"];
        return NO;
    }
    if (length < 6) {
        [self showHint:@"密码不能小于6位"];
        return NO;
    }
    return YES;
}

-(IBAction)enrollButtonClick:(id)sender
{
    if ([accountTF isFirstResponder]) {
        [accountTF resignFirstResponder];
    }
    NSString *error = [Tool checkRegisterAccount:accountTF.text];
    if (error) {
        [self showHint:error];
        return;
    }
    [self showHudInView:self.view hint:@"正在获取验证码"];
    [self performSelector:@selector(getcheckCode:) withObject:nil afterDelay:0.2];
    
}

-(void)scanUserProtocol:(id)sender
{
//    NSString *websiteUrl = @"http://huobao.us/index.php/huobao/userProtocol/index";
//    BrowserView *userProtocolVC = [[BrowserView alloc] initWithWebSite:websiteUrl];
//    userProtocolVC.navigationItem.backBarButtonItem.title = @"返回";
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont boldSystemFontOfSize:20.0];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    userProtocolVC.navigationItem.titleView = label;
//    label.text = @"活宝产品使用协议";
//    [label sizeToFit];
//    
//    userProtocolVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:userProtocolVC animated:YES];
}

-(void)getcheckCode:(id)sender
{
//    //获取注册手机号的验证码
//    NSString *zone = @"86"; //区域号
//    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:accountTF.text
//                                   zone:zone
//                       customIdentifier:nil
//                                 result:^(NSError *error)
//     {
//         [self hideHud];
//         if (!error)
//         {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 // *** 将UI操作放到主线程中执行 ***
//                 HeCommitView *commitView = [[HeCommitView alloc] initWithDic:nil];
//                 commitView.phoneStr = [[NSString alloc] initWithString:accountTF.text];
//                 commitView.hidesBottomBarWhenPushed = YES;
//                 [self.navigationController pushViewController:commitView animated:YES];
//                 return ;
//             });
//         }
//         else
//         {
//             NSString *errorString = [NSString stringWithFormat:@"错误描述：%@",[error.userInfo objectForKey:@"getVerificationCode"]];
//             [self showHint:errorString];
//         }
//     }];
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) {
        if (range.location >= 11) {
            return NO;
        }
    }
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
