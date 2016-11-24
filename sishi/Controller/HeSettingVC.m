//
//  HeSettingVC.m
//  yu
//
//  Created by Danertu on 16/10/21.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeSettingVC.h"
#import "UIButton+Bootstrap.h"
#import "HeFeedbackVC.h"
#import "HeModifyUserInfoVC.h"
#import "HeBlockUserVC.h"
#import "HeChatBlockUserVC.h"

@interface HeSettingVC ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UIButton *logOutButton;


@end

@implementation HeSettingVC
@synthesize dataSource;
@synthesize tableview;
@synthesize logOutButton;

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
        label.text = @"设置";
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getUserInfo];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"昵称",@"手机号",@"清理缓存",@"意见反馈",@"联系我们",@"话题黑名单",@"聊天黑名单"]];
}

- (void)initView
{
    [super initView];
    
    [Tool setExtraCellLineHidden:tableview];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];

}

- (void)getUserInfo
{
    NSString *getUserUrl = [NSString stringWithFormat:@"%@/user/getUserInfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestParams = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserUrl params:requestParams  success:^(AFHTTPRequestOperation* operation,id response){
        //        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            User *userInfo = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = userInfo;
            
            [self.tableview reloadData];
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

- (IBAction)logOutButtonClick:(id)sender
{
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定退出登录?" preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self loginOut];
        }];
        
        
        // Add the actions.
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定退出登录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self loginOut];
    }
}
- (void)loginOut
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERACCOUNTKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERPASSWORDKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    return;
    [self showHudInView:self.view hint:@"正在注销..."];
    NSString *logoutUrl = [NSString stringWithFormat:@"%@/user/quit.action",BASEURL];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:logoutUrl params:nil success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        id result = [respondDict objectForKey:@"success"];
        if ([result isMemberOfClass:[NSNull class]] || result == nil) {
            result = @"";
        }
        if ([result isKindOfClass:[NSString class]]) {
            if ([result compare:@"true" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
                [self showHint:@"注销用户失败，请稍后再试!"];
                return;
            }
        }
        else{
            if (![result boolValue]) {
                [self showHint:@"注销用户失败，请稍后再试!"];
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERACCOUNTKEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERPASSWORDKEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
        NSNotification *notification = [[NSNotification alloc] initWithName:@"loginSucceed" object:self userInfo:@{LOGINKEY:@NO}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[dataSource objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeUserCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *string = nil;
    @try {
        string = dataSource[section][row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",string];
    
    NSString *rightContent = @"";
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                {
                    CGFloat labelW = 200;
                    CGFloat labelH = cellSize.height;
                    CGFloat labelY = 0;
                    CGFloat labelX = SCREENWIDTH - labelW - 30;
                    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
                    contentLabel.backgroundColor = [UIColor clearColor];
                    contentLabel.textColor = [UIColor grayColor];
                    contentLabel.font = [UIFont systemFontOfSize:15.0];
                    contentLabel.textAlignment = NSTextAlignmentRight;
                    [cell addSubview:contentLabel];
                    rightContent = [HeSysbsModel getSysModel].user.userNick;
                    contentLabel.text = rightContent;
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1:
                {
                    CGFloat labelW = 200;
                    CGFloat labelH = cellSize.height;
                    CGFloat labelY = 0;
                    CGFloat labelX = SCREENWIDTH - labelW - 30;
                    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
                    contentLabel.backgroundColor = [UIColor clearColor];
                    contentLabel.textColor = [UIColor grayColor];
                    contentLabel.font = [UIFont systemFontOfSize:15.0];
                    contentLabel.textAlignment = NSTextAlignmentRight;
                    [cell addSubview:contentLabel];
                    rightContent = [HeSysbsModel getSysModel].user.huanxId;
                    contentLabel.text = rightContent;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                {
                    HeModifyUserInfoVC *modifyUserInfoVC = [[HeModifyUserInfoVC alloc] init];
                    modifyUserInfoVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:modifyUserInfoVC animated:YES];
                    break;
                }
                case 2:
                {
                    [self showHint:@"清理成功"];
                    break;
                }
                case 3:
                {
                    HeFeedbackVC *feedBackVC = [[HeFeedbackVC alloc] init];
                    feedBackVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:feedBackVC animated:YES];
                    break;
                }
                case 4:
                {
                    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请发邮件至 327993669@qq.com" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [alertview show];
                    break;
                }
                case 5:{
                    HeBlockUserVC *blockUserVC = [[HeBlockUserVC alloc] init];
                    blockUserVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:blockUserVC animated:YES];
                    break;
                }
                case 6:{
                    HeChatBlockUserVC *blockUserVC = [[HeChatBlockUserVC alloc] init];
                    blockUserVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:blockUserVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
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
