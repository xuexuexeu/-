//
//  ViewController.m
//  bluetoothTest
//
//  Created by apple on 2019/1/23.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;
// 文本  显示的内容
@property (weak, nonatomic) IBOutlet UITextView *peripheralContentTextView;
- (IBAction)saomiaoBtnClick:(id)sender;
- (IBAction)lianjieBtnClick:(id)sender;
- (IBAction)qingkongBtnClick:(id)sender;
@end
// 蓝牙4.0设备名
static NSString * const kBlePeripheralName = @"公司硬件蓝牙名称";
// 通知服务
static NSString * const kNotifyServerUUID = @"FFE0";
// 写服务
static NSString * const kWriteServerUUID = @"FFE1";
// 通知特征值
static NSString * const kNotifyCharacteristicUUID = @"FFE2";
// 写特征值
static NSString * const kWriteCharacteristicUUID = @"FFE3";
@implementation ViewController
//创建中心管理者  创建蓝牙管理者对象
-(CBCentralManager *)centralManager{
    if (_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//        _centralManager.delegate = self;
    }
    return _centralManager;
}

//创建存储设备数组
- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saomiaoBtnClick:(id)sender {
    //开始扫描前  先断开以前的扫描链接
    [self.centralManager stopScan];
    NSLog(@"扫描设备");
//    [self showMessage:@"扫描设备"];
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        // 扫描所有设备,传入nil,代表所有设备.
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (IBAction)lianjieBtnClick:(id)sender {
}

- (IBAction)qingkongBtnClick:(id)sender {
}




// 当状态更新时调用(如果不实现会崩溃)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"未知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
        }
            break;
        default:
            break;
    }
}

#pragma mark  CBCentralManagerDelegate
/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
//    [self showMessage:[NSString stringWithFormat:@"发现设备,设备名:%@",peripheral.name]];
    
    if (![self.peripherals containsObject:peripheral])
    {
        [self.peripherals addObject:peripheral];
        NSLog(@"%@",peripheral);
        
        if ([peripheral.name isEqualToString:kBlePeripheralName])
        {
//            [self showMessage:[NSString stringWithFormat:@"设备名:%@",peripheral.name]];
            self.cbPeripheral = peripheral;
            
//            [self showMessage:@"开始连接"];
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
    }
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    [self showMessage:@"连接失败"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接断开
 
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    [self showMessage:@"断开连接"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接设备:%@成功",peripheral.name);
//    [self showMessage:[NSString stringWithFormat:@"连接设备:%@成功",peripheral.name]];
    
    // 设置设备的代理
    peripheral.delegate = self;
    // services:传入nil代表扫描所有服务
    [peripheral discoverServices:nil];
}

#pragma mark  CBPeripheralDelegate
/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务:%@",service.UUID.UUIDString);
        // 获取对应的服务
        if ([service.UUID.UUIDString isEqualToString:kWriteServerUUID] || [service.UUID.UUIDString isEqualToString:kNotifyServerUUID])
        {
            // 根据服务去扫描特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // 遍历所有的特征
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"特征值:%@",characteristic.UUID.UUIDString);
        // 获取对应的特征
        if ([characteristic.UUID.UUIDString isEqualToString:kWriteCharacteristicUUID])
        {
            // 写入数据
//            [self showMessage:@"写入特征值"];
            for (Byte i = 0x0; i < 0x73; i++)
            {
                // 让钢琴的每颗灯都亮一次
                Byte byte[] = {0xf0, 0x3d, 0x3d, i,
                    0x02,0xf7};
                NSData *data = [NSData dataWithBytes:byte length:6];
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
        if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
        {
            // 订阅特征通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        }
    }
}

/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
    {
        NSData *data = characteristic.value;
        NSLog(@"%@",data);
    }
}
@end
