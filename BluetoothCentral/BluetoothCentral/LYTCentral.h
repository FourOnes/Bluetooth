//
//  LYTCentral.h
//  BluetoothCentral
//
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol LYTCentralDelegate <NSObject>
@required
-(void)receiveData:(NSData *)data;
@end

@interface LYTCentral : NSObject

-(id)init;
+(id)shareInstance;
-(void)write:(NSString *)str;
@property(strong,nonatomic) id<LYTCentralDelegate> delegate;
@end
