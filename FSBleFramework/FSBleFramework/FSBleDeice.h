
#import "BleDevice.h"

@class BleDevice;
@class FSParams;
@class FSMotors;


// 模块厂商
extern NSString *_Nonnull const CHAR_READ_MFRS;

// 模块机型
extern NSString *_Nonnull const CHAR_READ_PN;

// 硬件版本
extern NSString *_Nonnull const CHAR_READ_HV;

// 软件版本
extern NSString *_Nonnull const CHAR_READ_SV;

// 运动秀的通知通道
extern NSString *_Nonnull const CHAR_NOTIFY_UUID;

// 运动秀的可写通道
extern NSString *_Nonnull const CHAR_WRITE_UUID;



NS_ASSUME_NONNULL_BEGIN

/*
 设备的参数信息
 */

@interface FSDeviceParam : NSObject

// 单位 0:公里  1: 英里  544344117
@property (nonatomic, assign) BOOL     imperial;

// 最大速度，def:@"0"
@property (nonatomic,   copy) NSString *maxSpeed;

// 最小速度，设备的启动速度, def:@"0"
@property (nonatomic,   copy) NSString *minSpeed;

// 最大坡度， def:@"0"
@property (nonatomic,   copy) NSString *maxIncline;

// 最小坡度, def:@"0"
@property (nonatomic,   copy) NSString *minIncline;

// 最大阻力， def: @"0"
@property (nonatomic,   copy) NSString *maxLevel;

// 最小阻力, def:@"0"
@property (nonatomic,   copy) NSString *minLevel;

// 程序段数, 这个属性在SDK 没有实际使用过
@property (nonatomic,   copy) NSString *paragraph;

// 是否支持坡度控制 设备的最大坡度大于最小坡度，表示坡度是支持控制的
@property (nonatomic, assign) BOOL     supportIncline;

// 是否支持阻力控制 设备的最大阻力大于最小阻力，表示阻力支持控制
@property (nonatomic, assign) BOOL     supportLevel;

// 是否是否支持速度控制
@property (nonatomic, assign) BOOL     supportSpeed;

// 只要速度、坡度、阻力有一个可以控制，就表示设备支持控制
@property (nonatomic, assign) BOOL     supportControl; // G

// 设备是否支持暂停， 因为有厂家没有严格按照协议对接， 通模块上报的数据判断是否支持暂停是不准确
@property (nonatomic, assign) BOOL     supportPause;

// 设备的总距离，该属性在没有实际意义，
@property (nonatomic, assign) NSString *totalDistance;

@end

// 设备信息  通过后台获取的数据
@interface FSDeviceInfo : NSObject

// 品牌
@property (nonatomic,   copy) NSString *brand;

// 设备id
@property (nonatomic, strong) NSNumber *device;

// 厂商码
@property (nonatomic, strong) NSNumber *factory;

// 设备图片
@property (nonatomic,   copy) NSString *image;

// 机型码
@property (nonatomic, strong) NSNumber *model;

// 设备名字  后台配置的名字，
@property (nonatomic,   copy) NSString *name;

// 设备类型
@property (nonatomic, strong) NSNumber *type;

// 参数字符串  甩脂机使用
@property (nonatomic, strong) NSString *paramString;

// 点击模式    甩脂机使用
@property (nonatomic, strong) NSString *motorModeString;

// 初始化方法，根据后台返回的数据，转成模型数据
+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

// 参数 最大速度、时间
- (FSParams *)paramModel;

// 电机模式
- (NSArray <FSMotors *>*)motorModels;

@end

@interface FSBaseDevice : BleDevice



// 设备参数
@property (nonatomic, strong) FSDeviceParam *deviceParam;

// 设备信息
@property (nonatomic, strong) FSDeviceInfo  *deviceInfo;

// 设置是否正在启动中，运动秀APP有使用的这个属性做相应判断
@property (nonatomic, assign) BOOL          isStarting;

// 设备是否正在运行中
@property (nonatomic, assign) BOOL          isRunning;

// 设备是否处于暂停中 暂停的问题内部做了很多适配，
@property (nonatomic, assign) BOOL          isPausing;

// 设备是将要启动， 运动秀app有使用到
@property (nonatomic, assign) BOOL          isWillStart;

// 设备是否已经完全停止
@property (nonatomic, assign) BOOL          hasStoped;

// 速度参数获取成功
@property (nonatomic, assign) BOOL          speedObtainSuccess;

// 坡度参数是否获取成功
@property (nonatomic, assign) BOOL          inclineObtainSuccess;

// 写入用户数据是成功， AB决定，只要写入一次，不管成功与否， 因此内部在调用发送指令--写入用户数据时就会数组为YES, def:NO
@property (nonatomic, assign) BOOL          writeUserDataSuccess;

// 速度  模块上报的速度
@property (nonatomic,   copy) NSString      *speed;

// 表显速度
@property (nonatomic,   copy) NSString      *display_speed;

