
#import "BleDevice.h"

@class BleDevice;
@class FSParams;
@class FSMotors;



extern NSString *_Nonnull const CHAR_READ_MFRS;
extern NSString *_Nonnull const CHAR_READ_PN;
extern NSString *_Nonnull const CHAR_READ_HV;
extern NSString *_Nonnull const CHAR_READ_SV;
extern NSString *_Nonnull const CHAR_NOTIFY_UUID;
extern NSString *_Nonnull const CHAR_WRITE_UUID;



NS_ASSUME_NONNULL_BEGIN

@interface FSDeviceParam : NSObject

/// 单位 0:公里  1: 英里
@property (nonatomic, assign) BOOL     imperial;
@property (nonatomic,   copy) NSString *maxSpeed;
@property (nonatomic,   copy) NSString *minSpeed;
@property (nonatomic,   copy) NSString *maxIncline;
@property (nonatomic,   copy) NSString *minIncline;
@property (nonatomic,   copy) NSString *maxLevel;
@property (nonatomic,   copy) NSString *minLevel;
@property (nonatomic,   copy) NSString *paragraph;
@property (nonatomic, assign) BOOL     supportIncline;
@property (nonatomic, assign) BOOL     supportLevel;
@property (nonatomic, assign) BOOL     supportControl; // G
@property (nonatomic, assign) BOOL     supportSpeed;
@property (nonatomic, assign) BOOL     supportPause;
@property (nonatomic, assign) NSString *totalDistance;

@end

@interface FSDeviceInfo : NSObject

@property (nonatomic,   copy) NSString *brand;
@property (nonatomic, strong) NSNumber *device;
@property (nonatomic, strong) NSNumber *factory;
@property (nonatomic,   copy) NSString *image;
@property (nonatomic, strong) NSNumber *model;
@property (nonatomic,   copy) NSString *name;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *paramString;
@property (nonatomic, strong) NSString *motorModeString;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

// 参数 最大速度、时间
- (FSParams *)paramModel;

// 电机模式
- (NSArray <FSMotors *>*)motorModels;

@end

@interface FSBaseDevice : BleDevice

// 心跳包 定时器
@property (nonatomic, strong) NSTimer       *_Nullable heartbeatTmr;
@property (nonatomic, strong) FSDeviceParam *deviceParam;
@property (nonatomic, strong) FSDeviceInfo  *deviceInfo;
@property (nonatomic, assign) BOOL          isStarting;
// G
@property (nonatomic, assign) BOOL          isRunning;
@property (nonatomic, assign) BOOL          isPausing;
@property (nonatomic, assign) BOOL          isWillStart;
@property (nonatomic, assign) BOOL          hasStoped;
@property (nonatomic, assign) BOOL          speedObtainSuccess;
@property (nonatomic, assign) BOOL          inclineObtainSuccess;
@property (nonatomic, assign) BOOL          writeUserDataSuccess;
// datas
@property (nonatomic,   copy) NSString      *speed;
@property (nonatomic,   copy) NSString      *display_speed; // G
@property (nonatomic,   copy) NSString      *incline;
@property (nonatomic,   copy) NSString      *exerciseTime;
@property (nonatomic,   copy) NSString      *heartRate;
@property (nonatomic,   copy) NSString      *errorCode;
@property (nonatomic,   copy) NSString      *weight;
@property (nonatomic,   copy) NSString      *height;
@property (nonatomic,   copy) NSString      *age;
@property (nonatomic,   copy) NSString      *gender;
@property (nonatomic,   copy) NSString      *adjustSpeed;
@property (nonatomic,   copy) NSString      *adjustIncline;
@property (nonatomic,   copy) NSString      *resistance;
@property (nonatomic,   copy) NSString      *frequency;
@property (nonatomic,   copy) NSString      *countdownSeconds;
@property (nonatomic,   copy) NSString      *watt;
@property (nonatomic,   copy) NSString      *distance;  // 设备上报的数据
@property (nonatomic,   copy) NSString      *displayDistance; // 千米 或 英里
@property (nonatomic,   copy) NSString      *calculateDist;   // 计算距离，内部同步转换成米计算
@property (nonatomic,   copy) NSString      *calory;    //
@property (nonatomic,   copy) NSString      *steps;     // 步数
@property (nonatomic,   copy) NSString      *counts;    // 次数
@property (nonatomic,   copy) NSString      *paragraph; // 段数
@property (nonatomic,   copy) NSString      *uid;       // 运动ID

@property (nonatomic,   copy) NSString      *targetSpeed;   // 目标速度
@property (nonatomic,   copy) NSString      *targetIncline; // 目标坡度
@property (nonatomic,   copy) NSString      *targetLevel;   // 目标阻力

@property (nonatomic, assign) BOOL           stopWithCmd; // 是否通过指令停止 22.7.5 添加

@property (nonatomic, assign) FSDiscontrolType discontrolType; // 失控类型

- (BOOL)start;

- (void)stop;

- (void)targetSpeed:(int)targetSpeed incline:(int)targetIncline;

- (void)setTargetLevl:(int)t_level incline:(int)t_incline;

- (void)sendData:(NSData *)data;

- (void)dataReset;

// 心跳包的定时器放
- (void)updateState:(NSTimer *__nullable)sender;

- (void)updateDeviceParams; // 更新数据参数

// 重启模块
- (void)fsRestartBleModule;
// 定次数
- (void)minDeviceCnts:(NSInteger)cnt;
// 定时间
- (void)minDeviceTime:(NSInteger)time;
// 小件暂停
- (void)minPause;
// 小件重启
- (void)minRestore;

// 甩脂机---------------------------
// 甩脂机的程序模式
- (void)slimmingStartParagram;

// 甩脂机  控制速度
- (void)slimmingTargetSpeed:(int)speed;

// 甩脂机  控制时间
- (void)slimmingTargetTime:(int)time;

/// 发送相同时间还是无效
/// 修改时间 加randomNum参数是为了避免与上一条指令一模一样而设备不响应
- (void)slimmingTargetTime:(int)time randomNum:(int)randomNum;

/// 甩脂机 切换模式
- (void)slimmingSwitchMode;

// 21.12.16 power_cmd
- (void)cleanAll;
- (void)cleanCals;
- (void)cleanCnts;
- (void)cleanTime;

- (int)paramRangeOfMax:(int)maxValue min:(int)minValue compare:(int)value;

- (int)signedParam:(int)value;





@end


NS_ASSUME_NONNULL_END
