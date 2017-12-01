//
//  SportNode.m
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "SportNode.h"

@implementation SportNode

+ (instancetype)nodeWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        _coordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
        _angle = [dict[@"angle"] doubleValue];
        _distance = [dict[@"distance"] doubleValue];
        _speed = [dict[@"speed"] doubleValue];
    }
    return self;
}

@end
