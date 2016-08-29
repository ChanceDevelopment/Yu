//
//  HeUserVC.m
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeUserVC.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface HeUserVC ()
@property(strong,nonatomic)IBOutlet UIView *topicBgView;

@end

@implementation HeUserVC
@synthesize topicBgView;

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
        label.text = @"我的";
        
        [label sizeToFit];
        self.title = @"我的";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [BMKMapView enableCustomMapStyle:NO];//关闭个性化地图
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)initializaiton
{
    [super initializaiton];
    _locService = [[BMKLocationService alloc]init];
}

- (void)initView
{
    [super initView];
    
    CGFloat buttonW = (SCREENWIDTH - 40) / 2.0;
    CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    CGFloat buttonH = 40;
    UIButton *myTopicButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"我的话题" image:@"icon_topic"];
    [topicBgView addSubview:myTopicButton];
    
    UIButton *myReplyButton = [Tool getButton:CGRectMake(buttonX + buttonW, buttonY, buttonW, buttonH) title:@"我回复的话题" image:@"icon_reply"];
    [topicBgView addSubview:myReplyButton];
    
    [myTopicButton addTarget:self action:@selector(topicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [myReplyButton addTarget:self action:@selector(topicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    myTopicButton.tag = 1;
    myReplyButton.tag = 1;
}

- (void)topicButtonClick:(UIButton *)button
{
    NSInteger tag = button.tag;
    switch (tag) {
        case 1:
        {
            break;
        }
        case 2:
        {
            break;
        }
        default:
            break;
    }
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.013142, 0.011678);
    BMKCoordinateRegion region = BMKCoordinateRegionMake(userLocation.location.coordinate, span);
    [_mapView setRegion:region animated:YES];
    
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    //    [alert show];
    //    alert = nil;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: click blank");
}

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: double click");
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