// 坡度  模块上报的数据
@property (nonatomic,   copy) NSString      *incline;

// 运动时间，单位秒，模块上报的时间
@property (nonatomic,   copy) NSString      *exerciseTime;

// 心率， 模块上报的数据
@property (nonatomic,   copy) NSString      *heartRate;

// 错误代码，模块上报的错误码， def:0 表示没有错误
@property (nonatomic,   copy) NSString      *errorCode;

// 体重
@property (nonatomic,   copy) NSString      *weight;

// 身高
@property (nonatomic,   copy) NSString      *height;

// 年龄
@property (nonatomic,   copy) NSString      *age;

// 性别
@property (nonatomic,   copy) NSString      *gender;

// 调整速度，模块上报的数据，实际没有使用到这个数据
@property (nonatomic,   copy) NSString      *adjustSpeed;

// 调整坡度，模块上报的数据，实际没有使用到这个数据
@property (nonatomic,   copy) NSString      *adjustIncline;

// 阻力， 模块上报数据
@property (nonatomic,   copy) NSString      *resistance;

// 频率， 模块上报数据
@property (nonatomic,   copy) NSString      *frequency;

// 倒计时， 第一次上报的秒杀，之后再次上报的数据则忽略
@property (nonatomic,   copy) NSString      *countdownSeconds;

// 瓦特 模块上报数据
@property (nonatomic,   copy) NSString      *watt;

// 距离  模块上报数据
@property (nonatomic,   copy) NSString      *distance;  // 设备上报的数据

// 表显距离， 保留2位小数，单位根据设备参数信息的imperial，显示  公里或英里
@property (nonatomic,   copy) NSString      *displayDistance; // 千米 或 英里

// 计算距离，内部同步转换成米计算
@property (nonatomic,   copy) NSString      *calculateDist;

// 卡路里 模块上报数据
@property (nonatomic,   copy) NSString      *calory;

// 步数 跑步机 模块上报数据
@property (nonatomic,   copy) NSString      *steps;

// 次数 车表 模块上报数据
@property (nonatomic,   copy) NSString      *counts;

// 段数 模块上报数据 实际没使用
@property (nonatomic,   copy) NSString      *paragraph;

// 运动ID 模块上报数据 实际没使用
@property (nonatomic,   copy) NSString      *uid;

// 目标速度  精度0.1, 如:需要把设备的速度调到5KM/H, 把这个属性设置为50
@property (nonatomic,   copy) NSString      *targetSpeed;

// 目标坡度  精度1 如:需要包设备的坡度调到5, 把这个属性设置为5
@property (nonatomic,   copy) NSString      *targetIncline;

// 目标阻力 精度1 如:需要包设备的阻力调到5, 把这个属性设置为5
@property (nonatomic,   copy) NSString      *targetLevel;   // 目标阻力

// 是否通过指令停止 22.7.5 添加  内部在判断是否可以通过指令停止使用到这个值
@property (nonatomic, assign) BOOL           stopWithCmd;

@property (nonatomic, assign) FSDiscontrolType discontrolType; // 失控类型

@property (nonatomic, assign) int subSafeCode; // 安全锁脱落的子数据  def:0

/*
 启动设备:所有运动模块的设备调用此方法，启动设备
 只有设备处于待机状态才会返回YES, 如果这个方法返回NO,不会发送启动指令
 */
- (BOOL)start;

/*
 停止设备:所有运动模块的设备调用此方法，停止设备
 内部做了失控判断
 */
- (void)stop;

/*
 同时控制  速度与坡度参数
 速度：精度0.1
 坡度：精度1
 内部已对数据安全做了防护
 */
- (void)targetSpeed:(int)targetSpeed incline:(int)targetIncline;

/*
 同时控制  阻力与坡度参数
 阻力：精度1
 坡度：精度1
 内部已对数据安全做了防护
 */
- (void)setTargetLevl:(int)t_level incline:(int)t_incline;

/*
 发送指令  SDK 测试方法， 发送指令不推荐使用此方法
 */
- (void)sendData:(NSData *)data;

// 数据重置， 设备连接成功，开始运动前先对模块上报的数据做初始化处理，避免保留上传遗留的数据
- (void)dataReset;

// 心跳包的定时器  内部根据设备类型不同，添加不同指令，跑步机：状态指令，车表：状态指令+运动数据指令
- (void)updateState:(NSTimer *__nullable)sender;

// 更新设备参数, 如果设备参数没有获取成功，会重新获取设备参数
- (void)updateDeviceParams; // 更新数据参数

// 重启模块,
- (void)fsRestartBleModule;

// 跳绳协议--------------
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

// 21.12.16 力量器械，设备还未完成测试，有待优化
- (void)cleanAll;
- (void)cleanCals;
- (void)cleanCnts;
- (void)cleanTime;

- (int)paramRangeOfMax:(int)maxValue min:(int)minValue compare:(int)value;

- (int)signedParam:(int)value;





@end


NS_ASSUME_NONNULL_END
