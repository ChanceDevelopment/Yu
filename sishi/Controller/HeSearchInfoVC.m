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

#define HEADVIEWHEIGH 150
#define SCROLLTAG 300
#define LEFTVIEWTAG 200
#define LOADRECORDNUM 20

@interface HeSearchInfoVC ()<UISearchBarDelegate>
{
    NSInteger limit;
    NSInteger offset;
}
@property(strong,nonatomic)IBOutlet UITableView *infoTable;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *userdataSource;
@property(strong,nonatomic)NSMutableArray *headerArray;
@property(strong,nonatomic)NSCache *imageCache;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;

@end

@implementation HeSearchInfoVC
@synthesize infoTable;
@synthesize dataSource;
@synthesize userdataSource;
@synthesize headerArray;
@synthesize imageCache;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize searchBar;

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
    
    isShowLeft = NO;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:infoTable];
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
    
    [searchBar becomeFirstResponder];
    
    [self pullUpUpdate];
}

- (void)addFooterView
{
    if (infoTable.contentSize.height >= SCREENHEIGH) {
        [self pullDownUpdate];
    }
}

-(void)pullUpUpdate
{
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.infoTable.bounds.size.height, SCREENWIDTH, self.infoTable.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [infoTable addSubview:refreshHeaderView];
    [refreshHeaderView refreshLastUpdatedDate];
}
-(void)pullDownUpdate
{
    if (refreshFooterView == nil) {
        self.refreshFooterView = [[EGORefreshTableFootView alloc] init];
    }
    refreshFooterView.frame = CGRectMake(0, infoTable.contentSize.height, SCREENWIDTH, 650);
    refreshFooterView.delegate = self;
    [infoTable addSubview:refreshFooterView];
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
    [self loadInfoDataWithKey:searchKey];
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
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
            break;
        case 2:
            [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
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
    return 1;
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
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    static NSString *cellIndentifier = @"HeSearchInfoCell";
    HeSearchInfoCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeSearchInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellsize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100.0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[section];
    } @catch (NSException *exception) {
        
    } @finally {
        
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
