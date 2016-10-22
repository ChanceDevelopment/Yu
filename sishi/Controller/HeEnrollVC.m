//
//  HeEnrollVC.m
//  huayoutong
//
//  Created by Tony on 16/3/24.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//  注册界面

#import "HeEnrollVC.h"
#import "UIButton+Bootstrap.h"
#import <SMS_SDK/SMSSDK.h>
#import "HeBasicInfoVC.h"

@interface HeEnrollVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *phoneField;
@property(strong,nonatomic)IBOutlet UITextField *verifyCodeField;
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
@property(strong,nonatomic)IBOutlet UIButton *nextButton;
@property(strong,nonatomic)NSString *correctVerifyCode;   //服务器发送过来的验证码

@end

@implementation HeEnrollVC
@synthesize phoneField;
@synthesize verifyCodeField;
@synthesize getCodeButton;
@synthesize nextButton;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"注册账号";
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    
    [getCodeButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:getCodeButton.frame.size] forState:UIControlStateNormal];
    [getCodeButton bootstrapStyle];
    [getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getCodeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    
    
    [nextButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:nextButton.frame.size] forState:UIControlStateNormal];
    [nextButton bootstrapStyle];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


//取消输入
- (IBAction)cancelInputTap:(id)sender
{
    if ([phoneField isFirstResponder]) {
        [phoneField resignFirstResponder];
    }
    if ([verifyCodeField isFirstResponder]) {
        [verifyCodeField resignFirstResponder];
    }
    
}

//获取验证码
- (IBAction)verifyButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *userPhone = phoneField.text;
    if ((userPhone == nil || [userPhone isEqualToString:@""])) {
        [self showHint:@"请输入手机号"];
        return;
    }
    if (![Tool isMobileNumber:userPhone]) {
        [self showHint:@"请输入正确的手机号"];
        return;
    }
    
    [self myTimer];
    //获取注册手机号的验证码
    NSString *zone = @"86"; //区域号
    NSString *phoneNumber = phoneField.text;
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber
                                       zone:zone
                           customIdentifier:nil
                                     result:^(NSError *error)
    {
        [self hideHud];
        if (!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                     // *** 将UI操作放到主线程中执行 ***
                     
                     return ;
            });
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"错误描述：%@",[error.userInfo objectForKey:@"getVerificationCode"]];
            [self showHint:errorString];
        }
    }];
}

- (IBAction)nextButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *userPhone = phoneField.text;
    NSString *verifyCode = verifyCodeField.text;
    if (userPhone == nil || [userPhone isEqualToString:@""]) {
        [self showHint:@"请输入注册手机号"];
        return;
    }
    if (![Tool isMobileNumber:userPhone]) {
        [self showHint:@"输入的手机号格式有误"];
        return;
    }
    if (verifyCode == nil || [verifyCode isEqualToString:@""]) {
        [self showHint:@"请输入手机验证码"];
        return;
    }
    //用户输入的手机验证码
    [self showHudInView:self.view hint:@"验证中..."];
    NSString *zone = @"86"; //区域号
        
    [SMSSDK commitVerificationCode:verifyCode phoneNumber:userPhone zone:zone result:^(SMSSDKUserInfo *userInfo, NSError *error) {
        [self hideHud];
        if (error) {
            [self showHint:@"验证码有误"];
        }
        else{
            //验证码验证成功
            HeBasicInfoVC *basicInfoVC = [[HeBasicInfoVC alloc] init];
            basicInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:basicInfoVC animated:YES];
        }
    }];
}

//我的倒计时
-(void)myTimer
{
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                [getCodeButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                [getCodeButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                self.getCodeButton.enabled = YES;
                [self.getCodeButton setTitle:@"重  发" forState:UIControlStateNormal];
            });
        }else{
            self.getCodeButton.enabled = NO;
            
            int seconds = timeout % 60;
            if (seconds == 0) {
                seconds = 60;
            }
            NSString *strTime = [NSString stringWithFormat:@"%d秒",seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.getCodeButton setTitle:strTime forState:UIControlStateNormal];
                [self.getCodeButton setTitle:strTime forState:UIControlStateHighlighted];
                [self.getCodeButton setTitle:strTime forState:UIControlStateSelected];
                [self.getCodeButton setTitle:strTime forState:UIControlStateDisabled];
                
                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
                
                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
                
                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
                
                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
