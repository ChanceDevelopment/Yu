//
//  HeTopicDetailVC.m
//  yu
//
//  Created by HeDongMing on 2016/10/22.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeTopicDetailVC.h"
#import "HeDiscoverTableCell.h"
#import "ChatViewController.h"
#import "HeDistributeTopicVC.h"
#import "HeTopicDetailVC.h"
#import "MJRefresh.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "MLLabel+Size.h"
#import "MLLinkLabel.h"
#import "HeTopicDetailCell.h"
#import "HeCommentCell.h"
#import "UIImageView+EMWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import "FTPopOverMenu.h"
#import "HeComplaintVC.h"

@interface HeTopicDetailVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *replyDataSource;
@property(strong,nonatomic)NSCache *imageCache;
@property(assign,nonatomic)NSInteger pageNo;

@end

@implementation HeTopicDetailVC
@synthesize topicDetailDict;
@synthesize tableview;
@synthesize dataSource;
@synthesize imageCache;
@synthesize pageNo;
@synthesize replyDataSource;
@synthesize commentField;
@synthesize commentBGLabel;
@synthesize locationDict;

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
        label.text = @"话题详情";
        [label sizeToFit];
        
        self.title = @"话题详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self updateTopicDetail];
    [self loadReplyData];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    replyDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [dataSource addObject:topicDetailDict];
    imageCache = [[NSCache alloc] init];
    pageNo = 0;
}

- (void)initView
{
    [super initView];

    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(moreItemClick:) forControlEvents:UIControlEventTouchUpInside];
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    
    [self performSelector:@selector(addCommentTextField) withObject:nil afterDelay:0.5];
}

- (void)moreItemClick:(id)sender
{
    NSArray *menuArray = @[@"举报",@"屏蔽该发布人"];
    NSString *userId = topicDetailDict[@"topicUserId"];
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = @"";
    }
    NSString *myuserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    
    if ([userId isEqualToString:myuserId]) {
       menuArray = @[@"举报",@"屏蔽该发布人",@"删除话题"];
    }
    
    [FTPopOverMenu setTintColor:APPDEFAULTORANGE];
    [FTPopOverMenu showForSender:sender
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           switch (selectedIndex) {
                               case 0:
                               {
                                   HeComplaintVC *complaintVC = [[HeComplaintVC alloc] init];
                                   complaintVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:complaintVC animated:YES];
                                   break;
                               }
                               case 1:
                               {
                                   //屏蔽用户
                                   [self blockUserButtonClick];
                                   break;
                               }
                               case 2:
                               {
                                   
                                   break;
                               }
                               default:
                                   break;
                           }
                           
                           
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
}

//屏蔽用户
- (void)blockUserButtonClick
{
    NSString *userId = topicDetailDict[@"userId"]; //发布人的ID
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = nil;
    }
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([userId isEqualToString:myUserId]) {
        [self showHint:@"不能屏蔽自己"];
        return;
    }
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"屏蔽该用户之后，他发布的内容将不会出现你的内容列表里面" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            NSLog(@"cancelAction");
        }];
        UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"屏蔽" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *userId = topicDetailDict[@"topicUserId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            NSString *userNick = topicDetailDict[@"nick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            NSDictionary *userDict = @{@"userId":userId,@"userNick":userNick};
            [self blockUserWithUser:userDict];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:blockAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"屏蔽该用户之后，他发布的内容将不会出现你的内容列表里面" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"屏蔽", nil];
    alertview.tag = 200;
    [alertview show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200) {
        switch (buttonIndex) {
            case 1:
            {
                NSString *userId = topicDetailDict[@"topicUserId"]; //发布人的ID
                if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                    userId = @"";
                }
                NSString *userNick = topicDetailDict[@"nick"];
                if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                    userNick = @"";
                }
                NSDictionary *userDict = @{@"userId":userId,@"userNick":userNick};
                [self blockUserWithUser:userDict];
                break;
            }
            default:
                break;
        }
    }
    else if (alertView.tag == 1){
        if (buttonIndex == 1) {
            [self deleteTopic];
        }
    }
}

- (void)blockUserWithUser:(NSDictionary *)userDict
{
    NSLog(@"blockUser");
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,myUserId];
    NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
    if (blockArray != nil) {
        [tmpArray addObjectsFromArray:blockArray];
    }
    [tmpArray addObject:userDict];
    blockArray = [[NSArray alloc] initWithArray:tmpArray];
    [[NSUserDefaults standardUserDefaults] setObject:blockArray forKey:blockKey];
    NSNotification *notification = [NSNotification notificationWithName:@"blockUserSucceed" object:nil userInfo:userDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self showHint:@"成功屏蔽用户"];
}

