//
//  HeRootSegmentVC.m
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeRootSegmentVC.h"
#import "HeUserVC.h"
#import "HeDiscoverVC.h"
#import "HeNewsVC.h"
#import "HeChatVC.h"
#import "HeSearchInfoVC.h"
#import "ChatDemoHelper.h"
#import "ApplyViewController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

@interface HeRootSegmentVC ()<UISearchBarDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)UISearchBar *searchBar;
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (strong, nonatomic)HeChatVC *newsVC;

@end

@implementation HeRootSegmentVC
@synthesize searchBar;
@synthesize newsVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
//    [self setUpAllViewController];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    
//    //if 使tabBarController中管理的viewControllers都符合 UIRectEdgeNone
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
//    self.title = NSLocalizedString(@"title.conversation", @"Conversations");
    
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    //    [self didUnreadMessagesCountChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
    
    [self setUpAllViewController];
//    self.selectedIndex = 0;
    
//    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [addButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
//    [addButton addTarget:_contactsVC action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
//    _addFriendItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    [self setupUnreadMessageCount];
    [self setupUntreatedApplyCount];
    
//    [ChatDemoHelper shareHelper].contactViewVC = _contactsVC;
    [ChatDemoHelper shareHelper].conversationListVC = newsVC;
}

- (void)initView
{
    [super initView];
    CGFloat searchX = 10;
    CGFloat searchY = 15;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = 64 - 2 * searchY;
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    searchView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:searchView.bounds];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"          搜索话题、用户";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    [searchView addSubview:titleLabel];
    
    CGFloat iconW = 20;
    CGFloat iconH = 20;
    CGFloat iconX = 10;
    CGFloat iconY = (searchH - iconH) / 2.0;
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconH)];
    searchIcon.image = [UIImage imageNamed:@"icon_search"];
    [searchView addSubview:searchIcon];
    
    searchView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchInfo:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [searchView addGestureRecognizer:tap];
    
//    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
//    searchBar.tintColor = [UIColor blueColor];
//    searchBar.delegate = self;
//    searchBar.barStyle = UIBarStyleDefault;
//    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchView;
    
    self.norColor = [UIColor whiteColor];
    self.selColor = [UIColor whiteColor];
    self.titleFont = [UIFont systemFontOfSize:20.0];
    self.isShowUnderLine = YES;
    self.underLineColor = [UIColor whiteColor];
    self.underLineH = 3.0;
    self.underLineW = SCREENWIDTH / 5.0;
    
    NSArray *titleViewArray = @[@"main_meet_select",@"main_message_select",@"main_mine_select"];
    
    [self setSelectedTitleViewArrayWith:titleViewArray size:CGSizeMake(SCREENWIDTH / 3.0, 50)];
}

- (void)searchInfo:(id)sender
{
    HeSearchInfoVC *searchInfoVC = [[HeSearchInfoVC alloc] init];
    searchInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchInfoVC animated:YES];
}

- (void)setUpAllViewController
{
    HeDiscoverVC *discoverVC = [[HeDiscoverVC alloc] init];
    [self addChildViewController:discoverVC];
    
    newsVC = [[HeChatVC alloc] init];
    [self addChildViewController:newsVC];
    
    
    HeUserVC *userVC = [[HeUserVC alloc] init];
    [self addChildViewController:userVC];
}



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//环信代码
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (newsVC) {
        if (unreadCount > 0) {
            newsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            newsVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
//    if (_contactsVC) {
//        if (unreadCount > 0) {
//            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
//        }else{
//            _contactsVC.tabBarItem.badgeValue = nil;
//        }
//    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    [newsVC networkChanged:connectionState];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        do {
            NSString *title = @"新消息";
            if (message.chatType == EMChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[EMClient sharedClient].currentUsername]) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                }
                NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                        break;
                    }
                }
            }
            else if (message.chatType == EMChatTypeChatRoom)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName)
                {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
            
            notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
        } while (0);
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
    }
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        }else{
            [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
        }
    }
}

#pragma mark - public

- (void)jumpToChatList
{
    if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
        //        ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
        //        [chatController hideImagePicker];
    }
    else if(newsVC)
    {
//        [self.navigationController popToViewController:self animated:NO];
//        [self setSelectedViewController:_chatListVC];
    }
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
//    if (userInfo)
//    {
//        if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
//            //            ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
//            //            [chatController hideImagePicker];
//        }
//        
//        NSArray *viewControllers = self.navigationController.viewControllers;
//        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//            if (obj != self)
//            {
//                if (![obj isKindOfClass:[ChatViewController class]])
//                {
//                    [self.navigationController popViewControllerAnimated:NO];
//                }
//                else
//                {
//                    NSString *conversationChatter = userInfo[kConversationChatter];
//                    ChatViewController *chatViewController = (ChatViewController *)obj;
//                    if (![chatViewController.conversation.conversationId isEqualToString:conversationChatter])
//                    {
//                        [self.navigationController popViewControllerAnimated:NO];
//                        EMChatType messageType = [userInfo[kMessageType] intValue];
//#ifdef REDPACKET_AVALABLE
//                        chatViewController = [[RedPacketChatViewController alloc]
//#else
//                                              chatViewController = [[ChatViewController alloc]
//#endif
//                                                                    initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
//                                              switch (messageType) {
//                                                  case EMChatTypeChat:
//                                                  {
//                                                      NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
//                                                      for (EMGroup *group in groupArray) {
//                                                          if ([group.groupId isEqualToString:conversationChatter]) {
//                                                              chatViewController.title = group.subject;
//                                                              break;
//                                                          }
//                                                      }
//                                                  }
//                                                      break;
//                                                  default:
//                                                      chatViewController.title = conversationChatter;
//                                                      break;
//                                              }
//                                              [self.navigationController pushViewController:chatViewController animated:NO];
//                                              }
//                                              *stop= YES;
//                                              }
//                                              }
//                                              else
//                                              {
//                                                  ChatViewController *chatViewController = nil;
//                                                  NSString *conversationChatter = userInfo[kConversationChatter];
//                                                  EMChatType messageType = [userInfo[kMessageType] intValue];
//#ifdef REDPACKET_AVALABLE
//                                                  chatViewController = [[RedPacketChatViewController alloc]
//#else
//                                                                        chatViewController = [[ChatViewController alloc]
//#endif
//                                                                                              initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
//                                                                        switch (messageType) {
//                                                                            case EMChatTypeGroupChat:
//                                                                            {
//                                                                                NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
//                                                                                for (EMGroup *group in groupArray) {
//                                                                                    if ([group.groupId isEqualToString:conversationChatter]) {
//                                                                                        chatViewController.title = group.subject;
//                                                                                        break;
//                                                                                    }
//                                                                                }
//                                                                            }
//                                                                                break;
//                                                                            default:
//                                                                                chatViewController.title = conversationChatter;
//                                                                                break;
//                                                                        }
//                                                                        [self.navigationController pushViewController:chatViewController animated:NO];
//                                                                        }
//                                                                        }];
//                                              }
//                                              else if (newsVC)
//                                              {
////                                                  [self.navigationController popToViewController:self animated:NO];
////                                                  [self setSelectedViewController:_chatListVC];
//                                              }
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
