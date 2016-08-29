//
//  HeChatTableCell.m
//  sishi
//
//  Created by HeDongMing on 16/8/18.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeChatTableCell.h"

@implementation HeChatTableCell
@synthesize headImage;
@synthesize titleLabel;
@synthesize contentLabel;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat headX = 10;
        CGFloat headY = 10;
        CGFloat headW = 60;
        CGFloat headH = headW;
        headImage = [[UIImageView alloc] initWithFrame:CGRectMake(headX, headY, headW, headH)];
        headImage.image = [UIImage imageNamed:@"demo_nearBgImage.jpg"];
        headImage.layer.masksToBounds = YES;
        headImage.layer.cornerRadius = headW / 2.0;
        headImage.layer.borderColor = [UIColor whiteColor].CGColor;
        headImage.layer.borderWidth = 1.0;
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headImage];
        
        CGFloat titleX = CGRectGetMaxX(headImage.frame) + 10;
        CGFloat titleY = headY;
        CGFloat titleW = SCREENWIDTH - titleX - headX;
        CGFloat titleH = headH / 2.0;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:20.0];
        titleLabel.text = @"何晓明";
        [self addSubview:titleLabel];
        
        
        CGFloat tipX = CGRectGetMaxX(headImage.frame) + 10;;
        CGFloat tipY = CGRectGetMaxY(titleLabel.frame);
        CGFloat tipW = SCREENWIDTH - 2 * tipX;
        CGFloat tipH = headH / 2.0;;
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipX, tipY, tipW, tipH)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor redColor];
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.text = @"晚上一起去吃饭吧";
        [self addSubview:contentLabel];
    }
    return self;
}

@end
