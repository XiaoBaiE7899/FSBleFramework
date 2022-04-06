/*
 语音播报
 */
#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(int, XBVoiceType) {
    XBVoiceTypeNormal,
    XBVoiceTypeSportSecond,    // 倒计时声音
    XBVoiceTypeSportStart,     // 开始运动
    XBVoiceTypeSportPause,     // 运动暂停
    XBVoiceTypeSportResume,    // 恢复运动
    XBVoiceTypeSportStop,      // 停止运动
};

// 设置语言种类可以参考  https://www.jianshu.com/p/5cbe466b128a

NS_ASSUME_NONNULL_BEGIN

@protocol XBVoiceDelegate <NSObject>
@optional

- (BOOL)shouldSpeechUtterance:(AVSpeechUtterance *)utterance;

/// 文本播报已经完成
/// @param speechString 已经完成的文本
- (void)didFinishSpeech:(NSString *)speechString;

@end

@interface XBVoice : NSObject <AVSpeechSynthesizerDelegate>

+ (instancetype)voice;
+ (void)background;              // 处理后台（APP初始化时，执行一次，以支持后台播报）

+ (void)sound:(XBVoiceType)type;  // 播放音效
+ (void)voice:(NSString *)text;   // 播报文本



//+ (void)stop;

@property (nonatomic) id <XBVoiceDelegate>        delegate;

@property (nonatomic, readonly) AVSpeechSynthesizer     *player;
@property (nonatomic,     copy) NSString                *voiceText;        //当前播报的文本，设置将开始播报
@property (nonatomic, copy) NSString *voiceLanguage;

//@property (nonatomic, assign) BOOL speaking;

- (void)speakUtterance:(AVSpeechUtterance *)utterance;        //开始播报
/// 停止播报
- (void)stopSpeak;

#pragma mark -- 运动秀合成语言播报所增加的内容

/// 文本队列
//@property (nonatomic, strong) NSMutableArray *textQueue;




@end

NS_ASSUME_NONNULL_END
