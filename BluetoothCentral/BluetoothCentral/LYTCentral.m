//
//  LYTCentral.m
//  BluetoothCentral
//  bluetooth central device
//  Created by limingru on 15/12/3.
//  Copyright © 2015年 limingru. All rights reserved.
//

#import "LYTCentral.h"
#define LYTPeripheralWritedServiceUUID @"121be011-b979-4921-a8d5-3b69124a3266"
#define LYTCharacteristicWritedUUID @"31c8dc61-c519-4ed6-adeb-968859bfe023"

#define LYTPeripheralReadedServiceUUID @"586c4179-83a1-4862-9864-7b2030cb2f76"
#define LYTCharacteristicReadedUUID @"6ea990c7-ca93-4e63-9bd7-460f308c0d13"

@interface LYTCentral()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(strong,nonatomic) CBCentralManager *centralManager;
@property(strong,nonatomic) NSMutableArray *peripherals;
@property(strong,nonatomic) CBCharacteristic *writeCharacteristic;
@property(strong,nonatomic) CBPeripheral *wPeripheral;
@end
static LYTCentral *shareLYTCentral;
@implementation LYTCentral
-(id)init{
    self=[super init];
    if(self){
        _centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
        _peripherals=[NSMutableArray new];
    }
    return self;
}
+(id)shareInstance{
    if(shareLYTCentral) return shareLYTCentral;
    shareLYTCentral=[[LYTCentral alloc]init];
    return shareLYTCentral;
}
-(void)write:(NSString *)str{
    [self.wPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark --CBCentralManagerDelegate

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"error=%@",error.localizedDescription);
}
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
        }
        default:
        {
            [@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备." tipsInfo];
            break;
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //NSLog(@"发现外围设备=%@,name=%@",peripheral.identifier.UUIDString,peripheral.name);
    if(peripheral){
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
            NSLog(@"连接外围设备");
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功！");
    peripheral.delegate=self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:LYTPeripheralReadedServiceUUID],[CBUUID UUIDWithString:LYTPeripheralWritedServiceUUID]]];
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
}
//找到服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CBUUID *readServiceUUID=[CBUUID UUIDWithString:LYTPeripheralReadedServiceUUID];
    CBUUID *writeServiceUUID=[CBUUID UUIDWithString:LYTPeripheralWritedServiceUUID];
    for (CBService *service in peripheral.services) {
        if([service.UUID isEqual:readServiceUUID]){
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:LYTCharacteristicReadedUUID]] forService:service];
        }
        if([service.UUID isEqual:writeServiceUUID]){
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:LYTCharacteristicWritedUUID]] forService:service];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    CBUUID *readServiceUUID=[CBUUID UUIDWithString:LYTPeripheralReadedServiceUUID];
    CBUUID *writeServiceUUID=[CBUUID UUIDWithString:LYTPeripheralWritedServiceUUID];
    CBUUID *readCharUUID=[CBUUID UUIDWithString:LYTCharacteristicReadedUUID];
    CBUUID *writeCharUUID=[CBUUID UUIDWithString:LYTCharacteristicWritedUUID];
    if([service.UUID isEqual:readServiceUUID]){
        for (CBCharacteristic *characteristic in service.characteristics) {
            if([characteristic.UUID isEqual:readCharUUID]){
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
    if([service.UUID isEqual:writeServiceUUID]){
        for (CBCharacteristic *chaa in service.characteristics) {
            if([chaa.UUID isEqual:writeCharUUID]){
                self.writeCharacteristic=chaa;
                self.wPeripheral=peripheral;
            }
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"收到特征更新通知...");
    CBUUID *readCharUUID=[CBUUID UUIDWithString:LYTCharacteristicReadedUUID];
    if([characteristic.UUID isEqual:readCharUUID]){
        if(characteristic.isNotifying){
            if(characteristic.properties==CBCharacteristicPropertyNotify){
                NSLog(@"已订阅特征通知.");
            }
            else if (characteristic.properties ==CBCharacteristicPropertyRead) {
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
        else{
            NSLog(@"停止已停止.");
            //取消连接
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}
//更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    if (characteristic.value) {
        [self.delegate receiveData:characteristic.value];
        NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"读取到特征值：%@",value);
    }else{
        NSLog(@"未发现特征值.");
    }
}
@end
