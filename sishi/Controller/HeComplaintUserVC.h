//
//  HeDistributeView.h
//  huobao
//
//  Created by HeDongMing on 14-7-4.
//  Copyright (c) 2014年 何 栋明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTextViewPlaceholder.h"
#import "DeleteImageProtocol.h"
#import "MBProgressHUD.h"
#import "HeBaseViewController.h"


@interface HeComplaintUserVC : HeBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,DeleteImageProtocol,MBProgressHUDDelegate>
{
    int distributeType;
    int uploadType;//上传标记
}

@property(strong,nonatomic)IBOutlet UITableView *distributeTable;
@property(strong,nonatomic)UITextField *distributeTF;
@property(strong,nonatomic)UIView *headerBGView;
@property(strong,nonatomic)UIButton *addPictureButton;
@property(strong,nonatomic)NSMutableArray *pictureArray;
@property(strong,nonatomic)NSMutableArray *buttonArray;
@property(strong,nonatomic)NSString *fzid;
@property(strong,nonatomic)NSString *uid;
@property(assign,nonatomic)int loadSucceedFlag;

@property(strong,nonatomic)NSString *userNick;

-(id)initWithType:(int)type;
@end
