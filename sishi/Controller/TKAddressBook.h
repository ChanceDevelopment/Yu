//
//  MainViewController.h
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKAddressBook : NSObject {
    NSInteger sectionNumber;
    NSInteger recordID;
    BOOL rowSelected;
    NSString *name;
    NSString *email;
    NSString *tel;
    UIImage *thumbnail;
}

@property NSInteger sectionNumber;
@property NSInteger recordID;
@property BOOL rowSelected;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *tel;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, strong) NSString *phone;
@property(nonatomic,strong)NSString *dateline;
@property(nonatomic,strong)NSString *fuid;
@property(nonatomic,strong)NSString *fusername;
@property(nonatomic,strong)NSString *fuuid;
@property(nonatomic,strong)NSString *gid;
@property(nonatomic,strong)NSString *note;
@property(nonatomic,strong)NSString *num;
@property(nonatomic,strong)NSString *profile;
@property(nonatomic,strong)NSString *sign;
@property(assign,nonatomic)int sex;  //1.男   2.女

@end