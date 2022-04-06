//
//  NSDate+Extension.h
//  FSExpand
//
//  Created by zt on 2021/6/24.
//

#import <Foundation/Foundation.h>

// 一周的时间戳 60*60*24*7
static NSInteger weekSeconds = 604800;

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Extension)

/// 返回时间组件  年  月  日  时  分 秒
- (NSDateComponents *)toDateComponents;

/// 从时间戳 获取时间组件
+ (NSDateComponents *)fs_withTimeIntervalSince1970:(NSInteger)timeInterval;

/// 从时间格式  转获取时间组件
/// @param dateFmt 格式 @"2021-03-10 10:10:10"
+ (NSDateComponents *)fsDateWith:(NSString *)dateFmt;

/// 从时间组件  返回 yyyy-mm-dd hh:mm:ss
+ (NSString *)ymdhms:(NSDateComponents *)cmp;

/// 从时间组件返回  NSDate
+ (NSDate *)fsDateFromDateComponents:(NSDateComponents *)cmp;

/// 判断2个时间组件 是否在同一周
+ (BOOL)isSameWeek:(NSDateComponents *)cmp1
            todate:(NSDateComponents *)cmp2;

/// 对比2个时间组件相隔多少天
+ (NSInteger)FSDaysApart:(NSDateComponents *)cmp1
           toDate:(NSDateComponents *)cmp2;

/// 对比2个时间组件相隔多少周
+ (NSInteger)fsWeeksFormApartCmps:(NSDateComponents *)startCmps
                           toCmps:(NSDateComponents *)nowCmps;

/// 获取上周的时间
+ (NSInteger)fsLastWeek:(NSInteger)timeInterval;
/// 获取下周的时间
+ (NSInteger)fsNextWeek:(NSInteger)timeInterval;
/// 获取上月的时间
+ (NSInteger)fsLastMonth:(NSInteger)timeInterval;
/// 获取下月的时间
+ (NSInteger)fsNextMonth:(NSInteger)timeInterval;
/// 获取上年的时间
+ (NSInteger)fsLastYear:(NSInteger)timeInterval;
/// 获取下一年的时间
+ (NSInteger)fsNextYear:(NSInteger)timeInterval;

/// 通过传入的时间戳  获取统计的时间类型  20210308
/// @param timeInterval 时间戳
+ (NSString *)fsSaticTimeType:(NSInteger)timeInterval;

/// 获取一周的日期
+ (NSArray *)date_of_week;

@end

NS_ASSUME_NONNULL_END
