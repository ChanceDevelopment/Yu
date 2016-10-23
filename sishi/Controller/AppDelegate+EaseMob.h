//
//  AppDelegate+EaseMob.h
//  yu
//
//  Created by HeDongMing on 2016/10/23.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig;

@end
