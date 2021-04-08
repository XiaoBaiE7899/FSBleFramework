
// 蓝牙库的自定义宏

#ifndef FSLibHelp_h
#define FSLibHelp_h

#define kIsEmptyStr(str)  ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 || [str isEqualToString:@"<null>"] || [str isEqualToString:@"(null)"] ? YES : NO )

#define UUID(x)        [CBUUID UUIDWithString:(x)]
#define HIBYTE(w)           (Byte)((w) >> 8)
#define LOBYTE(w)           (Byte)((w) & 0x00ff)

#define HIWORD(l)           (uint)((l) >> 16)
#define LOWORD(l)           (uint)((l) & 0xffff)

#define MAKELONG(a, b)      (uint)((uint)(a) | ((uint)(b) << 16))
#define MAKEWORD(a, b)      (uint)((uint)(a) | ((uint)(b) << 8))
#define MAKEDWORD(a,b,c,d)  (uint)(MAKELONG(MAKEWORD(a, b), MAKEWORD(c, d)))

#define    WORDBYTE(d)            LOBYTE(d), HIBYTE(d)
#define    DWORDBYTE(d)        LOBYTE(LOWORD(d)), HIBYTE(LOWORD(d)), LOBYTE(HIWORD(d)), HIBYTE(HIWORD(d))

#define FSSF(format, ...) ([NSString stringWithFormat:(format), ##__VA_ARGS__])

#define weakObj(value) __weak typeof(value) weak##value = value;
#define SPBLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); }
#if (DEBUG == 1)
#define FSLog(string, ...) NSLog(@"🔨 %@ <%d>🔥🔥 %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(string), ##__VA_ARGS__])
#else
#define FSLog(string, ...)
#endif

/// 扫描外设UUID
static NSString * _Nonnull const SERVICES_UUID        = @"FFF0";

/// 通知通道
static NSString * _Nonnull const CHAR_NOTIFY_UUID     = @"FFF1";

/// 可以写通道
static NSString * _Nonnull const CHAR_WRITE_UUID      = @"FFF2";

/// 厂家
static NSString * _Nonnull const CHAR_READ_MFRS       = @"2A29";

/// 型号
static NSString * _Nonnull const CHAR_READ_PN         = @"2A24";

/// 硬件版本
static NSString * _Nonnull const CHAR_READ_HV         = @"2A27";

/// 软件版本
static NSString * _Nonnull const CHAR_READ_SV         = @"2A28";

#pragma mark 以下是通知的名称
/// 运动秀设备收到数据的通知
static NSString * _Nonnull const kUpdateFitshoData = @"kUpdateFitshoData";

/// 运动秀设备完全停止了
static NSString * _Nonnull const kFitshowHasStoped = @"kFitshowHasStoped";


#endif /* FSLibHelp_h */
