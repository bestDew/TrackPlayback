//
//  AppDelegate.m
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface AppDelegate () <BMKGeneralDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BMKMapManager *mapManger = [[BMKMapManager alloc] init];
    BOOL ret = [mapManger start:@"SnDEV5cbXqyNIo2bYqZ8MQKD2ntxEj9N" generalDelegate:self];
    if (!ret) NSLog(@"start failed!");
    
    return YES;
}

#pragma mark -- BMKGeneral Delegate
- (void)onGetNetworkState:(int)iError
{
    if (iError != 0) NSLog(@"onGetNetworkState:%d", iError);
}

- (void)onGetPermissionState:(int)iError
{
    if (iError != 0) NSLog(@"onGetPermissionState:%d", iError);
}

@end
