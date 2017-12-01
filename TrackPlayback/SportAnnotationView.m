//
//  SportAnnotationView.m
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "SportAnnotationView.h"
#import "SportNode.h"

@interface SportAnnotationView ()
{
    NSInteger _currentIndex;   // 当前结点索引值
    NSInteger _animationState; // 标识动画状态 (0:动画未开始 1:动画中 2:动画暂停 3:动画完成)
}
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SportAnnotationView

#pragma mark -- 初始化
- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        self.bounds = CGRectMake(0.f, 0.f, 22.f, 22.f);
        self.draggable = NO;
        
        [self addSubview:self.imageView];
        
        _currentIndex = 1;
        _animationState = 0;
    }
    return self;
}

#pragma mark -- Method
- (void)start
{
    switch (_animationState) {
        case 0:
            [self running];
            break;
        case 1:
            break;
        case 2: {
            [self resume];
            break;
        }
        case 3:
            [self reset];
            [self running];
            break;
    }
}

- (void)pause
{
    _animationState = 2;
    
    // 将当前时间CACurrentMediaTime转换为layer上的时间, 即将parent time转换为local time
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置layer的timeOffset, 在继续操作也会使用到
    self.layer.timeOffset = pauseTime;
    self.paopaoView.layer.timeOffset = pauseTime;
    // local time与parent time的比例为0, 意味着local time暂停了
    self.layer.speed = 0;
    self.paopaoView.layer.speed = 0;
}

- (void)stop
{
    _animationState = 0;
    
    [self.layer removeAllAnimations];
    [self.paopaoView.layer removeAnimationForKey:@"position"];
    [self reset];
}

- (void)resume
{
    // 时间转换
    CFTimeInterval pauseTime = self.layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    // 取消
    self.layer.timeOffset = 0;
    self.paopaoView.layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    self.layer.beginTime = timeSincePause;
    self.paopaoView.layer.beginTime = timeSincePause;
    // 继续
    self.layer.speed = 1;
    self.paopaoView.layer.speed = 1;
    
    _animationState = 1;
}

#pragma mark -- Other
- (void)running
{
    _animationState = 1;
    
    SportNode *node_1 = _sportNodes[_currentIndex - 1];
    [UIView animateWithDuration:0.3 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(node_1.angle);
    }];
    
    NSLog(@"%.2f", node_1.distance / node_1.speed);
    
    if (_currentIndex == _sportNodes.count) {
        _animationState = 3;
        if (self.completion) self.completion();
        return;
    }
    
    SportNode *node_2 = _sportNodes[_currentIndex];
    [UIView animateWithDuration:node_1.distance/node_1.speed delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        self.annotation.coordinate = node_2.coordinate;
    } completion:^(BOOL finished) {
        if (_animationState == 1) {
            _currentIndex ++;
            [self running];
        }
    }];
}

- (void)reset
{
    _currentIndex = 1;
    
    SportNode *node = [_sportNodes firstObject];
    self.annotation.coordinate = node.coordinate;
    self.imageView.transform = CGAffineTransformMakeRotation(node.angle);
    
    self.layer.timeOffset = 0;
    self.paopaoView.layer.timeOffset = 0;
    self.layer.beginTime = 0;
    self.paopaoView.layer.beginTime = 0;
    self.layer.speed = 1;
    self.paopaoView.layer.speed = 1;
    
    _animationState = 0;
}

#pragma mark -- Setter && Getter
- (void)setSportNodes:(NSArray<SportNode *> *)sportNodes
{
    _sportNodes = sportNodes;
    
    SportNode *node = [self.sportNodes firstObject];
    self.imageView.transform = CGAffineTransformMakeRotation(node.angle);
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView.image = [UIImage imageNamed:@"sportarrow.png"];
    }
    return _imageView;
}

@end
