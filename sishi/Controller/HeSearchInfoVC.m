//
//  HeInfoVC.m
//  carTune
//
//  Created by HeDongMing on 16/6/18.
//  Copyright © 2016年 Jitsun. All rights reserved.
//

#import "HeSearchInfoCell.h"
#import "DCPicScrollView.h"
#import "DCWebImageManager.h"
#import "HeSearchInfoVC.h"
#import "AppDelegate.h"
#import "MLLinkLabel.h"
#import "MLLabel+Size.h"
#import "HeTopicDetailVC.h"
#import "ChatViewController.h"

#define HEADVIEWHEIGH 150
#define SCROLLTAG 300
#define LEFTVIEWTAG 200
#define LOADRECORDNUM 20

@interface HeSearchInfoVC ()<UISearchBarDelegate>
{
    NSInteger limit;
    NSInteger offset;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *userdataSource;
@property(strong,nonatomic)NSMutableArray *headerArray;
@property(strong,nonatomic)NSCache *imageCache;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;

@end

@implementation HeSearchInfoVC
@synthesize tableview;
@synthesize dataSource;
@synthesize userdataSource;
@synthesize headerArray;
@synthesize imageCache;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize searchBar;
@synthesize userLocationDict;

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
        label.text = @"搜索";
        [label sizeToFit];
        self.title = @"搜索";
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
    imageCache = [[NSCache alloc] init];
    headerArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    limit = LOADRECORDNUM;
    offset = [dataSource count];
    updateOption = 1;
    isShowLeft = NO;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    userdataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"deleteTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"distributeTopicSucceed" object:nil];
    
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:tableview];
    CGFloat itembuttonW = 25;
    CGFloat itembuttonH = 25;
    
    UIImage *searchIcon = [UIImage imageNamed:@"icon_search"];
    @try {
        itembuttonW = searchIcon.size.width / searchIcon.size.height * itembuttonH;
    } @catch (NSException *exception) {
        itembuttonW = 25;
    } @finally {
        
    }
    
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"搜索话题、用户";
    self.navigationItem.titleView = searchBar;
    
//    [searchBar becomeFirstResponder];
    
//    [self pullUpUpdate];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"chatUserEvent"]) {
        NSString *chatID = userInfo[@"huanxId"];
        NSString *nick = userInfo[@"nick"];
        ChatViewController *chatView = [[ChatViewController alloc] initWithConversationChatter:chatID conversationType:EMConversationTypeChat];
        chatView.title = nick;
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
        return;
    }
    else if ([eventName isEqualToString:@"upDownButtonClick"]){
        [self upDownButtonClickWithDict:userInfo];
        return;
    }
    [super routerEventWithName:eventName userInfo:userInfo];
}

- (void)deleteTopicSucceed:(NSNotification *)notification
{
    updateOption = 1;
    [self searchTopicWithKey:searchBar.text];
}

- (void)distributeTopicSucceed:(NSNotification *)notification
{
    updateOption = 1;
    [self searchTopicWithKey:searchBar.text];
}

- (void)upDownButtonClickWithDict:(NSDictionary *)dict
{
    NSString *upDownUrl = [NSString stringWithFormat:@"%@/UpOrDown/insertUd.action",BASEURL];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:upDownUrl params:dict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            if (updateOption == 1) {
                [dataSource removeAllObjects];
            }
            //            NSArray *resultArray = [respondDict objectForKey:@"json"];
            //            if ([resultArray isMemberOfClass:[NSNull class]]) {
            //                return;
            //            }
            updateOption = 1;
            [self searchUserWithKey:searchBar.text];
            //            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                // *** 将UI操作放到主线程中执行 ***
            //                [self.tableview reloadData];
            //                return ;
            //            });
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)searchTopicWithKey:(NSString *)keyword
{
    self.navigationItem.titleView = searchBar;
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/AllTopicKeyword.action",BASEURL];
    
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userId,@"keyword":keyword};
    [self showHudInView:self.tableview hint:@"正在搜索..."];
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
            if (![resultArray isMemberOfClass:[NSNull class]]) {
                for (NSDictionary *zoneDict in resultArray) {
                    [dataSource addObject:zoneDict];
                }
            }
            //            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // *** 将UI操作放到主线程中执行 ***
                [self.tableview reloadData];
                return ;
            });
            
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)searchUserWithKey:(NSString *)keyword
{
    self.navigationItem.titleView = searchBar;
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/selectuserbykeword.action",BASEURL];
    
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userId,@"keyword":keyword};
//    [self showHudInView:self.tableview hint:@"正在搜索..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
//        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            if (updateOption == 1) {
                [userdataSource removeAllObjects];
            }
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if (![resultArray isMemberOfClass:[NSNull class]]) {
                for (NSDictionary *zoneDict in resultArray) {
                    [userdataSource addObject:zoneDict];
                }
            }
            //            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // *** 将UI操作放到主线程中执行 ***
                [self.tableview reloadData];
                return ;
            });
            
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)addFooterView
{
    if (tableview.contentSize.height >= SCREENHEIGH) {
        [self pullDownUpdate];
    }
}

