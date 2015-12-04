//
//  LYTPeripheral.h
//  BluetoothCentral
//  bluetooth peripheral device
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol LYTPeripheralDelegate<NSObject>
@required
-(void)receiveData:(NSData *)data;
@end

@interface LYTPeripheral : NSObject
+(id)shareInstance;
-(id)init;
-(void)notify:(NSString *)str;
@property(nonatomic,strong) id<LYTPeripheralDelegate> delegate;
@end
