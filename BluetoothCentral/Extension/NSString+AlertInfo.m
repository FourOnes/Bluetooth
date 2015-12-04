//
//  NSString+AlertInfo.m
//  BluetoothCentral
//
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import "NSString+AlertInfo.h"

@implementation NSString (AlertInfo)

-(void)tipsInfo{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:self delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
@end
