//
//  HeSearchInfoVC.h
//  carTune
//
//  Created by Tony on 16/6/24.
//  Copyright © 2016年 Jitsun. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeSearchInfoVC : HeBaseViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate>
{
    BOOL isShowLeft;
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@end
