//
//  HeTopicDetailCell.m
//  yu
//
//  Created by HeDongMing on 2016/10/22.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeTopicDetailCell.h"
#import "MLLabel+Size.h"
#import "MLLinkLabel.h"

#define TextLineHeight 1.2f

@implementation HeTopicDetailCell
@synthesize headInfoBg;
@synthesize imageInfoBg;
@synthesize contentTextInfoBg;
@synthesize otherInfoBg;
@synthesize timeLabel;
@synthesize rankNumLabel;
@synthesize nameLabel;
@synthesize disCoverImage;
@synthesize contentLabel;
@synthesize replyDict;
@synthesize commentButton;
@synthesize forwardButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        /********头部信息*******/
        CGFloat headX = 0;
        CGFloat headY = 0;
        CGFloat headW = SCREENWIDTH;
        CGFloat headH = 50;
        headInfoBg = [[UIView alloc] initWithFrame:CGRectMake(headX, headY, headW, headH)];
        headInfoBg.backgroundColor = [UIColor whiteColor];
        headInfoBg.userInteractionEnabled = YES;
        [self addSubview:headInfoBg];
        
        CGFloat headImageX = 10;
        CGFloat headImageY = 5;
        CGFloat headImageH = headH - 2 * headImageY;
        CGFloat headImageW = headImageH;
        
        UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(headImageX, headImageY, headImageW, headImageH)];
        headImage.layer.masksToBounds = YES;
        headImage.layer.cornerRadius = 3.0;
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        headImage.image = [UIImage imageNamed:@"userDefalut_icon"];
        //        [headInfoBg addSubview:headImage];
        
        NSString *name = @"马天宇";
        CGFloat nameX = 10;
        CGFloat nameY = headImageY;
        CGFloat nameH = headImageH;
        CGFloat nameW = SCREENWIDTH - 2 * nameX;
        UIFont *textFont = [UIFont systemFontOfSize:18.0];
        CGSize nameSize = [MLLinkLabel getViewSizeByString:name maxWidth:nameW font:textFont lineHeight:TextLineHeight lines:0];
        //        nameW = nameSize.width;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
        nameLabel.text = name;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = textFont;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.userInteractionEnabled = YES;
        [headInfoBg addSubview:nameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatWithUser:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [nameLabel addGestureRecognizer:tap];
        
        CGFloat timeW = 100;
        CGFloat timeX = SCREENWIDTH - headImageX - timeW;
        CGFloat timeY = headImageY;
        CGFloat timeH = nameH;
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.text = @"5小时前";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.textColor = [UIColor grayColor];
        [headInfoBg addSubview:timeLabel];
        
        CGFloat subInfoBgX = nameX;
        CGFloat subInfoBgY = CGRectGetMaxY(nameLabel.frame);
        CGFloat subInfoBgW = 50;
        CGFloat subInfoBgH = nameH;
        UIView *subInfoBg = [[UIView alloc] initWithFrame:CGRectMake(subInfoBgX, subInfoBgY, subInfoBgW, subInfoBgH)];
        subInfoBg.backgroundColor = [UIColor colorWithRed:254.0 /255.0 green:178.0 /255.0 blue:196.0 /255.0 alpha:1.0];
        //        [headInfoBg addSubview:subInfoBg];
        
        CGFloat iconY = 5;
        CGFloat iconH = subInfoBgH - 2 * iconY;
        CGFloat iconW = iconH;
        CGFloat iconX = (subInfoBgW / 2.0 - iconW) / 2.0;
        UIImageView *sexIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_man"]];
        sexIcon.frame = CGRectMake(iconX, iconY, iconW, iconH);
        sexIcon.backgroundColor = [UIColor clearColor];
        //        [subInfoBg addSubview:sexIcon];
        
        CGFloat ageX = subInfoBgW / 2.0;
        CGFloat ageY = 0;
        CGFloat ageH = subInfoBgH;
        CGFloat ageW = subInfoBgW / 2.0;
        UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(ageX, ageY, ageW, ageH)];
        ageLabel.text = @"12";
        ageLabel.textAlignment = NSTextAlignmentCenter
        ;
        ageLabel.backgroundColor = [UIColor clearColor];
        ageLabel.font = [UIFont systemFontOfSize:11.0];
        ageLabel.textColor = [UIColor whiteColor];
        //        [subInfoBg addSubview:ageLabel];
        
        /********图片区域*******/
        CGFloat imageX = 0;
        CGFloat imageY = CGRectGetMaxY(headInfoBg.frame);
        CGFloat imageW = SCREENWIDTH;
        CGFloat imageH = 120;
        imageInfoBg = [[UIView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        imageInfoBg.backgroundColor = [UIColor whiteColor];
        imageInfoBg.userInteractionEnabled = YES;
        [self addSubview:imageInfoBg];
        
        disCoverImage = [[UIImageView alloc] initWithFrame:imageInfoBg.bounds];
        disCoverImage.image = [UIImage imageNamed:@"comonDefaultImage"];
        disCoverImage.image = [UIImage imageNamed:@"demoImage_Girl.jpg"];
        disCoverImage.layer.masksToBounds = YES;
        disCoverImage.contentMode = UIViewContentModeScaleAspectFill;
        [imageInfoBg addSubview:disCoverImage];
        
        imageInfoBg.userInteractionEnabled = YES;
        disCoverImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeImage:)];
        tapGes.numberOfTouchesRequired = 1;
        tapGes.numberOfTapsRequired = 1;
        [disCoverImage addGestureRecognizer:tapGes];
        
        /********文字区域*******/
        CGFloat contentX = 0;
        CGFloat contentY = CGRectGetMaxY(imageInfoBg.frame);
        CGFloat contentW = SCREENWIDTH;
        CGFloat contentH = 40;
        contentTextInfoBg = [[UIView alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentTextInfoBg.backgroundColor = [UIColor whiteColor];
        contentTextInfoBg.userInteractionEnabled = YES;
        [self addSubview:contentTextInfoBg];
        
        CGFloat contentLabelX = 10;
        CGFloat contentLabelY = 0;
        CGFloat contentLabelH = contentH;
        CGFloat contentLabelW = SCREENWIDTH - 2 * contentLabelX;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
        contentLabel.text = @"她的智慧、学识超过她的年龄。";
        contentLabel.numberOfLines = 0;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.textColor = [UIColor blackColor];
        [contentTextInfoBg addSubview:contentLabel];
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, contentLabelH - 1, SCREENWIDTH, 1)];
        sepLine.tag = 100;
        sepLine.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [contentTextInfoBg addSubview:sepLine];
        
        /********其他区域*******/
        CGFloat otherX = 0;
        CGFloat otherY = CGRectGetMaxY(contentTextInfoBg.frame);
        CGFloat otherW = SCREENWIDTH;
        CGFloat otherH = 40;
        otherInfoBg = [[UIView alloc] initWithFrame:CGRectMake(otherX, otherY, otherW, otherH - 1)];
        otherInfoBg.backgroundColor = [UIColor whiteColor];
        otherInfoBg.userInteractionEnabled = YES;
        [self addSubview:otherInfoBg];
        
        UIView *sepLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, otherH - 1, SCREENWIDTH, 1)];
        sepLine1.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [otherInfoBg addSubview:sepLine1];
        
        CGFloat commentX = SCREENWIDTH / 2.0;
        CGFloat commentY = 5;
        CGFloat commentH = otherH - 2 * commentY;
        CGFloat commentW = 80;
        commentButton = [Tool getButton:CGRectMake(commentX, commentY, commentW, commentH) title:@"10" image:@"icon_comment"];
        [commentButton addTarget:self action:@selector(commment:) forControlEvents:UIControlEventTouchUpInside];
        [otherInfoBg addSubview:commentButton];
        
        CGFloat forwardX = CGRectGetMaxX(commentButton.frame) + 10;
        CGFloat forwardY = 5;
        CGFloat forwardH = otherH - 2 * commentY;
        CGFloat forwardW = 80;
        forwardButton = [Tool getButton:CGRectMake(forwardX, forwardY, forwardW, forwardH) title:@"10" image:@"icon_share"];
        [forwardButton addTarget:self action:@selector(foward:) forControlEvents:UIControlEventTouchUpInside];
        [otherInfoBg addSubview:forwardButton];
        
        
        CGFloat downY = 12;
        CGFloat downH = otherH - 2 * downY;
        CGFloat downW = downH * 1.1;
        CGFloat downX = SCREENWIDTH - 10 - downW;
        UIButton *downIcon = [[UIButton alloc] init];
        [downIcon setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
        downIcon.frame = CGRectMake(downX, downY, downW, downH);
        downIcon.tag = 1;
//        [otherInfoBg addSubview:downIcon];
        
        CGFloat rankNumLabelW = 40;
        CGFloat rankNumLabelX = CGRectGetMinX(downIcon.frame) - rankNumLabelW;
        CGFloat rankNumLabelY = downY;
        CGFloat rankNumLabelH = downH;
        
        rankNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(rankNumLabelX, rankNumLabelY, rankNumLabelW, rankNumLabelH)];
        rankNumLabel.text = @"10";
        rankNumLabel.textAlignment = NSTextAlignmentCenter;
        rankNumLabel.backgroundColor = [UIColor clearColor];
        rankNumLabel.font = [UIFont systemFontOfSize:13.0];
        rankNumLabel.textColor = [UIColor grayColor];
