
#import "FSSport.h"
#import "FSBleDeice.h"
#import "FSDevice.h"
#import "BleManager.h"

FSSport            *fs_sport;
static FSSport     *currentSport;

@implementation FSSport

+ (instancetype)currentWithHostURL:(NSString *)url {
    if (!currentSport) {
//        FSLog(@"全局运动类初始化");
        currentSport = [[FSSport alloc] init];
        // MARK: 创建运动的时候，添加监听通知，这里可以做数据处理，运动记录等等
        [[NSNotificationCenter defaultCenter] addObserver:currentSport selector:@selector(updateFitshowData:) name:kUpdateFitshoData object:nil];
        fs_sport = currentSport;
        fs_sport.hostUrl = url;
    }
    return currentSport;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateFitshoData object:nil];
}

#pragma mark 监听蓝牙上报数据
- (void)updateFitshowData:(NSNotification *)sender {
    FSLog(@"全局运动类增加  监听蓝牙数据");
    // FIXME: 可以做一些数据统计之类的东西
}




@end
