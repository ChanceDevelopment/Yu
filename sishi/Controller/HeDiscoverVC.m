//
//  HeNearbyVC.m
//  beautyContest
//
//  Created by Tony on 16/8/3.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeDiscoverVC.h"
#import "HeDiscoverTableCell.h"
#import "ChatViewController.h"
#import "HeDistributeTopicVC.h"
#import "HeTopicDetailVC.h"
#import "MJRefresh.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "MLLabel+Size.h"
#import "MLLinkLabel.h"

#define MinLocationSucceedNum 1   //要求最少成功定位的次数

#define ALERTTAG 200

@interface HeDiscoverVC ()<UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate,UITextFieldDelegate>
{
    BMKLocationService *_locService;
}

@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSCache *imageCache;
@property (nonatomic,assign)NSInteger locationSucceedNum; //定位成功的次数
@property (nonatomic,strong)NSMutableDictionary *userLocationDict;
@property(strong,nonatomic)UIView *dismissView;

@property(strong,nonatomic)NSDictionary *currentSelectTopicDict;
@end

@implementation HeDiscoverVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize imageCache;

@synthesize locationSucceedNum;
@synthesize userLocationDict;
@synthesize dismissView;

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
        label.text = @"遇";
        [label sizeToFit];
        
        self.title = @"遇";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    //获取用户的地理位置
    [self getLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [_locService stopUserLocationService];
    _locService.delegate = nil;
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNo = 0;
    updateOption = 1;
    imageCache = [[NSCache alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"deleteTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTopicSucceed:) name:@"distributeTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUserSucceed:) name:@"blockUserSucceed" object:nil];
    
}

- (void)initView
{
    [super initView];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor whiteColor];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
//    [self pullUpUpdate];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    UIView *footerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 80)];
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
        pageNo = [dataSource count];
        [self loadNearbyUserShow:YES];
    }];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter  = 1.5f;
    
    userLocationDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    locationSucceedNum = 0;
}

- (void)blockUserSucceed:(NSNotification *)notificaiton
{
    updateOption = 1;
    [self loadNearbyUserShow:NO];
}
- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    [alertview removeFromSuperview];
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
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/NewestList.action",BASEURL];
    
    NSString *latitudeStr = [userLocationDict objectForKey:@"latitude"];
    if (latitudeStr == nil) {
        latitudeStr = @"";
    }
    NSString *longitudeStr = [userLocationDict objectForKey:@"longitude"];
    if (longitudeStr == nil) {
        longitudeStr = @"";
    }
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":userid,@"pageNum":pageNum,@"latitude":latitudeStr,@"longitude":longitudeStr};
    if (show) {
        [self showHudInView:self.tableview hint:@"正在获取..."];
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
            if (![resultArray isMemberOfClass:[NSNull class]]) {
                
                NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
                NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,myUserId];
                
                NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
                
                
                for (NSDictionary *zoneDict in resultArray) {
                    BOOL isBlock = NO;
                    for (NSDictionary *dict in blockArray) {
                        NSString *userId = dict[@"userId"];
                        NSString *zoneUserId = zoneDict[@"topicUserId"];
                        if ([zoneUserId isMemberOfClass:[NSNull class]]) {
                            zoneUserId = @"";
                        }
                        if ([zoneUserId isEqualToString:userId]) {
                            isBlock = YES;
                            break;
                        }
                    }
                    if (!isBlock) {
                        [dataSource addObject:zoneDict];
                    }
                    
                    NSString *header = zoneDict[@"header"];
                    if ([header isMemberOfClass:[NSNull class]] || header == nil) {
                        header = @"";
                    }
                    NSString *huanxId = zoneDict[@"huanxId"];
                    if ([huanxId isMemberOfClass:[NSNull class]] || huanxId == nil) {
                        huanxId = @"";
                    }
                    NSString *nick = zoneDict[@"nick"];
                    if ([nick isMemberOfClass:[NSNull class]] || nick == nil) {
                        nick = @"";
                    }
                    id sex = zoneDict[@"sex"];
                    if ([sex isMemberOfClass:[NSNull class]] || sex == nil) {
                        sex = @"";
                    }
                    NSString *topicUserId = zoneDict[@"topicUserId"];
                    if ([topicUserId isMemberOfClass:[NSNull class]] || topicUserId == nil) {
                        topicUserId = @"";
                    }
                    NSDictionary *userDictInfo = @{@"huanxId":huanxId,@"userHeader":header,@"userNick":nick,@"userSex":sex,@"userId":topicUserId};
                    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
                    NSString *contactKey = [NSString stringWithFormat:@"%@_%@",USERCONTACTKEY,userId];
                    
                    NSDictionary *contactDict = [[NSUserDefaults standardUserDefaults] objectForKey:contactKey];
                    NSMutableDictionary *myContactDict = [[NSMutableDictionary alloc] initWithDictionary:contactDict];
                    [myContactDict setObject:userDictInfo forKey:huanxId];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:myContactDict forKey:contactKey];
                    
                }
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
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)getLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务设置->隐私->定位服务" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [self showHudInView:self.view hint:@"定位中..."];
        [_locService startUserLocationService];
    }
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    CLLocation *newLocation = userLocation.location;
    CLLocationCoordinate2D coordinate1 = newLocation.coordinate;
    
