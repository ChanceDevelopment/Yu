//
//  HeBlockUserVC.m
//  beautyContest
//
//  Created by Tony on 2016/11/17.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBlockUserVC.h"
#import "HeBaseTableViewCell.h"
#import "UIButton+Bootstrap.h"

@interface HeBlockUserVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeBlockUserVC
@synthesize tableview;
@synthesize dataSource;

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
        label.text = @"黑名单";
        [label sizeToFit];
        
        self.title = @"黑名单";
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
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,userId];
    NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
    [dataSource addObjectsFromArray:blockArray];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Tool setExtraCellLineHidden:tableview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeUserFollowTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *userNick = dict[@"userNick"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",userNick];
    
    CGFloat buttonW = 100;
    CGFloat buttonH = 30;
    CGFloat buttonY = (cellSize.height - buttonH) / 2.0;
    CGFloat buttonX = cellSize.width - buttonW - 20;
    UIButton *removeButton = [[UIButton alloc] init];
    [removeButton addTarget:self action:@selector(removeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    removeButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    [removeButton dangerStyle];
    [removeButton.titleLabel setFont:[UIFont systemFontOfSize:13.5]];
    [removeButton setTitle:@"移出黑名单" forState:UIControlStateNormal];
    
    
    removeButton.tag = row;
    [cell addSubview:removeButton];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
}

- (void)removeButtonClick:(UIButton *)button
{
    NSInteger row = button.tag;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,userId];
    NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:blockArray];
    NSString *blockUserId = dict[@"userId"];
    if ([blockUserId isMemberOfClass:[NSNull class]]) {
        blockUserId = @"";
    }
    for (NSDictionary *userDict in mutableArray) {
        NSString *userid = userDict[@"userId"];
        if ([userid isMemberOfClass:[NSNull class]]) {
            userid = @"";
        }
        if ([userid isEqualToString:blockUserId]) {
            [mutableArray removeObject:userDict];
            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:blockKey];
    dataSource = [[NSMutableArray alloc] initWithArray:mutableArray];
    [tableview reloadData];
    [self showHint:@"成功移出"];
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
