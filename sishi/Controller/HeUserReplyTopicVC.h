//
//  HeDiscoverVC.h
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeUserReplyTopicVC : HeBaseViewController<EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@end