//        [otherInfoBg addSubview:rankNumLabel];
        
        CGFloat upY = 12;
        CGFloat upH = otherH - 2 * upY;
        CGFloat upW = downH * 1.1;
        CGFloat upX = CGRectGetMinX(rankNumLabel.frame) - upW;
        UIButton *upIcon = [[UIButton alloc] init];
        [upIcon setImage:[UIImage imageNamed:@"icon_up"] forState:UIControlStateNormal];
        upIcon.frame = CGRectMake(upX, upY, upW, upH);
        upIcon.tag = 2;
//        [otherInfoBg addSubview:upIcon];
        
        otherInfoBg.userInteractionEnabled = YES;
        [downIcon addTarget:self action:@selector(upDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [upIcon addTarget:self action:@selector(upDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)enlargeImage:(UITapGestureRecognizer *)ges
{
    UIView *myview = ges.view;
    NSDictionary *dict = @{@"view":myview};
    [self routerEventWithName:@"enlargeImage" userInfo:dict];
}



- (void)commment:(UIButton *)sender
{
    [self routerEventWithName:@"commment" userInfo:replyDict];
}

- (void)foward:(UIButton *)sender
{
    [self routerEventWithName:@"foward" userInfo:replyDict];
}

- (void)updateFrame
{
    CGFloat contentLabelH = contentTextInfoBg.frame.size.height;
    
    UIView *sepLine = [contentTextInfoBg viewWithTag:100];
    CGRect frame = sepLine.frame;
    frame.origin.y = contentLabelH - 1;
    sepLine.frame = frame;
    
    sepLine.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [contentTextInfoBg addSubview:sepLine];
    
    CGFloat otherX = 0;
    CGFloat otherY = CGRectGetMaxY(contentTextInfoBg.frame);
    CGFloat otherW = SCREENWIDTH;
    CGFloat otherH = 40;
    otherInfoBg.frame = CGRectMake(otherX, otherY, otherW, otherH);
}

- (void)upDownButtonClick:(UIButton *)sender
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *topicId = replyDict[@"topicId"];
    if (!topicId) {
        topicId = @"";
    }
    NSString *udType = @"0";
    if (sender.tag == 1) {
        udType = @"1";
    }
    NSDictionary *params = @{@"userId":userId,@"topicId":topicId,@"udType":udType};
    [self routerEventWithName:@"upDownButtonClick" userInfo:params];
}

- (void)chatWithUser:(id)sender
{
    [self routerEventWithName:@"chatUserEvent" userInfo:nil];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, ([UIColor colorWithWhite:237.0 / 255.0 alpha:1.0]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
