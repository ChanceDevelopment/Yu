//
//  HeUserVC.h
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface HeUserVC : HeBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}

@end
