//
//  LYTPeripheral.m
//  BluetoothCentral
//
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import "LYTPeripheral.h"
#define LYTPeripheralWritedServiceUUID @"121be011-b979-4921-a8d5-3b69124a3266"
#define LYTCharacteristicWritedUUID @"31c8dc61-c519-4ed6-adeb-968859bfe023"

#define LYTPeripheralReadedServiceUUID @"586c4179-83a1-4862-9864-7b2030cb2f76"
#define LYTCharacteristicReadedUUID @"6ea990c7-ca93-4e63-9bd7-460f308c0d13"

@interface LYTPeripheral()<CBPeripheralManagerDelegate>
@property(strong,nonatomic) CBPeripheralManager *peripharalManager;
@property(strong,nonatomic) NSMutableArray *centralManagers;
//可写服务
@property(strong,nonatomic) CBMutableService *writedService;
//可写特征
@property(strong,nonatomic) CBMutableCharacteristic *writeCharacteristic;

//读服务
@property(strong,nonatomic) CBMutableService *readedService;
//读特征
@property(strong,nonatomic) CBMutableCharacteristic *readedCharacteristic;

@end
static LYTPeripheral *shareLYTPeripheral;
@implementation LYTPeripheral
+(id)shareInstance{
    if(shareLYTPeripheral) return shareLYTPeripheral;
    shareLYTPeripheral=[[LYTPeripheral alloc]init];
    return shareLYTPeripheral;
}
-(id)init{
    self=[super init];
    if(self){
        _peripharalManager=[[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}
-(void)setupPeripheral{
    //写服务和特征
    CBUUID *writedServiceUUID=[CBUUID UUIDWithString:LYTPeripheralWritedServiceUUID];
    CBUUID *writedCharacteristicUUID=[CBUUID UUIDWithString:LYTCharacteristicWritedUUID];
    _writedService=[[CBMutableService alloc]initWithType:writedServiceUUID primary:YES];
    _writeCharacteristic=[[CBMutableCharacteristic alloc]initWithType:writedCharacteristicUUID properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
    [self.writedService setCharacteristics:@[self.writeCharacteristic]];
    
    //读、订阅
    CBUUID *readedServiceUUID=[CBUUID UUIDWithString:LYTPeripheralReadedServiceUUID];
    CBUUID *readedCharacteristicUUID=[CBUUID UUIDWithString:LYTCharacteristicReadedUUID];
    _readedService=[[CBMutableService alloc]initWithType:readedServiceUUID primary:YES];
    _readedCharacteristic=[[CBMutableCharacteristic alloc]initWithType:readedCharacteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    [self.readedService setCharacteristics:@[self.readedCharacteristic]];
    
    [self.peripharalManager addService:self.writedService];
    [self.peripharalManager addService:self.readedService];
    
    NSLog(@"安装服务完成！");
}
#pragma mark --CBPeripheralManager 代理方法
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            [self setupPeripheral];
            break;
        }
        default:
        {
            [@"此设备不支持BLE或未打开蓝牙功能" tipsInfo];
            break;
        }
    }
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if(error){
        [error.localizedDescription tipsInfo];
        return;
    }
    if(!self.peripharalManager.isAdvertising){
        NSDictionary *dic=@{CBAdvertisementDataLocalNameKey:@"limingru peripheral"};//广播设置
        [self.peripharalManager startAdvertising:dic];//开始广播
    }
}
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if(error){
        [error.localizedDescription tipsInfo];
        return;
    }
}
@end
