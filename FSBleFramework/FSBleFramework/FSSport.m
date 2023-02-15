
#import "FSSport.h"
#import "FSBleDeice.h"
#import "FSDevice.h"
#import "FSManager.h"

FSSport            *fs_sport;
static FSSport     *currentSport;

@interface FSSport () <FSCentralDelegate>

// 初始化管理器
@property (nonatomic, strong) BleManager *fsManager;

@end

@implementation FSSport

+ (instancetype)currentWithHostURL:(NSString *)url {
    if (!currentSport) {
        /*
         22.11.5 重构车表连接逻辑
         22.11.14 车表阻力不能控制
         22.11.21 跑步机安全锁脱落的状态还是为2，因为在新状态的赋值的，把6的状态过滤掉了
         */
//        FSLog(@"22.11.5 重构车表连接逻辑");
//        FSLog(@"22.11.14 车表阻力不能控制");
//        FSLog(@"22.11.21 修改跑步机安全锁脱落的状态还是为2");
        currentSport = [[FSSport alloc] init];
        // MARK: 创建运动的时候，添加监听通知，这里可以做数据处理，运动记录等等
        [[NSNotificationCenter defaultCenter] addObserver:currentSport selector:@selector(updateFitshowData:) name:kUpdateFitshoData object:nil];
        fs_sport = currentSport;
        fs_sport.hostUrl = url;
        currentSport.fsManager = [FSManager managerWithDelegate:currentSport];
    }
    return currentSport;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateFitshoData object:nil];
}

#pragma mark 监听蓝牙上报数据
- (void)manager:(BleManager * _Nonnull)manager didUpdateState:(FSCentralState)state {
}


- (void)updateFitshowData:(NSNotification *)sender {
    // FIXME: 可以做一些数据统计之类的东西
}




@end