- (void)loadReplyData
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/QueryReply.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *topicId = topicDetailDict[@"topicId"];
    if ([topicId isMemberOfClass:[NSNull class]] || topicId == nil) {
        topicId = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"pageNum":pageNum,@"topicId":topicId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [replyDataSource removeAllObjects];
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            for (NSDictionary *dict in resultArray) {
                [replyDataSource addObject:dict];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // *** 将UI操作放到主线程中执行 ***
                [self.tableview reloadData];
                return ;
            });
            
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)updateTopicDetail
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/TopicList.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *topicId = topicDetailDict[@"topicId"];
    if ([topicId isMemberOfClass:[NSNull class]] || topicId == nil) {
        topicId = @"";
    }
    //NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":userId,@"TopicId":topicId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            NSDictionary *topicDict = [respondDict objectForKey:@"json"];
            topicDetailDict = [[NSDictionary alloc] initWithDictionary:topicDict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // *** 将UI操作放到主线程中执行 ***
                [self.tableview reloadData];
                return ;
            });
            
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)deleteButtonClick:(id)sender
{
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定删除本话题?" preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self deleteTopic];
        }];
        
        
        // Add the actions.
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除本话题?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        alert.tag = 1;
        [alert show];
    }
}


- (void)deleteTopic
{
    NSLog(@"deleteButtonClick");
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/topic/deleteByTopicId.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *topicId = topicDetailDict[@"topicId"];
    if ([topicId isMemberOfClass:[NSNull class]] || topicId == nil) {
        topicId = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userId,@"topicId":topicId};
    
    [self showHudInView:self.view hint:@"删除中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteTopicSucceed" object:nil];
            
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCommentTextField
{
    commentField = [[UITextField alloc] init];
    commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    commentField.returnKeyType = UIReturnKeySend;
    commentField.delegate = self;
    commentField.placeholder = @"回复是一种鼓励";
    commentField.frame = CGRectMake(5, 10, SCREENWIDTH - 10, 30);
    commentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    commentField.textColor = [UIColor blackColor];
    commentField.borderStyle = UITextBorderStyleRoundedRect;
    commentField.autocorrectionType = UITextAutocorrectionTypeNo;
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish:)];
    finishButton.title = @"完成";
    NSArray *bArray = [NSArray arrayWithObjects:finishButton, nil];
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0)];//创建工具条对象
    tb.items = bArray;
    tb.hidden = YES;
    
    commentField.inputAccessoryView = tb;//将工具条添加到UITextView的响应键盘
    
    //    commentBGLabel = [[UILabel alloc] init];
    //    commentBGLabel.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 89 - 44 - 20 - 10, SCREENWIDTH, 50);
    commentBGLabel.userInteractionEnabled = YES;
    commentBGLabel.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0/255.0f blue:243.0/255.0f alpha:1.0];
    [commentBGLabel addSubview:commentField];
    
    //    commentBGLabel.hidden = YES;
    //    [self.view addSubview:commentBGLabel];
}

- (void)finish:(id)sender
{
    if ([commentField isFirstResponder]) {
        [commentField resignFirstResponder];
    }
}

-(void)onClickImage:(UIView *) sender
{
    NSMutableArray *photos = [NSMutableArray array];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    for (NSInteger index = 0; index < dataSource.count; index++) {

        UIImageView *srcImageView = (UIImageView *)sender;
        NSString *photoUrl = topicDetailDict[@"img"];
        NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,photoUrl];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageUrl];
        photo.srcImageView = srcImageView;
        [photos addObject:photo];
    }
    browser.photos = photos;
    browser.currentPhotoIndex = sender.tag;
    [browser show];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"commment"]) {
        if ([commentField isFirstResponder]) {
            return;
        }
        commentBGLabel.hidden = NO;
        commentField.hidden = NO;
        commentField.text = nil;
        
        [commentBGLabel addSubview:commentField];
        [self.view addSubview:commentBGLabel];
        [self performSelector:@selector(beginEdit) withObject:nil afterDelay:0.3];
    }
    else if ([eventName isEqualToString:@"foward"]){
        NSLog(@"foward");
        [self shareTopic];
    }
    else if ([eventName isEqualToString:@"enlargeImage"]){
        UIImageView *imageView = userInfo[@"view"];
        [self onClickImage:imageView];
    }
    else{
        [super routerEventWithName:eventName userInfo:userInfo];
    }
}

- (void)shareTopic
{
    NSString *shareContent = @"遇-上最好的您";
    NSString *shareTitleStr = @"遇";
    NSString *imagePath = nil;
    
    NSArray* imageArray = nil;
    if ([imagePath isMemberOfClass:[NSNull class]] || imagePath == nil || [imagePath isEqualToString:@""]) {
        imagePath =[[NSBundle mainBundle] pathForResource:@"appIcon"  ofType:@"png"];
    }
    imageArray = @[imagePath];
    
    
    NSArray *sharePlatFormArray = @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    
    NSString *shareUrl = @"http://114.55.226.224:8088/xuanmei/shareZone.action?";;
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:shareContent
                                     images:imageArray
                                        url:[NSURL URLWithString:shareUrl]
                                      title:shareTitleStr
                                       type:SSDKContentTypeWebPage];
    //2、分享
    [ShareSDK showShareActionSheet:nil
                             items:sharePlatFormArray
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               break;
                           }
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           break;
                       }
                       default:
                           break;
                   }
                   
                   
               }];
}

