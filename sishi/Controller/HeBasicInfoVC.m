//
//  HeBasicInfoVC.m
//  yu
//
//  Created by Danertu on 16/10/21.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeBasicInfoVC.h"
#import "UIButton+Bootstrap.h"

@interface HeBasicInfoVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UITextField *nickField;
@property(strong,nonatomic)IBOutlet UIButton *enrollButton;

@end

@implementation HeBasicInfoVC
@synthesize passwordField;
@synthesize enrollButton;
@synthesize userInfoDict;
@synthesize nickField;

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
    
    [enrollButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:enrollButton.frame.size] forState:UIControlStateNormal];
    [enrollButton bootstrapStyle];
    [enrollButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    enrollButton.layer.cornerRadius = 5.0;
    enrollButton.layer.masksToBounds = YES;
}

- (IBAction)nextButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *password = passwordField.text;
    if (password == nil || [password isEqualToString:@""]) {
        [self showHint:@"请输入注册密码"];
        return;
    }
    NSString *userNick = nickField.text;
    if (userNick == nil || [userNick isEqualToString:@""]) {
        [self showHint:@"请输入用户昵称"];
        return;
    }
    
    NSString *userName = userInfoDict[@"userName"];
    NSString *userPwd = password;
    NSString *huanxid = userInfoDict[@"huanxid"];;
    NSString *enrollUrl = [NSString stringWithFormat:@"%@/user/createNewUser.action",BASEURL];
    NSDictionary *enrollParams = @{@"userName":userName,@"userPwd":userPwd,@"huanxId":huanxid,@"userNick":userNick};
    [self showHudInView:self.view hint:@"注册中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:enrollUrl params:enrollParams  success:^(AFHTTPRequestOperation* operation,id response){
//        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self registerWithAccount:huanxid password:EASEPASSWORD];
            
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"注册失败!";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)registerWithAccount:(NSString *)account password:(NSString *)password
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] registerWithUsername:account password:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hideHud];
            if (!error) {
                [self showHint:@"注册成功"];
                [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
//                TTAlertNoTitle(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
            }else{
                switch (error.code) {
                    case EMErrorServerNotReachable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                        break;
                    case EMErrorUserAlreadyExist:
                    {
                        [self showHint:@"注册成功"];
                        [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
//                        TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                        break;
                    }
                    case EMErrorNetworkUnavailable:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                        break;
                    case EMErrorServerTimeout:
                        TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                        break;
//                    case EMErrorServerServingForbidden:
//                        TTAlertNoTitle(NSLocalizedString(@"servingIsBanned", @"Serving is banned"));
//                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
                        break;
                }
            }
        });
    });
}

- (void)backToLastView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//取消输入
- (IBAction)cancelInputTap:(id)sender
{
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    if ([nickField isFirstResponder]) {
        [nickField resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
