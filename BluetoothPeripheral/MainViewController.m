//
//  MainViewController.m
//  BluetoothCentral
//
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import "MainViewController.h"
#import "LYTPeripheral.h"

@interface MainViewController ()<LYTPeripheralDelegate>
{
    LYTPeripheral *peripheral;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    peripheral=[LYTPeripheral shareInstance];
    peripheral.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point= [[touches anyObject] locationInView:self.view];
    [self updateBall:point];
    [peripheral notify:[NSString stringWithFormat:@"{\"x\":%f,\"y\":%f}",point.x,point.y]];
}

-(void)receiveData:(NSData *)data{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    CGPoint point=CGPointMake([dic[@"x"] floatValue], [dic[@"y"] floatValue]);
    [self updateBall:point];
}

-(void)updateBall:(CGPoint)point{
    self.ball.frame=CGRectMake(point.x, point.y, self.ball.frame.size.width, self.ball.frame.size.height);
}
@end
