//
//  HeTopicDetailVC.h
//  yu
//
//  Created by HeDongMing on 2016/10/22.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeBaseViewController.h"

@interface HeTopicDetailVC : HeBaseViewController
{
    BOOL isScroll;
}
@property(strong,nonatomic)NSDictionary *topicDetailDict;
@property(strong,nonatomic)IBOutlet UITextField *commentField;
@property(strong,nonatomic)IBOutlet UILabel *commentBGLabel;

@end
