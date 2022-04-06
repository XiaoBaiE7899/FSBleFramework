
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kIsEmptyStr(str)  ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 || [str isEqualToString:@"<null>"] || [str isEqualToString:@"(null)"] ? YES : NO )
#define SF(format, ...) ([NSString stringWithFormat:(format), ##__VA_ARGS__])

typedef NS_ENUM(NSInteger, FSLengthUint) {
    /* 公里 */
    FSLengthUintKm = 0,
    /* 英里 */
    FSLengthUintMiles,
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FSExtension)

/// 本地化
- (NSString *)localizable;

/// yyyy-mm-dd hh:mm:ss  转时间戳
- (NSInteger (^)(void))toTimeIntervalSince1970;


/// yyyy-mm-dd hh:mm:ss 转 NSDate
- (NSDate *(^)(void))toDate;

#pragma mark 通用

/// 判断是不是交易金额，不能为负数，如果可以允许负数，要更改正则
- (BOOL (^)(void))isTransactionAmount;

/// 是不是商务交易金额，小数点保留2位
- (BOOL (^)(void))isbBusinessAmount;

/// 字符串转字典
- (NSDictionary *)toDictionary;

/// 字符串转数组
- (NSArray *)toArray;


#pragma mark 计算相关
/// 加
- (NSString *(^)(NSString *))add;

/// 减
- (NSString *(^)(NSString *))sub;

/// 乘
- (NSString *(^)(NSString *))mul;

/// 除
- (NSString *(^)(NSString *))div;

/// 保留 多少位小数
- (NSString *(^)(NSInteger))decimalPlace;

/// 等于
- (BOOL (^)(NSString *))dengyu;

/// 大于
- (BOOL (^)(NSString *))dayu;

/// 大于等于
- (BOOL (^)(NSString *))dayudengyu;

/// 小于
- (BOOL (^)(NSString *))xiaoyu;

/// 小于等于
- (BOOL (^)(NSString *))xiaoyudengyu;

/// 验证是否是手机号  不能为空，必须是11位， 必须是1开头的
- (BOOL (^)(void))isMobile;

/// 验证是不是邮箱
- (BOOL (^)(void))isEmail;

/// 时间格式 6'88
- (NSString *(^)(void))fs_paceTimeFormat;

/// 运动秀的连接添加一个lang参数  FIXME: 这个方法没有使用到
- (NSString *(^)(NSString *))fs_addLangTourl;

/// 秒转分钟 保留2位小数
- (NSString *(^)(void))secondTominutes;

/// 秒转小时 保留2位小数
- (NSString *(^)(void))secondToHour;

/// FIXME:#484 公英制转换  这个方法要弃用 独立成2个方法 米 转 公里或者英里保留2位小数 备注:默认返回公里，如果用户有登录并且设置了英制才会返回英里
- (NSString *(^)(FSLengthUint))mToKmOrMile;

/// 米 转 公里 保留2位小数
- (NSString *(^)(void))mToKm;

/// 米 转 英里 保留2位小数
- (NSString *(^)(void))mToMile;

/// 公里或英里  转为米， 底层为定距离模式的会使用到
- (NSString *(^)(FSLengthUint))kmOrMileToMeter;

/// 显示距离
- (NSString *(^)(FSLengthUint))fsDisplayDistance;

/// 公里转米  不保留小数
- (NSString *(^)(void))kmToMeter;

/// 英里转米  不保留小数
- (NSString *(^)(void))mileToMeter;

/// 秒转 时间格式  0:00:00
- (NSString *(^)(void))seccondToTimeFormate;

/// 时间格式 0:00:00  转 分钟  结果保留2位小数  因为这个数会被当成数据，非法数据返回1
- (NSString *(^)(void))fs_TimeFormateToMinutes;

/// 分转 时间格式  00'00''      第一种样式
- (NSString *(^)(void))setSecondTimeStyleFormate;
/// 分钟转为 分:秒 09:38       第二种样式
- (NSString * _Nonnull (^)(void))setSecondTimeStyle2Formate;
/// 分钟转为 小时:分 09:38   第三种样式
- (NSString * _Nonnull (^)(void))setSecondTimeStyle3Formate;

/// 获取最大值和最小值之间的合法数组，如果小于等于最小 返回最小值， 大于等于最大最大值，返回最大值，否则返回自己
- (NSString * (^)(NSString *, NSString *))fs_minAndMax;

/// base64字符串转图片
- (UIImage *)base64ToImage;

/// 运动记录转为小时
- (NSString *(^)(void))recordTimesToSecond;

/// 运动时间转换为 步行约XX小时XX分
- (NSString *(^)(NSString *))fomateSportTime;

/// 公里转化为英里 后台返回的数据都是公制单位，[单位是米]  block的参数为保留多少为小数
- (NSString *(^)(int, FSLengthUint))fsKmToMile;

/// 英里转换为公里
- (NSString *(^)(int, FSLengthUint))fsMileToKm;

/// 磅转千克 内部做过滤，公制单位直接返回，如果是英制单位转换
- (NSString *(^)(int, FSLengthUint))fsPoundsToKg;

/// 英尺转厘米 内部做过滤，公制单位直接返回，如果是英制单位转换
- (NSString *(^)(int, FSLengthUint))fsFeetToCm;

/// 重下载URL获取 文件类型
- (NSString *(^)(void))fsDownLoadFileType;

/// 16进制的字符串转整形
- (long (^)(void))hexStringToInt;

/// 获取沙盒主目录路径
+ (NSString *)fsHomepath;

/// 获取Caches目录路径
+ (NSString *)fsCachesPath;

/// 获取tmp目录路径
+ (NSString *)fsTmpPath;

/// 获取Documents目录路径
+ (NSString *)fsDocumentsPath;

/// 获取设备的可用空间 单位M
+ (NSString *)divceFreeSpace;

/// 语言播报保存的文件夹
+ (NSString *)fsAudioPath;

/// 动作库音频，  20220117 添加下载
+ (NSString *)fsActionAudioPath;

/// 指定音频的路径
+ (NSString *)fsGuideAudioPath;

/// 动作库保存的文件夹
+ (NSString *)fsActionsPath;

/// 空间是否足够
+ (BOOL)isEnoughSpace;
/// 隐私协议
+ (NSString *)fs_privacy;

/// 使用协议
+ (NSString *)fs_useagre;

/// 判断音频文件是否存在  根据路径去查询
- (BOOL)audioFileExist;

/// 缓存文件是否存在，如果缓存文件存在，返回文件路径，或者返回:@""
- (NSString *)cashesFileExist;

@end

NS_ASSUME_NONNULL_END
