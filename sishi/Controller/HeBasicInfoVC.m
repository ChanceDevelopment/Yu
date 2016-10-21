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
@property(strong,nonatomic)IBOutlet UIButton *enrollButton;

@end

@implementation HeBasicInfoVC
@synthesize passwordField;
@synthesize enrollButton;

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
}

- (IBAction)nextButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *password = passwordField.text;
    if (password == nil || [password isEqualToString:@""]) {
        [self showHint:@"请输入注册密码"];
        return;
    }
    
    
}

//取消输入
- (IBAction)cancelInputTap:(id)sender
{
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
