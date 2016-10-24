//
//  User.m
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "User.h"

@implementation User


- (User *)initUserWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if (dict) {
            NSString *userId = [dict objectForKey:@"userId"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            self.userId = userId;
            
            NSString *huanxId = [dict objectForKey:@"huanxId"];
            if ([huanxId isMemberOfClass:[NSNull class]] || huanxId == nil) {
                huanxId = @"";
            }
            self.huanxId = huanxId;
            
            NSString *userNick = [dict objectForKey:@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            self.userNick = userNick;
            
            NSString *userAddress = [dict objectForKey:@"userAddress"];
            if ([userAddress isMemberOfClass:[NSNull class]] || userAddress == nil) {
                userAddress = @"";
            }
            self.userAddress = userAddress;
            
            
            NSString *userHeader = [dict objectForKey:@"userHeader"];
            if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
                userHeader = @"";
            }
            self.userHeader = userHeader;
            
            NSString *userPositionX = [dict objectForKey:@"userPositionX"];
            if ([userPositionX isMemberOfClass:[NSNull class]] || userPositionX == nil) {
                userPositionX = @"";
            }
            self.userPositionX = userPositionX;
            
         
            NSString *userPositionY = [dict objectForKey:@"userPositionY"];
            if ([userPositionY isMemberOfClass:[NSNull class]] || userPositionY == nil) {
                userPositionY = @"";
            }
            self.userPositionY = userPositionY;
            
            
            NSString *userEmail = [dict objectForKey:@"userEmail"];
            if ([userEmail isMemberOfClass:[NSNull class]] || userEmail == nil) {
                userEmail = @"";
            }
            self.userEmail = userEmail;
            
            NSString *userPhone = [dict objectForKey:@"userPhone"];
            if ([userPhone isMemberOfClass:[NSNull class]] || userPhone == nil) {
                userPhone = @"";
            }
            self.userPhone = userPhone;
            
            NSString *userSign = [dict objectForKey:@"userSign"];
            if ([userSign isMemberOfClass:[NSNull class]] || userSign == nil) {
                userSign = @"";
            }
            self.userSign = userSign;
            
            id userAge = dict[@"userAge"];
            if ([userAge isMemberOfClass:[NSNull class]]) {
                userAge = @"";
            }
            self.userAge = [userAge integerValue];
            
            id userSex = dict[@"userSex"];
            if ([userSex isMemberOfClass:[NSNull class]]) {
                userSex = @"";
            }
            self.userSex = [userSex integerValue];
        }
        
    }
    return self;
}

- (User *)initUserWithUser:(User *)user
{
    self = [super init];
    if (self) {
        if (user) {
            
            NSString *userId = user.userId;
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            self.userId = userId;
            
            NSString *huanxId = user.huanxId;
            if ([huanxId isMemberOfClass:[NSNull class]] || huanxId == nil) {
                huanxId = @"";
            }
            self.huanxId = huanxId;
            
            NSString *userNick = user.userNick;
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            self.userNick = userNick;
            
            NSString *userAddress = user.userAddress;
            if ([userAddress isMemberOfClass:[NSNull class]] || userAddress == nil) {
                userAddress = @"";
            }
            self.userAddress = userAddress;
            
            
            NSString *userHeader = user.userHeader;
            if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
                userHeader = @"";
            }
            self.userHeader = userHeader;
            
            NSString *userPositionX = user.userPositionX;
            if ([userPositionX isMemberOfClass:[NSNull class]] || userPositionX == nil) {
                userPositionX = @"";
            }
            self.userPositionX = userPositionX;
            
            
            NSString *userPositionY = user.userPositionY;
            if ([userPositionY isMemberOfClass:[NSNull class]] || userPositionY == nil) {
                userPositionY = @"";
            }
            self.userPositionY = userPositionY;
            
            
            NSString *userEmail = user.userEmail;
            if ([userEmail isMemberOfClass:[NSNull class]] || userEmail == nil) {
                userEmail = @"";
            }
            self.userEmail = userEmail;
            
            NSString *userPhone = user.userPhone;
            if ([userPhone isMemberOfClass:[NSNull class]] || userPhone == nil) {
                userPhone = @"";
            }
            self.userPhone = userPhone;
            
            NSString *userSign = user.userSign;
            if ([userSign isMemberOfClass:[NSNull class]] || userSign == nil) {
                userSign = @"";
            }
            self.userSign = userSign;
            
            
            self.userAge = user.userAge;
            
            
            self.userSex = user.userSex;
            
        }
        
    }
    return self;
}

@end
