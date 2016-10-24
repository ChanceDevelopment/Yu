//
//  User.h
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsynImageView.h"

@interface User : NSObject

@property(strong,nonatomic)NSString *userId; //用户名
@property(strong,nonatomic)NSString *huanxId;  //用户密码
@property(strong,nonatomic)NSString *userNick; //昵称
@property(strong,nonatomic)NSString *userAddress; //真实姓名
@property(assign,nonatomic)NSInteger userSex;  //用户充当的角色
@property(strong,nonatomic)NSString *userHeader;  //用户的token，身份的唯一凭证
@property(strong,nonatomic)NSString *userPositionX;  //用户的头像
@property(strong,nonatomic)NSString *userPositionY;  //用户的ID
@property(strong,nonatomic)NSString *userEmail;//生日
@property(strong,nonatomic)NSString *userPhone;//生日
@property(strong,nonatomic)NSString *userSign;//生日
@property(assign,nonatomic)NSInteger userAge;//生日


@property(strong,nonatomic)NSString *schoolName;//学校
@property(strong,nonatomic)NSString *relation;//与小孩关系
@property(strong,nonatomic)NSString *className;//班级

/*************暂时不用****************/
@property(strong,nonatomic)NSString *industry;
@property(strong,nonatomic)NSString *companyname;
@property(assign,nonatomic)NSInteger sex;
@property(strong,nonatomic)NSString *profession;

@property(strong,nonatomic)NSString *idcard;
@property(strong,nonatomic)NSString *workaddress;
@property(strong,nonatomic)AsynImageView *userImage;
@property(strong,nonatomic)NSString *constellation;
@property(strong,nonatomic)NSString *currentaddress;
@property(strong,nonatomic)NSString *homeaddress;
@property(strong,nonatomic)NSString *loginid;
@property(strong,nonatomic)NSString *mail;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *phoneid;
@property(strong,nonatomic)NSString *signature;
@property(assign,nonatomic)NSInteger state;
@property(strong,nonatomic)NSString *phonenum;
/*************暂时不用****************/

- (User *)initUserWithDict:(NSDictionary *)dict;
- (User *)initUserWithUser:(User *)user;

@end
