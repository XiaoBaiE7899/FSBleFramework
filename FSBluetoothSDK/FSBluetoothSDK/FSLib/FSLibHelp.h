
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
#if (DEBUG == 1)
#define FSLog(string, ...) NSLog(@"🔨 %@ <%d>🔥🔥 %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(string), ##__VA_ARGS__])
#else
#define PLog(string, ...)
#endif


#endif /* FSLibHelp_h */
