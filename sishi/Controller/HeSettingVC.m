//
//  HeSettingVC.m
//  yu
//
//  Created by Danertu on 16/10/21.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeSettingVC.h"
#import "UIButton+Bootstrap.h"

@interface HeSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)NSArray *dataSource;

@end

@implementation HeSettingVC
@synthesize dataSource;

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
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@"昵称",@"手机号",@"清理缓存",@"意见反馈",@"联系我们"];
}

- (void)initView
{
    [super initView];
    
    CGFloat buttonX = 30;
    CGFloat buttonW = SCREENWIDTH - 2 * buttonX;
    CGFloat buttonH = 35;
    CGFloat buttonY = 5;
    
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [logoutButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:logoutButton.frame.size] forState:UIControlStateNormal];
    [logoutButton bootstrapStyle];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    cell.textLabel.text = [NSString stringWithFormat:@"          %@",string];
    
    
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
