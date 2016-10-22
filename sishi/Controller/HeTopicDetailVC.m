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

@interface HeTopicDetailVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>
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
    UIButton *deleteButton = [[UIButton alloc] init];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    deleteButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    deleteItem.target = self;
    self.navigationItem.rightBarButtonItem = deleteItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    
    [self performSelector:@selector(addCommentTextField) withObject:nil afterDelay:0.5];
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

- (void)deleteButtonClick:(id)sender
{
    NSLog(@"deleteButtonClick");
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
    }
    else if ([eventName isEqualToString:@"enlargeImage"]){
        UIImageView *imageView = userInfo[@"view"];
        [self onClickImage:imageView];
    }
    else{
        [super routerEventWithName:eventName userInfo:userInfo];
    }
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
    NSString *longitude = @"";
    NSString *latitude = @"";
    NSDictionary *commentDict = @{@"userId":userId,@"topicId":topicId,@"content":content,@"longitude":longitude,@"latitude":latitude};
    NSString *replyUrl = [NSString stringWithFormat:@"%@/topic/TopicReply.action",BASEURL];
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
            topicCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
        }
        long long topicCreatetimeStamp = [topicCreatetimeObj longLongValue];
        NSString *topicCreatetime = [NSString stringWithFormat:@"%lld",topicCreatetimeStamp];
        NSString *timeTips = [Tool compareCurrentTime:topicCreatetime];
        
        cell.timeLabel.text = timeTips;
        
        id udcountNum = dict[@"udcountNum"];
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
        titleLabel.text = [NSString stringWithFormat:@"%ld",[replyNum integerValue]];
        
        titleLabel = [cell.forwardButton viewWithTag:10086];
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
    return 250 + (size.height - 40);
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
