//
//  HeLoginVC.m
//  yu
//
//  Created by HeDongMing on 16/8/27.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeLoginVC.h"
#import "UIButton+Bootstrap.h"
#import "HeEnrollVC.h"
#import "ChatDemoHelper.h"

@interface HeLoginVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UIButton *loginButton;
@property(strong,nonatomic)IBOutlet UITextField *accountField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;


@end

@implementation HeLoginVC
@synthesize loginButton;
@synthesize accountField;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"登录";
        
        [label sizeToFit];
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    [loginButton dangerStyle];
    loginButton.layer.borderWidth = 0;
    loginButton.layer.borderColor = [UIColor clearColor].CGColor;
    [loginButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:loginButton.frame.size] forState:UIControlStateNormal];
    
    accountField.layer.borderWidth = 1.0;
    accountField.layer.borderColor = [UIColor whiteColor].CGColor;
    accountField.layer.masksToBounds = YES;
    accountField.layer.cornerRadius = 5.0;
    
    passwordField.layer.borderWidth = 1.0;
    passwordField.layer.borderColor = [UIColor whiteColor].CGColor;
    passwordField.layer.masksToBounds = YES;
    passwordField.layer.cornerRadius = 5.0;
    
}

- (IBAction)loginButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *loginUrl = [NSString stringWithFormat:@"%@/user/UserLogin.action",BASEURL];
    NSString *userName = accountField.text;
    NSString *userPwd = passwordField.text;
    if (userName == nil || [userName isEqualToString:@""]) {
        [self showHint:@"请输入手机号"];
        return;
    }
    if (![Tool isMobileNumber:userName]) {
        [self showHint:@"请输入正确的手机号码"];
        return;
    }
    if (userPwd == nil || [userPwd isEqualToString:@""]) {
        [self showHint:@"请输入登录密码"];
        return;
    }
    [self showHudInView:self.view hint:@"登录中..."];
    NSDictionary *loginParams = @{@"userName":userName,@"userPwd":userPwd};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:loginUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
//        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            NSInteger userState = [[userDictInfo objectForKey:@"userState"] integerValue];
//            if (userState == 0) {
//                [self showHint:@"当前用户不可用"];
//                return ;
//            }
//            NSString *userDataPath = [Tool getUserDataPath];
//            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
//            BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
//            if (succeed) {
//                NSLog(@"用户资料写入成功");
//            }
//            User *user = [[User alloc] initUserWithDict:userDictInfo];
//            [HeSysbsModel getSysModel].user = user;
//            NSString *userId = [HeSysbsModel getSysModel].user.userId;
//            if (userId == nil) {
//                userId = @"";
//            }
            NSString *userId = userDictInfo[@"userId"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:userPwd forKey:USERPASSWORDKEY];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERIDKEY];
            [self loginWithUsername:userName password:userPwd];
//            User *userInfo = [[User alloc] initUserWithDict:userDictInfo];
//            [HeSysbsModel getSysModel].user = userInfo;
//            
            //发送自动登陆状态通知
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"登录失败!";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (IBAction)enrollButtonClick:(id)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    HeEnrollVC *enrollView = [[HeEnrollVC alloc] init];
    enrollView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:enrollView animated:YES];
}

//取消输入
- (IBAction)cancelInputTap:(id)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    
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

//环信代码
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
//    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    //异步登陆账号
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:username password:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            if (!error) {
                //设置是否自动登录
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                
                //获取数据库中数据
//                [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[EMClient sharedClient] dataMigrationTo3];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
                        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
                        [[ChatDemoHelper shareHelper] asyncPushOptions];
//                        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
                        //发送自动登陆状态通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
                        
                        //保存最近一次登录用户名
                        [weakself saveLastLoginUsername];
                    });
                });
            } else {
                switch (error.code)
                {
                        //                    case EMErrorNotFound:
                        //                        TTAlertNoTitle(error.errorDescription);
                        //                        break;
                    case EMErrorNetworkUnavailable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                        break;
                    case EMErrorServerNotReachable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                        break;
                    case EMErrorUserAuthenticationFailed:
                        TTAlertNoTitle(error.errorDescription);
                        break;
                    case EMErrorServerTimeout:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                        break;
                }
            }
        });
    });
}

#pragma  mark - private
- (void)saveLastLoginUsername
{
    NSString *username = [[EMClient sharedClient] currentUsername];
    if (username && username.length > 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:username forKey:[NSString stringWithFormat:@"em_lastLogin_username"]];
        [ud synchronize];
    }
}

- (NSString*)lastLoginUsername
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:[NSString stringWithFormat:@"em_lastLogin_username"]];
    if (username && username.length > 0) {
        return username;
    }
    return nil;
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