-(void)pullUpUpdate
{
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableview.bounds.size.height, SCREENWIDTH, self.tableview.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableview addSubview:refreshHeaderView];
    [refreshHeaderView refreshLastUpdatedDate];
}
-(void)pullDownUpdate
{
    if (refreshFooterView == nil) {
        self.refreshFooterView = [[EGORefreshTableFootView alloc] init];
    }
    refreshFooterView.frame = CGRectMake(0, tableview.contentSize.height, SCREENWIDTH, 650);
    refreshFooterView.delegate = self;
    [tableview addSubview:refreshFooterView];
    [refreshFooterView refreshLastUpdatedDate];
    
}

- (void)updateInfo:(NSNotification *)notificaition
{
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
    limit = 20;
    offset = 0;
    NSLog(@"searchKey = %@",searchKey);
//    [self loadInfoDataWithKey:searchKey];
    [self searchTopicWithKey:searchKey];
    [self searchUserWithKey:searchKey];
}

- (void)loadInfoDataWithKey:(NSString *)searchKey
{
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    
    [self loadInfoDataWithKey:searchBar.text];
    [self updateDataSource];
}

-(void)updateDataSource
{
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];//视图的数据下载完毕之后，开始刷新数据
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    switch (updateOption) {
        case 1:
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableview];
            break;
        case 2:
            [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:tableview];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //刚开始拖拽的时候触发下载数据
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
}

