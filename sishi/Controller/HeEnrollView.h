//
//  HeEnrollView.h
//  huobao
//
//  Created by Tony He on 14-5-13.
//  Copyright (c) 2014年 何 栋明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Bootstrap.h"
#import "HeBaseViewController.h"
#import "BrowserView.h"

@interface HeEnrollView : HeBaseViewController<UITextFieldDelegate>

@property(strong,nonatomic)IBOutlet UITextField *accountTF;
@property(strong,nonatomic)IBOutlet UIButton *getCheckCodeButton;
@property(assign,nonatomic)int loadSucceedFlag;
@property(strong,nonatomic)IBOutlet UILabel *protocolDetailLabel;

-(IBAction)enrollButtonClick:(id)sender;

@end
