//
//  HeLocationTipVC.m
//  yu
//
//  Created by Tony on 16/9/9.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeLocationTipVC.h"
#import "UIButton+Bootstrap.h"

@interface HeLocationTipVC ()
@property(strong,nonatomic)IBOutlet UIButton *settingButton;

@end

@implementation HeLocationTipVC
@synthesize settingButton;

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
        label.text = @"温馨提示";
        
        [label sizeToFit];
        self.title = @"温馨提示";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)initializaiton
{
    [super initializaiton];
    [settingButton dangerStyle];
    [settingButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:settingButton.frame.size] forState:UIControlStateNormal];
    [settingButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)initView
{
    [super initView];
}

- (IBAction)setLocationService:(id)sender
{
//    if (ISIOS10) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        return;
//    }
//    NSURL * url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
//    
//    if([[UIApplication sharedApplication] canOpenURL:url]) {
//        
//        NSURL *url =[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
//        [[UIApplication sharedApplication] openURL:url];
//        
//    }
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
