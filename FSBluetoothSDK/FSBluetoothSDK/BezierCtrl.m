//
//  BezierCtrl.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/3/29.
//

#import "BezierCtrl.h"

@interface BezierCtrl ()

@end

@implementation BezierCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 100, 300, 100) cornerRadius:50];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.fillColor = UIColor.clearColor.CGColor; // 空心
    layer.strokeColor = UIColor.blackColor.CGColor; // 黑边
    layer.lineWidth = 5; // 边宽度
    [self.view.layer addSublayer:layer];

    // 创建一个view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    view.backgroundColor = UIColor.redColor;
    view.layer.cornerRadius = 15;
    [self.view addSubview:view];

    // 添加动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    // 设置动画的路径为心形路径
    animation.path = path.CGPath;
    // 动画时间间隔
    animation.duration = 60.0f;
    // 400 * 3600 / 8000
    //动画速度变化
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.calculationMode = kCAAnimationPaced;
    // 重复次数为最大值
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    // 将动画添加到动画视图上
    [view.layer addAnimation:animation forKey:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
