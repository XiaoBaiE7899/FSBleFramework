
// FS 蓝牙库的枚举文件

#ifndef FSEnum_h
#define FSEnum_h

// 系统蓝牙的 状态，只有FSManagerStatePoweredOn 可以使用
typedef NS_ENUM(NSInteger, FSManagerState) {
    /* 蓝牙电源已关闭 */
    FSManagerStatePoweredOff,
    /* 正常可用状态 */
    FSManagerStatePoweredOn,
    /* 设备不支持蓝牙功能 */
    FSManagerStateUnsupported,
};

/*
 设备类型
 通过蓝牙扫描得到的广播包 解析得到的
 */
typedef NS_ENUM(NSInteger, FSDeviceType) {
    /* 跑步机 */
    FSDeviceTypeTreadmill      = 0,
    /* 椭圆机 */
    FSDeviceTypeEllipse        = 1,
    /* 健身车 */
    FSDeviceTypeFitnessCar     = 2,
    /* 划船器 */
    FSDeviceTypeRowing         = 3,
    /* 骑马器 */
    FSDeviceTypeRider          = 4,
    /* 走步机 */
    FSDeviceTypeWalking        = 5,
    /* 跳绳  这个协议还没增加进来 */
    FSDeviceTypeUnknow
}; // Protocol


/*
 蓝牙协议类型
 */
typedef NS_ENUM(NSInteger, BleProtocolType) {
    /* 未知*/
    BleProtocolTypeUnknow         = -1,
    /* 跑步机 */
    BleProtocolTypeTreadmill      = 0,
    /* 椭圆机 */
    BleProtocolTypeCarTable       = 1,
};




#endif /* FSEnum_h */
