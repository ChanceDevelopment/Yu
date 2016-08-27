//
//  AppDelegate.h
//  beautyContest
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

static NSString *appKey = JPUSHAPPKEY;
static NSString *channel = @"App Store";  //下载的渠道
static BOOL isProduction = FALSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic)NSOperationQueue *queue;


@end

