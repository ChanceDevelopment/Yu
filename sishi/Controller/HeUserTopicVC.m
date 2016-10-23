//
//  HeTopicVC.m
//  yu
//
//  Created by HeDongMing on 2016/10/21.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeUserTopicVC.h"
#import "HeDiscoverTableCell.h"
#import "ChatViewController.h"
#import "HeDistributeTopicVC.h"
#import "HeTopicDetailVC.h"
#import "MJRefresh.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "MLLabel+Size.h"
#import "MLLinkLabel.h"
#import "HeCommentCell.h"

@interface HeUserTopicVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(assign,nonatomic)NSInteger pageNo;

@end

@implementation HeUserTopicVC
@synthesize tableview;
@synthesize dataSource;
@synthesize pageNo;

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
        label.text = @"我的话题";
        
        [label sizeToFit];
        self.title = @"我的话题";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self loadNearbyUserShow:YES];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"deleteTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"distributeTopicSucceed" object:nil];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    //    [self pullUpUpdate];
    
    UIView *footerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    self.tableview.tableFooterView = footerview;
    
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block,刷新
        [self.tableview.header performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        updateOption = 1;
        pageNo = 0;
        [self loadNearbyUserShow:YES];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
        updateOption = 2;
        pageNo++;
        [self loadNearbyUserShow:YES];
    }];
}

- (void)endRefreshing
{
    [self.tableview.footer endRefreshing];
    self.tableview.footer.hidden = YES;
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.tableview.footer.automaticallyHidden = YES;
        self.tableview.footer.hidden = NO;
        // 进入刷新状态后会自动调用这个block，加载更多
        
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }];
}

- (void)deleteTopicSucceed:(NSNotification *)notification
{
    updateOption = 1;
    [self loadNearbyUserShow:NO];
}

- (void)distributeTopicSucceed:(NSNotification *)notification
{
    updateOption = 1;
    [self loadNearbyUserShow:NO];
}

- (void)loadNearbyUserShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/HistoryTopic.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":userid,@"pageNum":pageNum};
    if (show) {
        [self showHudInView:self.view hint:@"正在获取..."];
    }
    
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            if (updateOption == 1) {
                [dataSource removeAllObjects];
            }
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                return;
            }
            for (NSDictionary *zoneDict in resultArray) {
                [dataSource addObject:zoneDict];
            }
            //            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // *** 将UI操作放到主线程中执行 ***
                [self.tableview reloadData];
                return ;
            });
            
        }
        else{
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if (updateOption == 2 && [resultArray count] == 0) {
                pageNo--;
                return;
            }
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
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
    
    static NSString *cellIndentifier = @"HeTopicDetailCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    
    @try {
        dict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    HeCommentCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *userNick = dict[@"nick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.nameLabel.text = userNick;
    
    id topicCreatetimeObj = [dict objectForKey:@"topicCreatetime"];
    if ([topicCreatetimeObj isMemberOfClass:[NSNull class]] || topicCreatetimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        topicCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long topicCreatetimeStamp = [topicCreatetimeObj longLongValue];
    NSString *topicCreatetime = [NSString stringWithFormat:@"%lld",topicCreatetimeStamp];
    NSString *timeTips = [Tool compareCurrentTime:topicCreatetime];
    
    cell.timeLabel.text = timeTips;
    
    NSString *content = dict[@"content"];
    if ([content isMemberOfClass:[NSNull class]] || content == nil) {
        content = @"";
    }
    CGFloat maxWidth = SCREENWIDTH - 20;
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
    if (size.height < 25) {
        size.height = 25;
    }
    cell.contentLabel.text = content;
    
    CGRect contentFrame = cell.contentLabel.frame;
    contentFrame.size.height = size.height;
    cell.contentLabel.frame = contentFrame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    NSDictionary *dict = nil;
    dict = [dataSource objectAtIndex:row];
    NSString *content = dict[@"content"];
    if ([content isMemberOfClass:[NSNull class]] || content == nil) {
        content = @"";
    }
    CGFloat maxWidth = SCREENWIDTH - 20;
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
    if (size.height < 25) {
        size.height = 25;
    }
    
    return 60 + size.height - 25;;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeTopicDetailVC *topicDetailVC = [[HeTopicDetailVC alloc] init];
    topicDetailVC.topicDetailDict = [[NSDictionary alloc] initWithDictionary:dict];
    topicDetailVC.locationDict = [[NSDictionary alloc] initWithDictionary:[HeSysbsModel getSysModel].userLocationDict];
    topicDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:topicDetailVC animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"distributeTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteTopicSucceed" object:nil];
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
