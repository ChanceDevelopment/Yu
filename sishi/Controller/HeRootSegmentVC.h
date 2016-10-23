//
//  HeRootSegmentVC.h
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "LXSegmentController.h"

@interface HeRootSegmentVC : LXSegmentController
{
    EMConnectionState _connectionState;
}

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)setupUnreadMessageCount;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)playSoundAndVibration;

- (void)showNotificationWithMessage:(EMMessage *)message;

@end
