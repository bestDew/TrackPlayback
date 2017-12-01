//
//  ViewController.m
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "ViewController.h"
#import "SportNode.h"
#import "SportAnnotationView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController () <BMKMapViewDelegate>
{
    SportAnnotationView *_sportAnnotationView;
}
@property (nonatomic, weak) BMKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *sportNodes; // 轨迹点

@end

@implementation ViewController

#pragma mark -- Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSportNodes];
    [self addSubViews];
}

#pragma mark -- Action
- (void)trackPlayback:(UIButton *)button
{
    switch (button.tag) {
        case 10: {
            button.selected = !button.selected;
            if (button.selected) {
                [_sportAnnotationView start];
            } else {
                [_sportAnnotationView pause];
            }
            break;
        }
        case 11: {
            UIButton *startButton = (UIButton *)[self.view viewWithTag:10];
            if (startButton.selected) startButton.selected = NO;
            [_sportAnnotationView stop];
            break;
        }
    }
}

#pragma mark -- BMKMapView Delegate
/** 地图加载完成 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    CLLocationCoordinate2D coors[self.sportNodes.count];
    for (NSInteger i = 0; i < self.sportNodes.count; i++) {
        SportNode *node = self.sportNodes[i];
        coors[i] = node.coordinate;
    }
    
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:self.sportNodes.count];
    [_mapView addOverlay:polyline];
    
    BMKPointAnnotation *sportAnnotation = [[BMKPointAnnotation alloc]init];
    sportAnnotation.coordinate = coors[0];
    sportAnnotation.title = @"轨迹回放";
    [_mapView addAnnotation:sportAnnotation];
}

/** 根据overlay生成对应的View */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if (![overlay isKindOfClass:[BMKPolyline class]]) return nil;
    
    BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:0.98 green:0.25 blue:0.11 alpha:0.6];
    polylineView.lineWidth = 3.0;
    
    return polylineView;
}

/** 根据anntation生成对应的View */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    __weak typeof(self) weakSelf = self;
    _sportAnnotationView = (SportAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"SportsAnnotation"];
    if (_sportAnnotationView == nil) {
        _sportAnnotationView = [[SportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SportsAnnotation"];
        _sportAnnotationView.sportNodes = self.sportNodes;
        _sportAnnotationView.selected = YES;
        _sportAnnotationView.completion = ^{
            UIButton *startButton = (UIButton *)[weakSelf.view viewWithTag:10];
            startButton.selected = NO;
        };
    }
    return _sportAnnotationView;
}

#pragma mark -- Other
- (void)addSubViews
{
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView.rotateEnabled = NO;
    mapView.delegate = self;
    mapView.zoomLevel = 19.2;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(40.056898, 116.307626);
    [self.view addSubview:mapView];
    _mapView = mapView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 4, SCREEN_HEIGHT - 60, SCREEN_WIDTH / 2, 40)];
    view.backgroundColor = [UIColor lightGrayColor];
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset =  CGSizeMake(0.5, 0.5);
    view.layer.shadowOpacity = 0.5;
    [self.view addSubview:view];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(0, 0, (view.frame.size.width - 0.5) / 2, 40);
    startButton.backgroundColor = [UIColor whiteColor];
    startButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [startButton setTitle:@"开始" forState:UIControlStateNormal];
    [startButton setTitle:@"暂停" forState:UIControlStateSelected];
    [startButton setTitleColor:[UIColor colorWithRed:0.09 green:0.54 blue:0.90 alpha:1.00] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(trackPlayback:) forControlEvents:UIControlEventTouchUpInside];
    startButton.tag = 10;
    [view addSubview:startButton];
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stopButton.frame = CGRectMake((view.frame.size.width - 0.5) / 2 + 0.5, 0, (view.frame.size.width - 0.5) / 2, 40);
    stopButton.backgroundColor = [UIColor whiteColor];
    stopButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor colorWithRed:0.09 green:0.54 blue:0.90 alpha:1.00] forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(trackPlayback:) forControlEvents:UIControlEventTouchUpInside];
    stopButton.tag = 11;
    [view addSubview:stopButton];
}

- (void)initSportNodes
{
    self.sportNodes = [NSMutableArray array];
    
    // 读取数据
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sport_path" ofType:@"json"]];
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    for (NSDictionary *dict in dataArray) {
        SportNode *node = [SportNode nodeWithDictionary:dict];
        [self.sportNodes addObject:node];
    }
}

@end
