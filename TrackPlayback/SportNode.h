//
//  SportNode.h
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SportNode : NSObject

/** 经纬度 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/** 方向（角度）*/
@property (nonatomic, assign) CGFloat angle;

/** 距离 */
@property (nonatomic, assign) CGFloat distance;

/** 速度 */
@property (nonatomic, assign) CGFloat speed;

+ (instancetype)nodeWithDictionary:(NSDictionary *)dict;

@end