- (void)beginEdit
{
    [commentField becomeFirstResponder];
}

- (void)commentWithText:(NSString *)commentContent
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *topicId = topicDetailDict[@"topicId"];
    NSString *content = commentContent;
    NSString *latitude = [locationDict objectForKey:@"latitude"];
    if (latitude == nil) {
        latitude = @"";
    }
    NSString *longitude = [locationDict objectForKey:@"longitude"];
    if (longitude == nil) {
        longitude = @"";
    }
    NSDictionary *commentDict = @{@"userId":userId,@"topicId":topicId,@"content":content,@"longitude":longitude,@"latitude":latitude};
    NSString *replyUrl = [NSString stringWithFormat:@"%@/topic/TopicReply.action",BASEURL];
    
    [self showHudInView:self.view hint:@"评论中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:replyUrl params:commentDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            //评论成功
            [self updateTopicDetail];
            [self loadReplyData];
            
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

- (void)updateDataWithParam:(NSDictionary *)params
{

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([commentField isFirstResponder]) {
        [commentField resignFirstResponder];
    }
    isScroll = YES;
    //    commentBGLabel.hidden = YES;
    //    commentField.hidden = YES;
    
    NSString *replyContent = textField.text;
    if (replyContent == nil || [replyContent isEqualToString:@""]) {
        isScroll = NO;
        
        textField.placeholder = @"回复是一种鼓励";
        //        [self showTipLabelWith:@"回复内容为空"];
        return;
    }
    [self commentWithText:textField.text];
    textField.text = nil;
    //    self.tmpReplyModel = nil;
    //    textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([commentField isFirstResponder]) {
        [commentField resignFirstResponder];
    }
    return YES;
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([commentField isFirstResponder]) {
        isScroll = YES;
        [commentField resignFirstResponder];
    }
    //    commentField.hidden = YES;
    //    commentBGLabel.hidden = YES;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isScroll = NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count] + [replyDataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeTopicDetailCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    if (row == 0) {
        @try {
            dict = [dataSource objectAtIndex:row];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        HeTopicDetailCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[HeTopicDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.replyDict = dict;
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
        
        id replyNum = dict[@"replyNum"];
        id shareNum = dict[@"shareNum"];
        UILabel *titleLabel = [cell.commentButton viewWithTag:10086];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.text = [NSString stringWithFormat:@"%ld",[replyNum integerValue]];
        
        titleLabel = [cell.forwardButton viewWithTag:10086];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.text = [NSString stringWithFormat:@"%ld",[shareNum integerValue]];
        
        [cell updateFrame];
        return cell;
    }
    @try {
        dict = [replyDataSource objectAtIndex:row - 1];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    HeCommentCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *userNick = dict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.nameLabel.text = userNick;
    
    id topicCreatetimeObj = [dict objectForKey:@"replyCreatetime"];
    if ([topicCreatetimeObj isMemberOfClass:[NSNull class]] || topicCreatetimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        topicCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long topicCreatetimeStamp = [topicCreatetimeObj longLongValue];
    NSString *topicCreatetime = [NSString stringWithFormat:@"%lld",topicCreatetimeStamp];
    NSString *timeTips = [Tool compareCurrentTime:topicCreatetime];
    
    cell.timeLabel.text = timeTips;
    
    NSString *content = dict[@"replyContent"];
    if ([content isMemberOfClass:[NSNull class]] || content == nil) {
        content = @"";
    }
    CGFloat maxWidth = SCREENWIDTH - 20;
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
    if (size.height < 25) {
        size.height = 25;
    }
    cell.contentLabel.text = content;
    
    CGRect contentFrame = cell.contentLabel.frame;
    contentFrame.size.height = size.height;
    cell.contentLabel.frame = contentFrame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    NSDictionary *dict = nil;
    if (row > 0) {
        dict = [replyDataSource objectAtIndex:row - 1];
        NSString *content = dict[@"replyContent"];
        if ([content isMemberOfClass:[NSNull class]] || content == nil) {
            content = @"";
        }
        CGFloat maxWidth = SCREENWIDTH - 20;
        UIFont *font = [UIFont systemFontOfSize:15.0];
        CGSize size = [MLLinkLabel getViewSizeByString:content maxWidth:maxWidth font:font lineHeight:1.2f lines:0];
        if (size.height < 25) {
            size.height = 25;
        }
        
        return 60 + size.height - 25;
    }
    
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
    return 250 + (size.height - 40)  + (SCREENWIDTH * 0.618 - 120);
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
