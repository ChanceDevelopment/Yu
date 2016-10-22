//
//  HeTopicDetailCell.h
//  yu
//
//  Created by HeDongMing on 2016/10/22.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeTopicDetailCell : HeBaseTableViewCell
@property(strong,nonatomic)UIView *headInfoBg;
@property(strong,nonatomic)UIView *imageInfoBg;
@property(strong,nonatomic)UIView *contentTextInfoBg;
@property(strong,nonatomic)UIView *otherInfoBg;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UILabel *rankNumLabel;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UIImageView *disCoverImage;
@property(strong,nonatomic)UILabel *contentLabel;
@property(strong,nonatomic)UIButton *commentButton;
@property(strong,nonatomic)UIButton *forwardButton;

@property(strong,nonatomic)NSDictionary *replyDict;

- (void)updateFrame;

@end
