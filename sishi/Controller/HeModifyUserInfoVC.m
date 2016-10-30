//
//  HeModifyUserInfoVC.m
//  yu
//
//  Created by Danertu on 16/10/30.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeModifyUserInfoVC.h"

@interface HeModifyUserInfoVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *modifyTextField;

@end

@implementation HeModifyUserInfoVC
@synthesize modifyTextField;

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
        label.text = @"个人资料";
        [label sizeToFit];
        self.title = @"个人资料";
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
    modifyTextField.layer.borderWidth = 1.0;
    modifyTextField.layer.borderColor = APPDEFAULTORANGE.CGColor;
    modifyTextField.layer.cornerRadius = 5.0;
    modifyTextField.layer.masksToBounds = YES;
    modifyTextField.placeholder = @"修改用户昵称";
    
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] init];
    finishItem.title = @"完成";
    finishItem.target = self;
    finishItem.action = @selector(finishEditUserInfo:);
    finishItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = finishItem;
}

- (void)finishEditUserInfo:(id)sender
{
    NSLog(@"finishEditUserInfo");
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
