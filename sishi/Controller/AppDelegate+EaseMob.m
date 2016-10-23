/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate+EaseMob.h"
#import "ApplyViewController.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"
#import "JPUSHService.h"
#import "HeRootSegmentVC.h"
#import "HeLoginVC.h"

/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:appkey
                                         apnsCertName:apnsCertName
                                          otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES],@"easeSandBox":[NSNumber numberWithBool:NO]}];
    
    [ChatDemoHelper shareHelper];
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    BOOL haveLogin = (userToken == nil) ? NO : YES;
    
    if (loginSuccess && haveLogin) {//登陆成功加载主窗口控制器
        //加载申请通知的数据
        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
        
        UIImage *navBackgroundImage = [UIImage imageNamed:@"NavBarIOS7"];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:20.0], NSFontAttributeName, nil]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        HeRootSegmentVC *tabBarVC = [[HeRootSegmentVC alloc] init];
        
        //        tabBarVC.underLineColor = [UIColor whiteColor];
        CustomNavigationController *rootNavigationVC = [[CustomNavigationController alloc] initWithRootViewController:tabBarVC];
        self.viewController = rootNavigationVC;
        
        
        [ChatDemoHelper shareHelper].mainVC = tabBarVC;
        
        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
        [[ChatDemoHelper shareHelper] asyncPushOptions];
    }
    else{//登陆失败加载登陆页面控制器
        HeLoginVC *loginVC = [[HeLoginVC alloc] init];
        CustomNavigationController *loginNav = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
        self.viewController = loginNav;
//        if (self.mainController) {
//            [self.mainController.navigationController popToRootViewControllerAnimated:NO];
//        }
//        self.mainController = nil;
//        [ChatDemoHelper shareHelper].mainVC = nil;
//        
//        LoginViewController *loginController = [[LoginViewController alloc] init];
//        navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
//        [self clearParse];
    }
    
//    //设置7.0以下的导航栏
//    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0){
//        navigationController.navigationBar.barStyle = UIBarStyleDefault;
//        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleBar"]
//                                                 forBarMetrics:UIBarMetricsDefault];
//        [navigationController.navigationBar.layer setMasksToBounds:YES];
//    }
    
    self.window.rootViewController = self.viewController;
}

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Required
    //IOS6.0上面接收到推送的时候执行的方法
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS6及以下系统，收到通知:%@", userInfo);
    
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
