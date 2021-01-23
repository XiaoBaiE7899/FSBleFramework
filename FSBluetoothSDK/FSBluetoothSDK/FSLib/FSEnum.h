
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


#endif /* FSEnum_h */