//    CLLocationCoordinate2D coordinate = [self returnBDPoi:coordinate1];
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate1.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate1.longitude];
    
    
    if (newLocation && ![userLocationDict objectForKey:@"latitude"]) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
            [_locService stopUserLocationService];
            
            [HeSysbsModel getSysModel].userLocationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
            //上传坐标
            NSString *latitudeStr = [userLocationDict objectForKey:@"latitude"];
            if (latitudeStr == nil) {
                latitudeStr = @"";
            }
            NSString *longitudeStr = [userLocationDict objectForKey:@"longitude"];
            if (longitudeStr == nil) {
                longitudeStr = @"";
            }
            [self loadNearbyUserShow:YES];
            [self updateUserLocationWith:userLocationDict];
        }
    }
    else{
        [userLocationDict setObject:latitudeStr forKey:@"latitude"];
        [userLocationDict setObject:longitudeStr forKey:@"longitude"];
        [HeSysbsModel getSysModel].userLocationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
        [self updateUserLocationWith:userLocationDict];
    }
    
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self hideHud];
    [self showHint:@"定位失败!"];
}

- (void)updateUserLocationWith:(NSDictionary *)locatonDict
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/updateCoordinate.action",BASEURL];
    
    NSString *latitudeStr = [userLocationDict objectForKey:@"latitude"];
    if (latitudeStr == nil) {
        latitudeStr = @"";
    }
    NSString *longitudeStr = [userLocationDict objectForKey:@"longitude"];
    if (longitudeStr == nil) {
        longitudeStr = @"";
    }
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userid,@"latitude":latitudeStr,@"longitude":longitudeStr};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSLog(@"上传坐标成功");
        }
        else{
            NSLog(@"上传坐标失败");
        }
    } failure:^(NSError *error){
    
    }];
}

- (void)canChatWithUser:(NSString *)otherUserId
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/selectdistance.action",BASEURL];
    
    NSString *latitudeStr = [userLocationDict objectForKey:@"latitude"];
    if (latitudeStr == nil) {
        latitudeStr = @"";
    }
    NSString *longitudeStr = [userLocationDict objectForKey:@"longitude"];
    if (longitudeStr == nil) {
        longitudeStr = @"";
    }
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userid,@"otherUserId":otherUserId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            //距离短，可以进行即时聊天
           dispatch_async(dispatch_get_main_queue(), ^{
               
           });
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前用户距离您太远，不能进行即时聊天" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error){
        
    }];
}

#pragma 火星坐标系 (GCJ-02) 转 mark-(BD-09) 百度坐标系 的转换算法
-(CLLocationCoordinate2D)returnBDPoi:(CLLocationCoordinate2D)PoiLocation
{
    const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    float x = PoiLocation.longitude + 0.0065, y = PoiLocation.latitude + 0.006;
    float z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    float theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationCoordinate2D GCJpoi=
    CLLocationCoordinate2DMake( z * sin(theta),z * cos(theta));
    return GCJpoi;
}

