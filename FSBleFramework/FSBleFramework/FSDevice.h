
#import "FSBleDeice.h"


@class FSBaseDevice;
@class FSTreadmill,FSSection,FSRope,FSSlimming,FSPower,FSSlimmingMode;


NS_ASSUME_NONNULL_BEGIN

@interface FSTreadmill : FSBaseDevice

@end


@interface FSSection : FSBaseDevice

@end


@interface FSRope : FSBaseDevice

// 绊绳次数
@property (nonatomic, copy) NSString *interruptCnts;
// 连跳数
@property (nonatomic, copy) NSString *continueCnts;
// 连跳时间
@property (nonatomic, copy) NSString *continueTimes;
// 最大连跳数
@property (nonatomic, copy) NSString *maxContinueCnts;
// 最大连跳时间
@property (nonatomic, copy) NSString *maxContinueTimes;
// 总数量
@property (nonatomic, copy) NSString *totalCnts;
// 平均频率
@property (nonatomic, copy) NSString *avg_cntFreq;
// 电量
@property (nonatomic, copy) NSString *battery;

@end

@interface FSSlimming : FSBaseDevice

@property (nonatomic, assign) UInt8 identifyCode; // G 0x90

/// 模式设定与显示  参照枚举值  当前模式
@property (nonatomic, assign) int currentMode;

/// 目标模式  这个会走setter方法
@property (nonatomic, assign) long targetMode;


/// 待机 0：不待机  1：待机 连接成功，发送不待机指令
@property (nonatomic, assign) BOOL isStandby;

// MARK: 以下3个属性没有暂时没使用
/// 音量控制
@property (nonatomic, assign) SlimmingVolumeControl volumeControl;

/// 音乐播放/停止  0：停止播放音乐  1：播放音乐
@property (nonatomic, assign) BOOL isMusizing;

/// 切换音乐
@property (nonatomic, assign) SlimmingSwitchMusic switchMusic;

/// 切换模式，直接切换模式，要先发送停止，设备停止了才能切换模式, 刚刚连接成功的时候设置为NO, 到了运动界面，确定切换模式再设置为YES
@property (nonatomic, assign) BOOL switchMode;

/// 对象初始化时候同时对这个属性初始化
@property (nonatomic, strong) FSSlimmingMode *mode;

/// 210812 增加统计时间
@property (nonatomic, readonly) int timeIncrement;

/// 结束时消耗的总卡路里 上传记录时使用
@property (nonatomic, readonly) NSString *totalCalory;

/// 用于判断结束运动时，避免计算卡路里时多次进来重复累加值  开始指令和自由模式的切换模式地方设置YES
@property (nonatomic,assign) BOOL isFirstStop;


@end

@interface FSPower : FSBaseDevice

@end

NS_ASSUME_NONNULL_END
