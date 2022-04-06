
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Extension)

+ (void)setLanguage:(NSString *)language;

+ (NSBundle *)bundLelottieJsonPath:(NSString *)name;

// FIXME:  210621 这个地方需要修改，增加传入的参数  这个方法没有调用，先注释掉
/// 动画文件名
/// @param sportType 运动类型
/// @param v 跑步机需要传入速度，其他类型可以不传
//+ (NSString *)fsLottieAnimationName:(int)sportType speed:(int)v;

@end

NS_ASSUME_NONNULL_END