/*******************Foot*********************/
#pragma mark -
#pragma mark EGORefreshTableFootDelegate Methods
- (void)egoRefreshTableFootDidTriggerRefresh:(EGORefreshTableFootView*)view
{
    updateOption = 2;//加载历史标志
    offset = [dataSource count] + [headerArray count];
    limit = LOADRECORDNUM;
    @try {
        
    }
    @catch (NSException *exception) {
        //抛出异常不应当处理dateline
    }
    @finally {
        [self reloadTableViewDataSource];//触发刷新，开始下载数据
    }
}
- (BOOL)egoRefreshTableFootDataSourceIsLoading:(EGORefreshTableFootView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}
- (NSDate*)egoRefreshTableFootDataSourceLastUpdated:(EGORefreshTableFootView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

/*******************Header*********************/
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    updateOption = 1;//刷新加载标志
    limit = [dataSource count]; //保持不变，刷新原来的所有记录
    offset = 0;
    @try {
        
    }
    @catch (NSException *exception) {
        //抛出异常不应当处理dateline
    }
    @finally {
        [self reloadTableViewDataSource];//触发刷新，开始下载数据
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([dataSource count] > 0) {
            return [dataSource count];
        }
    }
    return [userdataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num = 0;
    if ([dataSource count] > 0) {
        num++;
    }
    if ([userdataSource count] > 0) {
        num++;
    }
    return num;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    if ([dataSource count] > 0 && section == 0) {
        static NSString *cellIndentifier = @"HeDiscoverTableCell";
        
        NSDictionary *dict = nil;
        @try {
            dict = [dataSource objectAtIndex:row];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        HeDiscoverTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[HeDiscoverTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.topicDict = dict;
        id topicCreatetimeObj = [dict objectForKey:@"topicCreatetime"];
        if ([topicCreatetimeObj isMemberOfClass:[NSNull class]] || topicCreatetimeObj == nil) {
            NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
            topicCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
        }
        long long topicCreatetimeStamp = [topicCreatetimeObj longLongValue];
        NSString *topicCreatetime = [NSString stringWithFormat:@"%lld",topicCreatetimeStamp];
        NSString *timeTips = [Tool compareCurrentTime:topicCreatetime];
        
        cell.timeLabel.text = timeTips;
        
        id udcountNum = dict[@"udcountNum"];
        if ([udcountNum isMemberOfClass:[NSNull class]]) {
            udcountNum = @"";
        }
        cell.rankNumLabel.text = [NSString stringWithFormat:@"%ld",[udcountNum integerValue]];
        
        NSString *nick = dict[@"nick"];
        if ([nick isMemberOfClass:[NSNull class]] || nick == nil) {
            nick = @"";
        }
        cell.nameLabel.text = nick;
        
        NSString *img = dict[@"img"];
        NSString *imgKey = [NSString stringWithFormat:@"%@_%ld",img,row];
        UIImageView *imageView = [imageCache objectForKey:imgKey];
        if (imageView == nil) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,img];
            [cell.disCoverImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:cell.disCoverImage.image];
            imageView = cell.disCoverImage;
            [imageCache setObject:imageView forKey:imgKey];
        }
        cell.disCoverImage = imageView;
        [cell.imageInfoBg addSubview:imageView];
        
        NSString *content = dict[@"content"];
        if ([content isMemberOfClass:[NSNull class]] || content == nil) {
            content = @"";
        }
        if ([content isMemberOfClass:[NSNull class]] || content == nil) {
            content = @"";
        }
        CGFloat maxWidth = SCREENWIDTH - 20;
        UIFont *font = [UIFont systemFontOfSize:15.0];
        CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
        if (size.height < 40) {
            size.height = 40;
        }
        
        CGRect contentFrame = cell.contentTextInfoBg.frame;
        contentFrame.size.height = size.height;
        CGRect contentLabelFrame = cell.contentLabel.frame;
        contentLabelFrame.size.height = size.height;
        
        cell.contentTextInfoBg.frame = contentFrame;
        cell.contentLabel.frame = contentLabelFrame;
        cell.contentLabel.text = content;
        
        [cell updateFrame];
        return cell;
    }
    NSDictionary *dict = nil;
    @try {
        dict = [userdataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSString *userNick = dict[@"userNick"];
    static NSString *cellIndentifier = @"UserHeBaseTableViewCell";
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = userNick;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if ([dataSource count] > 0 && section == 0) {
        NSDictionary *dict = nil;
        @try {
            dict = [dataSource objectAtIndex:row];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        NSString *content = dict[@"content"];
        if ([content isMemberOfClass:[NSNull class]] || content == nil) {
            content = @"";
        }
        CGFloat maxWidth = SCREENWIDTH - 20;
        UIFont *font = [UIFont systemFontOfSize:15.0];
        CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
        if (size.height < 40) {
            size.height = 40;
        }
        CGFloat imageW = SCREENWIDTH;
        CGFloat imageH = imageW * 0.618;
        NSString *img = dict[@"img"];
        if ([img isMemberOfClass:[NSNull class]] || img == nil || [img hasSuffix:@"null"]) {
            img = @"";
        }
        if ([img isEqualToString:@""]) {
            return 250 + (size.height - 40) + (SCREENWIDTH * 0.618 - 120) - imageH;
        }
        return 250 + (size.height - 40) + (SCREENWIDTH * 0.618 - 120);
    }
    
    
    return 50.0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if ([dataSource count] > 0 && section == 0) {
        NSDictionary *dict = nil;
        @try {
            dict = dataSource[row];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        HeTopicDetailVC *topicDetailVC = [[HeTopicDetailVC alloc] init];
        topicDetailVC.topicDetailDict = [[NSDictionary alloc] initWithDictionary:dict];
        topicDetailVC.locationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
        topicDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topicDetailVC animated:YES];
        return;
    }
    NSDictionary *userInfo = nil;
    @try {
        userInfo = [userdataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSString *chatID = userInfo[@"huanxId"];
    NSString *nick = userInfo[@"userNick"];
    ChatViewController *chatView = [[ChatViewController alloc] initWithConversationChatter:chatID conversationType:EMConversationTypeChat];
    chatView.title = nick;
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if ([dataSource count] > 0) {
                return @"相关话题";
            }
            if ([userdataSource count] > 0) {
                return @"相关用户";
            }
            break;
        }
        case 1:
        {
            return @"相关用户";
            break;
        }
        default:
            break;
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
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
