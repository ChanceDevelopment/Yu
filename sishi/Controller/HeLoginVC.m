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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