- (UIImage *) buttonImageFromColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)modifyUserNote
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    CGFloat viewX = 10;
    CGFloat viewY = 100;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 150;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBarIOS7"]];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 40;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:15.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = shareFont;
    messageTitleLabel.textColor = [UIColor whiteColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = APPDEFAULTORANGE;
    messageTitleLabel.text = @"修改备注";
    messageTitleLabel.frame = CGRectMake(0, 0, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.backgroundColor = [UIColor whiteColor];
    textview.placeholder = @"请输入备注";
    textview.font = shareFont;
    textview.delegate = self;
    textview.frame = CGRectMake(10, labelY, shareAlert.frame.size.width - 20, labelH);
    textview.layer.borderWidth = 1.0;
    textview.layer.cornerRadius = 2.0;
    textview.layer.masksToBounds = YES;
    textview.layer.borderColor = [UIColor colorWithWhite:0xcc / 255.0 alpha:1.0].CGColor;
    [shareAlert addSubview:textview];
    
    CGFloat buttonDis = 10;
    CGFloat buttonW = (viewW - 3 * buttonDis) / 2.0;
    CGFloat buttonH = 40;
    CGFloat buttonY = labelY = labelY + labelH + 10;
    CGFloat buttonX = 10;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [shareButton setTitle:@"确定" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 1;
    [shareButton.titleLabel setFont:shareFont];
    [shareButton setBackgroundColor:APPDEFAULTORANGE];
    [shareButton setBackgroundImage:[self buttonImageFromColor:APPDEFAULTORANGE size:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
    [cancelButton setBackgroundImage:[self buttonImageFromColor:APPDEFAULTORANGE size:shareButton.frame.size] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareAlert addSubview:cancelButton];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shareAlert.layer addAnimation:popAnimation forKey:nil];
    [self.view addSubview:shareAlert];
}

- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    NSString *notename = textview.text;
    [alertview removeFromSuperview];
    if (notename == nil || [notename isEqualToString:@""]) {
        
        [self showHint:@"请输入备注"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *coveruserid = _currentSelectTopicDict[@"topicUserId"];
    if ([coveruserid isMemberOfClass:[NSNull class]] || coveruserid == nil) {
        coveruserid = @"";
    }
    NSDictionary *params = @{@"userId":userId,@"coveruserid":coveruserid,@"notename":notename};
    [self modifyUserNoteithDict:params];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"chatUserEvent"]) {
        NSLog(@"chatUserEvent");
        NSString *chatID = userInfo[@"huanxId"];
        NSString *nick = userInfo[@"nick"];
        ChatViewController *chatView = [[ChatViewController alloc] initWithConversationChatter:chatID conversationType:EMConversationTypeChat];
        chatView.title = nick;
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
        return;
    }
    else if ([eventName isEqualToString:@"upDownButtonClick"]){
        NSLog(@"upDownButtonClick");
        [self upDownButtonClickWithDict:userInfo];
        return;
    }
    else if ([eventName isEqualToString:@"modifyNoteUserNoteEvent"]){
        //修改备注
        _currentSelectTopicDict = [[NSDictionary alloc] initWithDictionary:userInfo];
        [self modifyUserNote];
        
        return;
    }
    [super routerEventWithName:eventName userInfo:userInfo];
}

- (void)modifyUserNoteithDict:(NSDictionary *)dict
{
    NSString *upDownUrl = [NSString stringWithFormat:@"%@/note/createAndUpdateNewNote.action",BASEURL];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:upDownUrl params:dict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            //修改备注成功，重新加载
            if (updateOption == 1) {
                [dataSource removeAllObjects];
            }
            updateOption = 1;
            [self loadNearbyUserShow:NO];
            
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
            [self loadNearbyUserShow:NO];
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

- (IBAction)distribuetButtonClick:(id)sender
{
    NSLog(@"distribuetButtonClick");
    HeDistributeTopicVC *distributeTopicVC = [[HeDistributeTopicVC alloc] init];
    distributeTopicVC.locationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
    distributeTopicVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeTopicVC animated:YES];
}

- (void)addFooterView
{
//    if (tableview.contentSize.height >= SCREENHEIGH) {
//        [self pullDownUpdate];
//    }
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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    //刷新列表
    [self loadNearbyUserShow:NO];
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
    pageNo++;
    
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
    pageNo = [dataSource count];
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
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeDiscoverTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
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
        topicCreatetimeObj = [NSString stringWithFormat:@"%.0f",timeInterval];
    }
    long long topicCreatetimeStamp = [topicCreatetimeObj longLongValue] / 1000;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
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
    topicDetailVC.locationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
    topicDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:topicDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"distributeTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteTopicSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"blockUserSucceed" object:nil];
    
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
