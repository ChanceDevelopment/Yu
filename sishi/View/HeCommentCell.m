//
//  HeCommentCell.m
//  yu
//
//  Created by HeDongMing on 2016/10/22.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeCommentCell.h"

@implementation HeCommentCell
@synthesize nameLabel;
@synthesize contentLabel;
@synthesize timeLabel;

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
        NSString *name = @"马天宇";
        CGFloat nameX = 10;
        CGFloat nameY = 5;
        CGFloat nameH = 25;
        CGFloat nameW = SCREENWIDTH - 2 * nameX;
        UIFont *textFont = [UIFont systemFontOfSize:15.0];

        //        nameW = nameSize.width;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
        nameLabel.text = name;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = textFont;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.userInteractionEnabled = YES;
        [self addSubview:nameLabel];
        
        CGFloat timeW = 100;
        CGFloat timeX = SCREENWIDTH - 10 - timeW;
        CGFloat timeY = nameY;
        CGFloat timeH = nameH;
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.text = @"5小时前";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.textColor = [UIColor grayColor];
        [self addSubview:timeLabel];
        
        CGFloat contentLabelX = 10;
        CGFloat contentLabelY = CGRectGetMaxY(nameLabel.frame);
        CGFloat contentLabelH = 25;
        CGFloat contentLabelW = SCREENWIDTH - 2 * contentLabelX;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
        contentLabel.text = @"她的智慧、学识超过她的年龄。";
        contentLabel.numberOfLines = 0;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.textColor = [UIColor grayColor];
        [self addSubview:contentLabel];
    }
    return self;
}

@end
