
#import "FSDevice.h"
#import "BleModule.h"
#import "FSManager.h"
#import "FSGenerateCmdData.h"
#import "FSSlimmingMode.h"
#import "NSString+fsExtent.h"

static int afterDelayTime = 3;


@interface FSTreadmill ()

// 原速度  失控判断
@property (nonatomic, assign) int            originalSpeed;
@property (nonatomic, strong) NSMutableArray *speedArr;

// 原坡度  失控判断
@property (nonatomic, assign) int            originalIncline;
@property (nonatomic, strong) NSMutableArray *inclineArr;


@end

@implementation FSTreadmill

@synthesize currentStatus   = _currentStatus;
@synthesize isRunning       = _isRunning;
@synthesize isPausing       = _isPausing;
@synthesize hasStoped       = _hasStoped;
@synthesize isStarting      = _isStarting;
@synthesize isWillStart     = _isWillStart;
@synthesize getParamSuccess = _getParamSuccess;
@synthesize targetSpeed     = _targetSpeed;
@synthesize targetIncline   = _targetIncline;
@synthesize targetLevel     = _targetLevel;


- (void)setCurrentStatus:(FSDeviceState)currentStatus {
    switch (currentStatus) {
        case -1: {
            _currentStatus = FSDeviceStateDefault;
        }
            break;
        case 0: {
            _currentStatus  = FSDeviceStateNormal;
        }
            break;
        case 1: {
            _currentStatus = FSDeviceStateTreadmillEnd;
        }
            break;
        case 2: {
            _currentStatus = FSDeviceStateStarting;
        }
            break;
        case 3: {
            /*
             正常的暂停 状态为 TreadmillStausPauseds || TreadmillStausPaused
             20.09.14 迈动工厂测试 暂停的时候设备还在运行中，但是速度为0
             9.29 迈动展厅测试，通过指令让设备从设备暂停状态恢复运行的结果
             1. TA860K 可以恢复，这种情况不需要处理，直接恢复就好
             2. 体博会参展的设备，设备状态一直都是3，点击app上的恢复，也是3，速度为0.
             3. 跑客（白色跑步机），从app恢复的状态一直为10.
             */
            if (self.exerciseTime.intValue > 3 &&
                self.speed.intValue == 0) {
                _currentStatus = FSDeviceStatePaused;
            } else {
                _currentStatus = FSDeviceStateRunning;
                
            }
        }
            break;
        case 4: {
            _currentStatus = FSDeviceStateTreadmillStopping;
        }
            break;
        case 5: {
            _currentStatus = FSDeviceStateError;
        }
            break;
        case 6: {
            _currentStatus = FSDeviceStateTreadmillDisable;
        }
            break;
        case 7: {
            _currentStatus = FSDeviceStateTreadmillDisRun;
        }
            break;
        case 9: {
            _currentStatus = FSDeviceStateTreadmillReady;
        }
            break;
        case 10:
        case 16: { // 16  防呆不防傻
            _currentStatus = FSDeviceStatePaused;
        }
        default:
            break;
    }
    /* MARK：这个逻辑需要修改
     1 蓝牙状态不是工作中
     2 如果是意外断开重连的，不需要回调
     3 已经获取设备参数
     4 代理有值
     5 代理相应对应的方法
     */
    /* !!!: 210923  重构蓝牙正在工作中
     原因：康乐佳的设备，test03  模块T4, 如果没有获取设备控制参数，蓝牙可以发送启动指令以后，设备进入倒计时，倒计时到1秒数的时候，设备再也没有上报数据了
     1 跑步机：获取设备控制参数成功&&当前状态不为初始化状态
     2 车表：  状态指令有返回再执行回调
     3 其他设备： 直接回调就行了
     */
    if (self.connectState != FSConnectStateWorking &&
        !self.accidentalReconnect &&
        self.getParamSuccess &&
        self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
        self.connectState = FSConnectStateWorking;
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
    }
}

- (BOOL)hasStoped {
    // 停止中-----正常状态
    if (self.oldStatus == FSDeviceStateTreadmillStopping &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }
    // MARK: 20.9.14 MD参展体博会设备 不会进入4状态，状态3&&速度0即为暂停，再发停止，就停止
    if (self.oldStatus == FSDeviceStateRunning &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }

    // MARK: 21.02.19 康乐佳 发送停止指令以后  3-1-0
    if (self.oldStatus == FSDeviceStateTreadmillEnd &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }

    // 暂停到待机
    if (self.oldStatus == FSDeviceStatePaused &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }

    return NO;
}

- (BOOL)isPausing {
    /*
     正常的暂停 状态为 TreadmillStausPauseds || TreadmillStausPaused
     20.09.14 迈动工厂测试 暂停的时候设备还在运行中，但是速度为0

     9.29 迈动展厅测试，通过指令让设备从设备暂停状态恢复运行的结果
     1. TA860K 可以恢复，这种情况不需要处理，直接恢复就好
     2. 体博会参展的设备，设备状态一直都是3，点击app上的恢复，也是3，速度为0.
     3. 跑客（白色跑步机），从app恢复的状态一直为10.
     !!!: 210830 周一早上与AB讨论决定，如果出现 状态为3，速度为0，时间大于0 才是暂停，否则为运行中
     */
    BOOL rst = NO;
    
    if (self.currentStatus == FSDeviceStatePaused) {
        rst = YES;
    }

    if (self.currentStatus == FSDeviceStateRunning &&
        self.speed.intValue == 0 &&
        self.exerciseTime.intValue > 3) {
//        return YES;
        rst = YES;
    }

    return rst;
}

- (BOOL)isRunning {
    // !!!: 210828 乔阳工厂  跑步机 启动， 状态为3， 速度为0， 根据之前的判断，这个状态是暂停，如果乔阳的数据都是这样，应该单独处理
    if (self.currentStatus == FSDeviceStateRunning /*&&
        self.speed.integerValue != 0*/) {
            return YES;
    }
    return NO;

}

- (BOOL)isStarting {
    return self.currentStatus == FSDeviceStateStarting;
}

- (BOOL)isWillStart {
    if (self.oldStatus != FSDeviceStateStarting &&
        self.currentStatus == FSDeviceStateStarting) {
        return YES;
    }
    return NO;
}

- (BOOL)getParamSuccess {
    if (self.speedObtainSuccess && self.inclineObtainSuccess) {
        return YES;
    }
    return NO;
}

- (void)setTargetLevel:(NSString *)targetLevel {
    _targetLevel = targetLevel;
}

- (void)setTargetSpeed:(NSString *)targetSpeed {
//    FSLog(@"目标速度");
    _targetSpeed = targetSpeed;
    // 当前坡度
    int cur_inl = self.incline.intValue;
    [self targetSpeed:targetSpeed.intValue incline:cur_inl];
}

- (void)setTargetIncline:(NSString *)targetIncline {
//    FSLog(@"目标坡度");
    // 当前速度
    int cur_spd = self.speed.intValue;
    [self targetSpeed:cur_spd incline:targetIncline.intValue];
}

- (NSMutableArray *)speedArr {
    if (!_speedArr) {
        _speedArr = NSMutableArray.array;
    }
    return _speedArr;
}

- (NSMutableArray *)inclineArr {
    if (!_inclineArr) {
        _inclineArr = NSMutableArray.array;
    }
    return _inclineArr;
}

- (BOOL)onUpdateData:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(treadmillReadyTimeOut) object:nil];
    Byte *bytes     = (Byte *)[cmd.data bytes];
    Byte mainCmd    = bytes[1];
    Byte subcmd     = bytes[2];
    switch (mainCmd) {
        case 0x50: { /*FSMainCmdModel*/
            if (subcmd == 0) { /*FSSubParamCmdTreadmillModel*/
                unsigned int producter   = MAKEWORD(bytes[3], bytes[4]);
                unsigned int models      = MAKEWORD(bytes[5], bytes[6]);
                self.module.manufacturer = FSFM(@"%d", producter);
                self.module.model        = FSFM(@"%d", models);
            } else if (subcmd == 2) { /* FSSubParamCmd_Speed_Param */
                // 02 速度信息
//                FSLog(@"22.3.29跑步机 上报  速度 信息");
                unsigned int maxSpeed         = bytes[3];
                unsigned int minSpeed         = bytes[4];
                unsigned int control          = maxSpeed - minSpeed;
                self.deviceParam.maxSpeed     = FSFM(@"%df", maxSpeed);
                self.deviceParam.minSpeed     = FSFM(@"%df", minSpeed);
                self.deviceParam.supportSpeed = control > 0 ? YES : NO;
                self.speedObtainSuccess = YES;
            } else if (subcmd == 3) { /* FSSubParamCmd_Incline_Total */
//                FSLog(@"22.3.29跑步机 上报  坡度 信息");
                [self inclineConfigInfo:cmd];
            } else if (subcmd == 4) { /* FSSubParamCmd_Total_Date */
//                unsigned int total_Distance = FSBleDataProcess.readUInt(databytes + 3);
//                [device setValue:SF(@"%d", total_Distance) forKey:paramTotalDistance];
            }
        }
            break;
        case 0x51: { /* FSMainCmdTreadmillStatus */
//            FSLog(@"跑步机 上报  心跳 信息");
            // 这个独立一个方法处理
            [self updateDeviceStatusAndData:cmd];
        }
            break;
//        case 0x52:{
//            [self updateDeviceStatusAndData:cmd];
//        }
//            break;
            // FSMainCmdTreadmillControl 设备控制
        case 0x53: {}
            break;

        default:
            break;
    }

    // 速度变化处理
    if (self.deviceParam.supportSpeed) {
        if (self.originalSpeed != self.speed.intValue && ![self.speedArr containsObject:self.speed]) {
            [self.speedArr addObject:self.speed];
        }
    }

    // 坡度变化处理
    if (self.deviceParam.supportIncline) {
        if (self.originalIncline != self.incline.intValue && ![self.inclineArr containsObject:self.incline]) {
            [self.inclineArr addObject:self.incline];
        }
    }

    // 数据通过通知发送出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFitshoData object:self];

    return YES;
}

// 坡度配置信息 解析
- (void)inclineConfigInfo:(BleCommand *)cmd {
    Byte *bytes = (Byte *)[cmd.data bytes];
    // 坡度信息  包含配置信息，逻辑独立成单独的方法
    int maxIncline = bytes[3];
    int minIncline = bytes[4];
    /*
     !!!: 210427 坡度是有符号的整数，第一位是符号位 因此最大的数据就是127
     */
    if (maxIncline > 127) maxIncline = (256 - maxIncline) * -1;
    if (minIncline > 127) minIncline = (256 - minIncline) * -1;

    self.inclineObtainSuccess = YES;

    /*
      这个指令的  设备的配置信息可以拿不到 可以根据返回的数据长度去判断信息是否完整。
     不响应返回    返回5个字节：  02 53 03 53 03
     没有配置信息  返回7个字节：  02 53 03 16  00 ** 03
     有配置信息    返回8个字节：  02 53 03 16 00 90 ** 03
     */
    switch (cmd.data.length) {
        case 5: { // 坡度数据没下发 最大坡度 最小坡度 是否英制单位，暂停，坡度是否可以控制
            self.deviceParam.maxIncline     = @"0";
            self.deviceParam.minIncline     = @"0";
            self.deviceParam.imperial       = NO;
            self.deviceParam.supportPause   = NO;
            self.deviceParam.supportIncline = NO;
        }
            break;
        case 7: { // 没有发配信息 英制单位、支持暂停设置为0， 最大、最小坡度、坡度是否可以控制可以赋值
            self.deviceParam.maxIncline     = FSFM(@"%d", maxIncline);
            self.deviceParam.minIncline     = FSFM(@"%d", minIncline);
            self.deviceParam.imperial       = NO;
            self.deviceParam.supportPause   = NO;
            unsigned int control = maxIncline - minIncline;
            self.deviceParam.supportIncline = control > 0 ? YES : NO;
        }
            break;
        case 8: { // 有发配置信息，所有信息都要配置
            // !!!: 距离单位 && 是否支持暂停
            unsigned int imperial = bytes[5] & 0x01;
            unsigned int pause    = bytes[5] & 0x02;
            // 配置信息 转为2进制  输出为字符串
            unsigned int control = maxIncline - minIncline;
            self.deviceParam.maxIncline     = FSFM(@"%d", maxIncline);
            self.deviceParam.minIncline     = FSFM(@"%d", minIncline);
            self.deviceParam.imperial       = imperial;
            self.deviceParam.supportPause   = pause;
            self.deviceParam.supportIncline = control > 0 ? YES : NO;
        }
            break;

        default:
            break;
    }
}

// 蓝牙状态 数据解析
- (void)updateDeviceStatusAndData:(BleCommand *)cmd {
    
    
    Byte *bytes        = (Byte *)[cmd.data bytes];
    Byte subcmd        = bytes[2];
    self.oldStatus     = self.currentStatus;
    FSLog(@"模块%@  当前状态:%d  旧状态:%d", self.module.name,  self.currentStatus, self.oldStatus);
    
    // !!!: 22.4.1 回调蓝牙正常工作  写在setter方法中
    self.currentStatus = subcmd; // 测试状态  会不会进入setter方法
    // 如果设备处于暂停暂停，并且是通过指令停止的，在发一次停止指令
    if (self.currentStatus == FSDeviceStatePaused && self.stopWithCmd) {
        [self stop];
    }
//    FSLog(@"模块%@  当前状态:%d  旧状态:%d", self.module.name,  self.currentStatus, self.oldStatus);
    // 收到状态上报  回调蓝牙正常
    
    if (self.oldStatus != self.currentStatus &&
        /*self.currentStatus != FSDeviceStateDefault &&*/
        self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(deviceDidUpdateState:fromState:)]) {
        [self.deviceDelegate deviceDidUpdateState:self.currentStatus fromState:self.oldStatus];
    }
    /*
     设备完成一次运动，状态的变化过程
     1 不支持暂停 0-2-3-4-0
     2 支持暂停
       2.1 正常流程 0-2-3-4-10-0
       2.2 9月14日 迈动工厂测试（参加体博会） 0-2-3------0
           MARK: 设备支持暂停，但不会进入4、10两种状态 当状态为3&&速度为0，设备就进入暂停状态
     !!!: 通过app发送恢复指令，设备从暂停恢复到运行的状态变化过程
       1. 正常恢复 10月30日 迈动展厅测试 TA860K 10-1-3
       2. 不能通过app 蓝牙指令恢复：
          1 跑客白色跑步机&A10： 指令发送之后，蓝牙有返回，设备没恢复，返回状态为10
          2 迈动体博会设备：指令发送之后，蓝牙有返回，设备没恢复，状态为3&&速度为0
          MARK: 处理逻辑，满足条件1：设备为跑步机， 2：设备处于暂停状态， 发送恢复指令，延迟4秒判断设备是否还是处于暂停中，如果处于暂停中，弹框告诉用户通过设备的屋里键恢复设备运行。
    !!!: 测试版  A10 FS-711636的问题描述
         1 连接-启动-停止-停止的状态变化： 0-2-3-10-10-0
         2 连接-启动-控制速度-停止: 0-2-3-4-10-0
         3 连接-启动-控制坡度-停止: 0-2-3-10-10-0
         4 这个设备  一开始步数就是错了
         MARK: 10.30  测试暂停恢复功能，A10有时候回进入10状态，有的时候不会进入10的状态
         1 暂停状态返回10，发送恢复指令，返回的数据与跑客相同
         2 不暂停状态返回4，速度为0， 返回0， 这个现象跟不支持暂停的设备一致
     */
    if (self.hasStoped) {
        [self disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
    }
    switch (subcmd) {
            // FSDeviceStateNormal 待机状态 完全停止 返回这个状态
        case 0: {}
            break;
            // FSDeviceStateTreadmillEnd 减速已停止状态，还未返回待机
        case 1: {}
            break;
            // FSDeviceStateStarting 开始启动状态
        case 2: {
            unsigned int countDown = bytes[3];
            self.countdownSeconds  = FSFM(@"%d", countDown);
        }
            break;
            // FSDeviceStateRunning 运行中
        case 3: {
            /*
             MARK: 210610 判断设备通哪种方式启动的，如果是从设备上启动，app负责采集数据
             1 设备不是通过指令启动的
             2 设备从非暂停状态到运行中的状态，这个条件比较合理，
            */
            /*
             MARK: 3月10日  迈动工厂拿回表头跑步机  返回的数据与解析
             V:速度 P:坡度 T:时间 D:距离 C:热量 S:步数 H:心率 G:段数 R:检验
                      V  P  T     D     C     S     H  G  R
             02 51 03 14 00 AD 02 3A 00 41 00 53 00 00 00 C1 03
             表显:     2           0.05
             02 51 03 14 00 C2 03 3E 00 46 00 59 00 00 00 A6 03
             表显:     2           0.06
             */
            int _speed        = bytes[3];
            int _incline      = bytes[4];
            int _time         = MAKEWORD(bytes[5], bytes[6]);
            int _distance     = MAKEWORD(bytes[7], bytes[8]);
            int _calory       = MAKEWORD(bytes[9], bytes[10]);
            int _steps        = MAKEWORD(bytes[11], bytes[12]);
            int _heartrate    = bytes[13];
            int _paragraph    = bytes[14];

            self.exerciseTime = FSFM(@"%d", _time);
            self.distance     = FSFM(@"%d", _distance);
            self.speed        = FSFM(@"%d", _speed);
            // 卡路里需要除以10
//            self.calory       = FSFM(@"%d", _calory);
            NSString *cal     = FSFM(@"%d", _calory);
            self.calory       = cal.fsDiv(@"10");
            self.steps        = FSFM(@"%d", _steps);
            self.heartRate    = FSFM(@"%d", _heartrate);
            self.paragraph    = FSFM(@"%d", _paragraph);
//            self.incline = FSFM(@"%d", _incline);
            // 坡度是有符号的  // MARK: 210430  坡度有-1 MD
            self.incline      = FSFM(@"%d", _incline > 127 ? (256 - _incline) * -1 : _incline);
            FSLog(@"跑步机上报数据 03: 时间%@  距离%@  速度%@  卡路里%@  步数%@ 心率%@ 坡度%@", self.exerciseTime, self.distance, self.speed, self.calory, self.steps, self.heartRate, self.incline);
        }
            break;
            // FSDeviceStateTreadmillStopping 减速度停止中
        case 4: { // 黑色跑步机 结束的有问题，距离会为0，统计的要增加判断
            int _speed        = bytes[3];
            int _incline      = bytes[4];
            int _time         = MAKEWORD(bytes[5], bytes[6]);
            int _distance     = MAKEWORD(bytes[7], bytes[8]);
            int _calory       = MAKEWORD(bytes[9], bytes[10]);
            int _steps        = MAKEWORD(bytes[11], bytes[12]);
            int _heartrate    = bytes[13];
            int _paragraph    = bytes[14];

            self.exerciseTime = FSFM(@"%d", _time);
            self.distance     = FSFM(@"%d", _distance);
            self.speed        = FSFM(@"%d", _speed);
            NSString *cal     = FSFM(@"%d", _calory);
            self.calory       = cal.fsDiv(@"10");
//            self.calory       = FSFM(@"%d", _calory);
            self.steps        = FSFM(@"%d", _steps);
            self.heartRate    = FSFM(@"%d", _heartrate);
            self.paragraph    = FSFM(@"%d", _paragraph);
            // 坡度是有符号的  // MARK: 210430  坡度有-1 MD
            self.incline      = FSFM(@"%d", _incline > 127 ? (256 - _incline) * -1 : _incline);
            FSLog(@"跑步机上报数据 04: 时间%@  距离%@  速度%@  卡路里%@  步数%@ 心率%@ 坡度%@", self.exerciseTime, self.distance, self.speed, self.calory, self.steps, self.heartRate, self.incline);
        }
            break;
            // FSDeviceStateError 设备故障
        case 5: {
            unsigned int code = bytes[3];
            self.errorCode    = FSFM(@"%d", code);
            [self disconnect];
            // 代理回调
            if (self.deviceDelegate &&
                [self.deviceDelegate respondsToSelector:@selector(deviceError:)]) {
                [self.deviceDelegate deviceError:self];
            }

        }
            break;
            // FSDeviceStateTreadmillDisable 设备禁用
        case 6: {
            // 代理回调
            if (self.deviceDelegate &&
                [self.deviceDelegate respondsToSelector:@selector(deviceError:)]) {
                [self.deviceDelegate deviceError:self];
            }
            [self disconnect];
        }
            break;
            // FSDeviceStateTreadmillReady 设备就绪
        case 9:
            // 暂停
        case 10:
        case 16: {}
        default:
            break;
    }
}

// 控制指令解析
- (void)treadmillControlCmdReportParsing:(BleCommand *)cmd  {
    Byte *bytes        = (Byte *)[cmd.data bytes];
    Byte subcmd        = bytes[2];
    switch (subcmd) {
            // FSSubControlCmdTreadmillUserData 写入用户数据
        case 0: {
            // 用户id  写入的都是:0
            unsigned int w = bytes[7];
            unsigned int h = bytes[8];
            self.weight    = FSFM(@"%d", w);
            self.height    = FSFM(@"%d", h);
            self.uid       = @"0";
            self.writeUserDataSuccess = YES;
        }
            break;
            // FSSubControlCmdReady 准备
        case 1: {
            // 准备开始（1.1）（START 前写入运动数据）
            unsigned int startsecond = bytes[3];
            // MARK: 这里只会进来一次
            self.countdownSeconds    = FSFM(@"%d", startsecond);
        }
            break;
        default:
            break;
    }

}

#pragma mark 重写父类的方法
- (void)dataReset {
    [super dataReset];
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.originalIncline = 0;
    [self.inclineArr removeAllObjects];
    self.originalSpeed = 0;
    [self.speedArr removeAllObjects];
    // MARK:210701 开始肯定不是指令开始&停止
    self.stopWithCmd = NO;
//    fs_sport.codeCtrlModel.isStartWithCmd = NO;
    [self clearSend];
}

- (void)onConnected {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 数据重置
    [self dataReset];
    /*
     MARK: 20211102 厂家三维的设备，连接成功的第一条指令必须是写入用户数据，否则设备不能控制,
     */
    // 写入用户数据 !!!: 中阳系统运动ID只能传0  特别注意
    [self sendData:FSGenerateCmdData.treadmillWriteUserData(0, 60, 170, 25, 0)];
    // 只发一次，不管是不是成功
    self.writeUserDataSuccess = YES;
    //  MARK: 210429 发送心跳包的时候，会判断是否已经获取设备参数，没有获取设备参数就回去获取设备参数，因此连接上以后就不用再获取设备参数了
    [self updateState:nil];
    // 判断是不是准备超时
    [self performSelector:@selector(treadmillReadyTimeOut) withObject:nil afterDelay:4];
    // 定时发送心跳包
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTmr forMode:NSRunLoopCommonModes];
}

- (void)onFailedSend:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    Byte *databytes = (Byte *)[cmd.data bytes];
    Byte maincmd    = databytes[1];
    Byte subcmd     = databytes[2];
    // 如果是控制开始或结束的控制指令，这条指令重新发
    if (maincmd == 0x53/*FSMainCmdTreadmillControl*/ &&
        (subcmd == 0x09/*FSSubControlCmdTreadmillStart*/ ||
         subcmd == 0x03/*FSSubControlCmd_Stop_Pause*/)) {
        [self sendCommand:cmd];
    }
}

// 控制 ----------
- (BOOL)start {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 不是正常状态 不能启动
    if (self.currentStatus != FSDeviceStateNormal) return NO;
    [self sendData:FSGenerateCmdData.treadmillStart()];
    return YES;
}

- (void)stop {
    /*
     停止之前先保存一次即时速度，2秒以后，
     判断设备是否的速度是下降，如果设备的速度有下降就表示能控制
     */
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.originalSpeed = self.speed.intValue;
    /* MARK: 添加通过指令停止设备的标识*/
    self.stopWithCmd = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canStopEnable) object:nil];
    [self sendData:FSGenerateCmdData.treadmillStop()];
    [self performSelector:@selector(canStopEnable) withObject:nil afterDelay:2];
}

- (void)targetSpeed:(int)targetSpeed incline:(int)targetIncline {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    /*
     同时控制速度、坡度
     1 如果不是跑步机 因为速度不能控制，速度、坡度等于目标速度、目标坡度 直接返回
     2 过滤速度、坡度的上下限
     3 跑步机的速度可以控制，坡度不一定可以控制
       3.1 如果跑步的坡度不可控制，速度等于目标速度，直接返回， 否则发送执行后返回
     4 速度、坡度都是可以控制，发送指令
     */
    // 当前速度、坡度等于目标速度、坡度 直接返回
    if (self.speed.intValue == targetSpeed &&
        self.incline.intValue == targetIncline) {
        return;
    }

    targetSpeed = [self paramRangeOfMax:self.deviceParam.maxSpeed.intValue min:self.deviceParam.minSpeed.intValue compare:targetSpeed];
    targetIncline = [self paramRangeOfMax:self.deviceParam.maxIncline.intValue min:0 compare:targetIncline];
    //  21.04.30  MD，坡度值有-1的，增加判断
    targetIncline = [self signedParam:targetIncline];

    // 坡度不可以控制
    if (!self.deviceParam.supportIncline) {
        // 当前速度等于目标速度，不需要发送指令，直接返回
        if (self.speed.intValue == targetSpeed) {
            return;
        }
        self.originalSpeed = self.speed.intValue;
        [self.speedArr removeAllObjects];

        [self cancelDelayControllable];
        // 发送指令，坡度为0
        [self sendData:FSGenerateCmdData.treadmillControlSpeedAndIncline(targetSpeed, 0)];
        [self performSelector:@selector(speedIsControllable) withObject:nil afterDelay:afterDelayTime]; // 2
        return;
    }

    // 代码可以执行到这里，说那个设备的速度、坡度都可以控制， 并且其他条件也过滤掉，可以放心发送指令
    /*
     1 如果速度相等， 只发送坡度指令
     2 如果坡度相等， 只发送速度指令
     */
    self.originalSpeed = self.speed.intValue;
    [self.speedArr removeAllObjects];

    self.originalIncline = self.incline.intValue;
    [self.inclineArr removeAllObjects];

    if (targetSpeed == self.speed.intValue) { // 速度相等  发送坡度指令
        if (targetIncline == self.incline.intValue) {
            return;
        }

        [self cancelDelayControllable];
        [self sendData:FSGenerateCmdData.treadmillControlSpeedAndIncline(targetSpeed, targetIncline)];
        [self performSelector:@selector(inclineIsControllable) withObject:nil afterDelay:afterDelayTime];
        return;
    }

    if (targetIncline == self.incline.intValue) { // 坡度相等  发送速度指令
        if (targetSpeed == self.speed.intValue) {
            return;
        }

        [self cancelDelayControllable];
        [self sendData:FSGenerateCmdData.treadmillControlSpeedAndIncline(targetSpeed, targetIncline)];

        [self performSelector:@selector(speedIsControllable) withObject:nil afterDelay:afterDelayTime];
        // 最大值不做提示
        if (targetSpeed == self.deviceParam.maxSpeed.integerValue) {
            [self cancelDelayControllable];
        }
        return;
    }

    // 速度坡度都不相等
    [self cancelDelayControllable];
//    FSLog(@"22.4.1 发送指令  目标速度%d  目标坡度%d", targetSpeed, targetIncline);
    [self sendData:FSGenerateCmdData.treadmillControlSpeedAndIncline(targetSpeed, targetIncline)];
    [self performSelector:@selector(speedIsControllable) withObject:nil afterDelay:afterDelayTime];
}

// 失控处理
- (void)canStopEnable {
    /* 点击停止以后
     1 A10 启动不改变速度，进入10的状态
           启动》改变速度》进入减速停止中状态
     */
    // 设备进入暂停状态，说明有响应停止指令，直接返回
    if (self.isPausing) return;
    if (!self.isRunning) return;
    if (self.originalSpeed && self.speed.intValue == self.originalSpeed) {
        self.discontrolType = FSDiscontrolTypeStop;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCmdUncontrolled object:self];
    }
}

- (void)speedIsControllable {
    if (self.speedArr.count == 0) { // 失控
        self.discontrolType = FSDiscontrolTypeSpeed;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCmdUncontrolled object:self];
    }
}

// 坡度是否可以控制
- (void)inclineIsControllable {
    if (self.inclineArr.count == 0) { // 失控
        self.discontrolType = FSDiscontrolTypeIncline;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCmdUncontrolled object:self];
    }
}

- (void)cancelDelayControllable {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canStopEnable) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(inclineIsControllable) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(speedIsControllable) object:nil];
}

#pragma mark 心跳包
- (void)updateState:(NSTimer *__nullable)sender {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.commands.count < 3) {
        // MARK: 210617  增加判断设备状态
        if (self.currentStatus != FSDeviceStateDefault &&
            !self.getParamSuccess &&
            sender) {
            [self updateDeviceParams];
        }
        // 发送状态指令
        [self sendData:FSGenerateCmdData.treadmillStatus()];
    }
    return;
}

- (void)updateDeviceParams {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.treadmillSpeedParam()];
    // MARK: 延迟1秒获取设备坡度信息，
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendData:FSGenerateCmdData.treadmillInclineParam()];
    });

}

- (void)treadmillReadyTimeOut {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(treadmillReadyTimeOut) object:nil];
//    FSLog(@"指令队列   移除所有指令");
    [self.commands removeAllObjects];
    [self.sendCmdTimer invalidate];
    self.sendCmdTimer = nil;
    [self.heartbeatTmr invalidate];
//    FSLog(@"停止定时器 sendCmdTimer, heartbeatTmr");
    self.heartbeatTmr = nil;
    if (self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//        FSLog(@"33.6.6 代理回调断链 FSDisconnectTypeWithoutResponse");
        [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeWithoutResponse];
        [self removeFromManager];
    }
    [self disconnect];
}

@end


@interface FSSection ()

@property (nonatomic, assign) int originalResistance; // 原阻力  失控判断
@property (nonatomic, strong) NSMutableArray *resistanceArr;
@property (nonatomic, assign) int originalIncline; // 原阻力  失控判断
@property (nonatomic, strong) NSMutableArray *inclineArr;
//@property (nonatomic, assign) BOOL stopWithCmd;  // 指令停止

@end

@implementation FSSection

@synthesize currentStatus   = _currentStatus;
@synthesize isRunning       = _isRunning;
@synthesize isPausing       = _isPausing;
@synthesize hasStoped       = _hasStoped;
@synthesize isStarting      = _isStarting;
@synthesize isWillStart     = _isWillStart;
@synthesize getParamSuccess = _getParamSuccess;
@synthesize targetSpeed     = _targetSpeed;
@synthesize targetIncline   = _targetIncline;
@synthesize targetLevel     = _targetLevel;

- (void)setCurrentStatus:(FSDeviceState)currentStatus {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 车表机状态
    switch (currentStatus) {
        case -1:{
            _currentStatus = FSDeviceStateDefault;
        }
        case 0: {
            _currentStatus  = FSDeviceStateNormal;
        }
            break;
        case 1: {
            _currentStatus = FSDeviceStateStarting;
        }
            break;
        case 2: {
            _currentStatus = FSDeviceStateRunning;
        }
            break;
        case 3: {
            _currentStatus = FSDeviceStatePaused;
        }
            break;
        case 20:
        case 32: { // 睡眠  有2个，防呆不防傻
            _currentStatus = FSDeviceStateSectionSleep;
        };
            break;
        case 21:
        case 33: // 故障  防呆不防傻
            _currentStatus = FSDeviceStateError;
        default:
            break;
    }
    
    // 收到状态上报  回调蓝牙正常
    /* MARK：这个逻辑需要修改
     1 蓝牙状态不是工作中
     2 如果是意外断开重连的，不需要回调
     3 代理有值
     4 代理相应方法
     */
    if (self.connectState != FSConnectStateWorking &&
        !self.accidentalReconnect &&
        self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
        self.connectState = FSConnectStateWorking;
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
    }
}

- (BOOL)hasStoped {
    // TODO: XB 210507 其实这个只要判断设备  从其他状态变为  正常待机状态就是停止了
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.oldStatus == FSDeviceStateRunning &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }
    if (self.oldStatus == FSDeviceStatePaused &&
        self.currentStatus == FSDeviceStateNormal) {
        return YES;
    }
    return NO;
}

- (BOOL)isPausing {
    BOOL rst = NO;
    if (self.currentStatus == FSDeviceStatePaused) {
        rst = YES;
    }
    // 22.7.5  如果是指令停止，重新发送停止指令
    if (self.stopWithCmd) {
//        [self stop];
        rst = NO;
    }
    return rst;
}

- (BOOL)isRunning {
    if (self.currentStatus == FSDeviceStateRunning) {
        return YES;
    }
    return NO;

}

- (BOOL)isStarting {
    return self.currentStatus == FSDeviceStateStarting;
}

- (BOOL)isWillStart {
    if (self.oldStatus != FSDeviceStateStarting &&
        self.currentStatus == FSDeviceStateStarting ) {
        return YES;
    }
    return NO;
}

- (BOOL)getParamSuccess {
    if (self.speedObtainSuccess && self.inclineObtainSuccess) {
        return YES;
    }
    return NO;
}

- (void)setTargetLevel:(NSString *)targetLevel {
    // 当前坡度
    int cur_inl = self.incline.intValue;
    [self setTargetLevl:targetLevel.intValue incline:cur_inl];
    
}

- (void)setTargetSpeed:(NSString *)targetSpeed {
//    FSLog(@"目标速度");
    _targetSpeed = targetSpeed;
}

- (void)setTargetIncline:(NSString *)targetIncline {
//    FSLog(@"目标坡度");
    // 当前阻力
    int cur_lvl = self.resistance.intValue;
    [self setTargetLevl:cur_lvl incline:targetIncline.intValue];
//    _targetSpeed = _targetSpeed;
}

- (NSMutableArray *)resistanceArr {
    if (!_resistanceArr) {
        _resistanceArr = NSMutableArray.array;
    }
    return _resistanceArr;
}

- (NSMutableArray *)inclineArr {
    if (!_inclineArr) {
        _inclineArr = NSMutableArray.array;
    }
    return _inclineArr;
}

- (void)sectionReadyTimeOut {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sectionReadyTimeOut) object:nil];
//    FSLog(@"指令队列   移除所有指令");
    [self.commands removeAllObjects];
    [self.sendCmdTimer invalidate];
    self.sendCmdTimer = nil;
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = nil;
    if (self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//        FSLog(@"33.6.6 代理回调断链 FSDisconnectTypeWithoutResponse");
        [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeWithoutResponse];
    }
    [self disconnect];
}

- (BOOL)onUpdateData:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sectionReadyTimeOut) object:nil];
    Byte *bytes = (Byte *)[cmd.data bytes];
    Byte mainCmd    = bytes[1];
    Byte subcmd     = bytes[2];
//    FSLog(@"车表22.3.31 主指令：%d 子指令： %d", mainCmd, subcmd);

    switch (mainCmd) {
            /* FSMainCmdSectionParam */
        case 0x41: {
            [self sectionParams:cmd];
        }
            break;
            /*FSMainCmdSectionStatus*/
        case 0x42: {
            // 车表状态过滤
            if ([self sectionStateFilter:cmd]) {
                return YES;
            }
            // 车表状态数据解析
            [self sectionStateDataParsing:cmd];
        }
            break;
        case 0x43: { // 车表数据
            if (subcmd == 0x01) {
                // 获取运动数据
                uint runtime  = MAKEWORD(bytes[3], bytes[4]);  // 时间
                uint distance = MAKEWORD(bytes[5], bytes[6]);  // 距离
                uint calory   = MAKEWORD(bytes[7], bytes[8]);  // 卡路里
                NSString *calStr = FSFM(@"%d", calory);
                uint counts   = MAKEWORD(bytes[9], bytes[10]); // 次数
                // 距离做特殊处理
                // !!!: 距离赋值的地方
                if (bytes[6] & 0x80) { // 判断是不是以10米为单位的
                    distance = MAKEWORD(bytes[5], bytes[6] & 0x7f) * 10;
                } else {
                    distance = MAKEWORD(bytes[5], bytes[6]);
                }
                self.distance = FSFM(@"%d", distance);
                // MARK: 210713 针对金亚太程序烧入错误做适配
                if (self.module.deviceID.integerValue == 544344117) {
//                    [device setValue:device.distance.div(mileToKm) forKey:sportDistance];
//                    self.distance = [NSString stringWithFormat:@"%.0f", distance / 1.60934];
                    self.distance = self.distance.fsDiv(@"1.60934");
                }
                self.counts = FSFM(@"%d", counts);
                self.exerciseTime = FSFM(@"%d", runtime);
                self.calory = calStr.fsDiv(@"10").decimalPlace(1);
                FSLog(@"车表数据上报43： 时间%@  距离%@  卡路里%@  次数%@", self.exerciseTime, self.distance, self.calory, self.counts);
            } else if (subcmd == 0x02) { // 这条指令没发送，不需要做解析
                // 获取用户信息
            
            } else if (subcmd == 0x03) { // 这条指令没发送，不需要做解析
                // 获取程式信息
                
            }
            
        }
            break;
        case 0x44: {
            if (subcmd == 0x0A) { // 设置写入用户数据成功
//                FSLog(@"车表22.3.31 写入用户数据成功");
                self.writeUserDataSuccess = YES;
            }
            
            // 车表控制
            // 0x02 开始继续
            // 0x06 设置步进
            // 0x04 停止
            // 0x0A 写入用户数据
            // 0x03 暂停
            // 0x01 继续
            // 0x0D 程序模式
            // 0x0B 运动模式
            // 0x0C 功能开关
            // 0x05 设置参数  设置阻力  坡度
        }
            break;

        default:
            break;
    }



    // 阻力变化处理
    if (self.deviceParam.supportLevel) {
        if (self.originalResistance != self.resistance.intValue && ![self.resistanceArr containsObject:self.resistance]) {
            [self.resistanceArr addObject:self.resistance];
        }
    }

    // 坡度变化处理
    if (self.deviceParam.supportIncline) {
        if (self.originalIncline != self.incline.intValue && ![self.inclineArr containsObject:self.incline]) {
            [self.inclineArr addObject:self.incline];
        }
    }

    // 数据通过通知发送出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFitshoData object:self];

    return YES;
}

- (void)sectionParams:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    
    Byte *bytes = (Byte *)[cmd.data bytes];
//    Byte mainCmd    = bytes[1];
    Byte subcmd     = bytes[2];
    /* FSSubParamCmd_Speed_Param */
    if (subcmd == 0x02) { // 参数信息
//        FSLog(@"车表22.3.31 获取 阻力、坡度、配置、段数  还有公英制暂停等信息");
        // 获取阻力、坡度、配置、段数
        int maxResistance    = bytes[3];
        int maxIncline       = bytes[4];
        /// !!!: FS 最小阻力、单位、是否支持暂停的赋值 协议里面写的时候配置信息
        int unit             = bytes[5] & 0x01;
        int pause            = bytes[5] & 0x02;
        int deviceParagraph  = bytes[6];
        /* !!!: 210427 最大坡度  最小坡度  是有符号的整数，第一位是符号位 因此最大的数据就是127*/
        if (maxResistance > 127) {
            maxResistance = (256 - maxResistance) * -1;
        }

        if (maxIncline > 127) {
            maxIncline    = (256 - maxIncline)   * -1;
        }
        self.deviceParam.maxLevel = FSFM(@"%d", maxResistance);
        self.deviceParam.maxIncline = FSFM(@"%d", maxIncline);
        // MARK: 20210419 金亚太  因为模块烧入错误，这里做兼容，类型是车，测试模块名字FS-1B39B3， deviceid:544344117  厂商码：114 机型码：2101. 如果获取配置信息是公制单位，应该变成英制单位，逻辑：1 配置信息上报的单位是公制单位，2 deviceid==544344117
        if (self.module.deviceID.integerValue == 544344117 && !unit) {
            self.deviceParam.imperial = 1;
        }
        self.deviceParam.paragraph      = FSFM(@"%d", deviceParagraph);
        self.deviceParam.supportLevel   = maxResistance > 0 ? YES : NO;
        self.deviceParam.supportPause   = pause;
        self.deviceParam.supportIncline = maxIncline > 0 ? YES : NO;
        self.speedObtainSuccess         = YES;
        self.inclineObtainSuccess       = YES;
    }
}

- (BOOL)sectionStateFilter:(BleCommand *)cmd {
//    Byte *bytes = (Byte *)[cmd.data bytes];
//    Byte mainCmd    = bytes[1];
//    Byte subcmd     = bytes[2];
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 新旧状态赋值
//    self.oldStatus     = self.currentStatus;
//    self.currentStatus = subcmd; // 测试状态  会不会进入setter方法
//    FSLog(@"状态回调");
//    FSLog(@"22.6.2 模块%@  当前状态:%d  旧状态:%d", self.module.name,  self.currentStatus, self.oldStatus);
//    if (self.oldStatus != self.currentStatus &&
//        self.deviceDelegate &&
//        [self.deviceDelegate respondsToSelector:@selector(deviceDidUpdateState:fromState:)]) {
//        [self.deviceDelegate deviceDidUpdateState:self.currentStatus fromState:self.oldStatus];
//    }
    
    if (self.hasStoped) {
        [self disconnect];
//        FSLog(@"22.6.2设备停止了");
        [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
    }

    if (self.currentStatus == FSDeviceStateError) {
        // 代理回调
        if ([self.deviceDelegate respondsToSelector:@selector(deviceError:)]) {
            [self.deviceDelegate deviceError:self];
        }
        return YES;
    }

    // !!!: 这里对君斯大的设备做特殊处理,理论上来讲，这个设备还么量产，应该有厂家修改，app严格执行对外的开放协议就好
    if (self.oldStatus == FSDeviceStateStarting &&
        self.currentStatus == FSDeviceStateNormal) {
        [self disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
        return YES;
    }
    return NO;

}

- (void)sectionStateDataParsing:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    Byte *bytes = (Byte *)[cmd.data bytes];
//    Byte mainCmd    = bytes[1];
    Byte subcmd     = bytes[2];
    // 新旧状态赋值
    self.oldStatus     = self.currentStatus;
    self.currentStatus = subcmd;
    if (subcmd == 3 && self.stopWithCmd) {
        // 22.7.5  如果设备处于暂停状态并且是通过指令停止的，再发一次停止指令
        [self stop];
    }
    FSLog(@"模块%@  当前状态:%d  旧状态:%d", self.module.name,  self.currentStatus, self.oldStatus);
    // 车表状态改变，通过代理回调出去
    if (self.oldStatus != self.currentStatus &&
        self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(deviceDidUpdateState:fromState:)]) {
        [self.deviceDelegate deviceDidUpdateState:self.currentStatus fromState:self.oldStatus];
    }
    
    switch (subcmd) {
        case 0: {} // 待机
            break;
        case 21:
        case 33: { // 故障
            // 代理回调 故障
            if ([self.deviceDelegate respondsToSelector:@selector(deviceError:)]) {
                [self.deviceDelegate deviceError:self];
            }
            [self disconnect];
        }
            break;
        case 2:   // 运行中
        case 3: { // 暂停
            uint spd         = MAKEWORD(bytes[3], bytes[4]);
//            NSString *spdStr = FSFM(@"%d", spd);
            uint resistance  = bytes[5];
            uint frequency   = MAKEWORD(bytes[6], bytes[7]);
            uint heartRate   = bytes[8];
            uint watt        = MAKEWORD(bytes[9], bytes[10]);
            uint slope       = bytes[11];
            uint duanshu     = bytes[12];
            self.speed       = FSFM(@"%d", spd);
            self.resistance  = FSFM(@"%d", resistance);
            self.frequency   = FSFM(@"%d", frequency);
            self.heartRate   = FSFM(@"%d", heartRate);
            self.watt        = FSFM(@"%d", watt);
            self.incline     = FSFM(@"%d", slope);
            self.paragraph   = FSFM(@"%d", duanshu);
            FSLog(@"车表数据上报42::: 速度%@  阻力%@  频率%@  心率%@ 功率%@  坡度%@  段数%@", self.speed, self.resistance, self.frequency, self.heartRate, self.watt, self.incline, self.paragraph);
        }
            break;
        case 20:
        case 32: { // 睡眠  防呆不防傻

        }
            break;
        case 1:{ // 启动中

        }
            break;
        default:
            break;
    }

}

#pragma mark 重写父类的方法
- (void)dataReset {
    [super dataReset];
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.originalIncline = 0;
    [self.inclineArr removeAllObjects];
    self.originalResistance = 0;
    [self.resistanceArr removeAllObjects];
    // MARK:210701 开始肯定不是指令开始&停止
    self.stopWithCmd = NO;
//    fs_sport.codeCtrlModel.isStartWithCmd = NO;
    
}

- (void)onConnected {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
//    [self clearSend];
    // 数据重置
    [self dataReset];
    // 获取状态指令

    // 判断是不是准备超时
    [self performSelector:@selector(sectionReadyTimeOut) withObject:nil afterDelay:4];
    // 定时发送心跳包
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTmr forMode:NSRunLoopCommonModes];
}

- (void)updateState:(NSTimer *)sender {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // FIXME:22.3.30  车表心跳的逻辑还是缺失的，这个得改
    if (self.commands.count < 3) {
        if (self.currentStatus != FSDeviceStateDefault) {
            if (!self.writeUserDataSuccess) {
                // 写入用数据
                [self sendData:FSGenerateCmdData.sectionWriteUserData(0, 70, 170, 25, 00)];
            }

            if (!self.getParamSuccess) { // 更新设备参数
                [self updateDeviceParams];
            }
        }
        // 获取状态信息
        [self sendData:FSGenerateCmdData.sectionStatue()];
        // 获取运动数据
        [self sendData:FSGenerateCmdData.sectionSportDada()];
    }
}

- (void)updateDeviceParams {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.sectionParamInfo()];
}

- (void)onFailedSend:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));

}

- (BOOL)start {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 车表正常待机  睡眠都可以启动
    if (self.currentStatus == FSDeviceStateNormal ||
        self.currentStatus == FSDeviceStateSectionSleep) {
    } else {
        return NO;
    }
    [self sendData:FSGenerateCmdData.sectionWriteUserData(0, 70, 170, 25, 00)];
    [self sendData:FSGenerateCmdData.sectionStatue()];
    [self sendData:FSGenerateCmdData.sectionReady()];
    [self sendData:FSGenerateCmdData.sectionWriteUserData(0, 70, 170, 25, 00)];
    [self sendData:FSGenerateCmdData.sectionStart()];
//    FSLog(@"%@  start", NSStringFromClass([self class]));
    return YES;
}

- (void)stop {
    /* MARK: 添加通过指令停止设备的标识*/
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.stopWithCmd = YES;
    [self sendData:FSGenerateCmdData.sectionStop()];
}

- (void)setTargetLevl:(int)t_level incline:(int)t_incline {
//    FSLog(@"发送车表控制指令");
    /*
     同时控制阻力、坡度
     1 直接返回
       不是车表协议，
       阻力&坡度都不能控制，
       阻力、坡度等于目标阻力、目标坡度
       阻力不可控，坡度等于目标坡度
       坡度不可空，阻力等于目标阻力
     2 过滤速度、坡度的上下限
     3 跑步机的速度可以控制，坡度不一定可以控制
       3.1 如果跑步的坡度不可控制，速度等于目标速度，直接返回， 否则发送执行后返回
     4 速度、坡度都是可以控制，发送指令
     */
    if (!self.module.isSectionProtocol) return;
    
    if (!self.deviceParam.supportLevel &&
        !self.deviceParam.supportIncline) return;
    
    if (self.resistance.intValue == t_level &&
        self.incline.intValue == t_incline) return;
    
    if (!self.deviceParam.supportLevel &&
        self.incline.intValue == t_incline) return;
    
    if (!self.deviceParam.supportIncline &&
        self.resistance.intValue == t_level) return;

    int targetLevel = 0;
    int targetIncline = 0;
//    FSLog(@"最大阻力 %@", self.deviceParam.maxLevel);
    targetLevel = [self paramRangeOfMax:self.deviceParam.maxLevel.intValue min:self.deviceParam.minLevel.intValue compare:t_level];
    targetIncline = [self paramRangeOfMax:self.deviceParam.maxIncline.intValue min:0 compare:t_incline];
//    FSLog(@"发送车表控制指令  阻力%d  坡度:%d", targetLevel, targetIncline);
    [self sendData:FSGenerateCmdData.sectionControlParam(targetLevel, targetIncline)];
    
    if (self.deviceParam.supportLevel) {
        [self performSelector:@selector(levelIsControllable) withObject:nil afterDelay:afterDelayTime];
        return;
    }

    if (self.deviceParam.supportIncline) {
        [self performSelector:@selector(inclineIsControllable) withObject:nil afterDelay:afterDelayTime];
    }
}

// 失控处理
- (void)levelIsControllable {
    if (self.resistanceArr.count == 0) { // 阻力失控
        self.discontrolType = FSDiscontrolTypeResistance;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCmdUncontrolled object:self];
    }
}

// 坡度是否可以控制
- (void)inclineIsControllable {
    if (self.inclineArr.count == 0) { // 坡度失控
        self.discontrolType = FSDiscontrolTypeIncline;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCmdUncontrolled object:self];
    }
}

- (void)cancelDelayControllable {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canStopEnable) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(inclineIsControllable) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(levelIsControllable) object:nil];
}



@end


/*
 共用父类的属性， 父类初始化的时候有默认值
 1. 运动时长  单位 秒  sportTime      def:0
 2. 卡路里            calory         def:0
 3. 速度             speed           def:0
 4. 当前状态          currentStatus   def:-1
 5. 旧状态            oldStatus       def:-1
 */

@interface FSRope()

// 开始跳绳的时间
@property (nonatomic, strong) NSDate *startDate;


@end

@implementation FSRope

@synthesize currentStatus = _currentStatus;
@synthesize isRunning = _isRunning;
@synthesize hasStoped = _hasStoped;
@synthesize isPausing = _isPausing;

- (instancetype)initWithModule:(BleModule *)module {
    if (self = [super initWithModule:module]) {
        [self dataReset];
    }
    return self;
}

#pragma mark 跳绳重写父类属性的setter && getter 方法
- (void)setCurrentStatus:(FSDeviceState)currentStatus {
    
    switch (currentStatus) {
        case -1: {
            _currentStatus = FSDeviceStateDefault;
        }
            break;
        case 0: {
            _currentStatus = FSDeviceStateNormal;
        }
            break;
        case 1: {
            _currentStatus = FSDeviceStateRunning;
        }
            break;
            
        default:
            break;
    }
    
    // 回调蓝牙正在工作中
    if (self.connectState != FSConnectStateWorking) {
        self.connectState = FSConnectStateWorking;
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
    }
}

- (BOOL)isRunning {
    return self.currentStatus == FSDeviceStateRunning ? YES : NO;
}

- (BOOL)hasStoped {
    if (self.oldStatus == FSDeviceStateRunning &&
        self.currentStatus == FSDeviceStateNormal) {
//        FSLog(@"添加最后一次绊绳");
        return YES;
    }
    return NO;
}

- (BOOL)isPausing {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    return NO;
}

-(BOOL)onUpdateData:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    NSData *data = cmd.data;
    Byte *databytes = (Byte *)[data bytes];
    Byte dataType = databytes[0];    // 数据类型
    switch (dataType) {
        case 2: { // 电量
            unsigned int battery = databytes[1];
            self.battery = FSFM(@"%d", battery);
        }
            break;
        case 4: { // 实时数据, 每秒一个Notify
            /*
             0    1    2 3   4 5    6 7    8 9    10 11    12 13
             实时 状态  时间   总跳数  速度    跘绳数   连跳     卡路里
             */
            // MARK: 20220207 添加跳绳统计的条 如果次数 时间 同时相等，直接不统计
            int cnts = self.totalCnts.intValue;
            int times = self.exerciseTime.intValue;
            unsigned int status = databytes[1]; // 状态
            self.oldStatus = self.currentStatus;
            self.currentStatus = status;
            // 如果状态补一致，把新旧状态都回调出去
            if (self.oldStatus != self.currentStatus &&
                self.currentStatus != FSDeviceStateDefault &&
                self.deviceDelegate &&
                [self.deviceDelegate respondsToSelector:@selector(deviceDidUpdateState:fromState:)]) {
                [self.deviceDelegate deviceDidUpdateState:self.currentStatus fromState:self.oldStatus];
            }
            if (self.hasStoped) { // 是不是停止了
                [self disconnect];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
            }
            
            // 运动时间
            unsigned int r_time       = MAKEWORD(databytes[2], databytes[3]);
            // 总跳数
            unsigned int r_totalCnts  = MAKEWORD(databytes[4], databytes[5]);
            // 速度
            unsigned int r_speed      = MAKEWORD(databytes[6], databytes[7]);
            // 跘绳
            unsigned int r_interrupt  = MAKEWORD(databytes[8], databytes[9]);
            // 连跳
            unsigned int r_continuous = MAKEWORD(databytes[10], databytes[11]);
            // 卡路里
            unsigned int r_calories   = MAKEWORD(databytes[12], databytes[13]);
            self.exerciseTime         = FSFM(@"%d", r_time);
            self.totalCnts            = FSFM(@"%d", r_totalCnts);
            self.speed                = FSFM(@"%d", r_speed);
            self.interruptCnts        = FSFM(@"%d", r_interrupt);
            self.calory               = FSFM(@"%d", r_calories);
            self.continueCnts         = FSFM(@"%d", r_continuous);
            // 当前时间
            NSDate *now = [NSDate date];
            NSInteger passTime = (NSInteger)[now timeIntervalSinceDate:self.startDate];
            if (r_interrupt > self.interruptCnts.intValue) {
                // 更新连跳时间
                if (passTime > self.maxContinueTimes.integerValue) {
                    self.maxContinueTimes = FSFM(@"%ld", (long)passTime);
                }
                self.startDate = [NSDate date]; // 重置开始时间
                // FIXME: 添加统计数据
            } else {
                // 连跳时长
                self.continueTimes = FSFM(@"%ld", (long)passTime);
            }
            
            // 计算平均次频
            if (self.exerciseTime.integerValue > 1) {
                int avg = self.totalCnts.intValue * 1.0 / self.exerciseTime.intValue * 60;
                self.avg_cntFreq = FSFM(@"%d", avg);
            }
            
            // 更新最大连跳 MARK: 20211102 数据不是一秒传一次
            if (self.continueCnts.intValue > self.maxContinueCnts.intValue) {
                self.maxContinueCnts = self.continueCnts;
            }
            // FIXME:XB 统计
            if (cnts == self.totalCnts.intValue &&
                times == self.exerciseTime.intValue) {
                return YES;
            }
        }
            break;
        case 5: { // 多个历史数据
            
        }
            break;
        case 6: { // 厂商名字
            
        }
            break;
        case 7: { // 设备序列号
            
        }
            break;
        case 8: { // 设备型号
            
        }
            break;
        case 9: { // 软件版本
            
        }
            break;
        case 10: { // 固件版本
            
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

#pragma mark 重写父类的方法
- (void)dataReset {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.interruptCnts    = @"0";
    self.continueCnts     = @"0";
    self.continueTimes    = @"0";
    self.totalCnts        = @"0";
    self.avg_cntFreq      = @"0";
    self.maxContinueCnts  = @"0";
    self.maxContinueTimes = @"0";
    [super dataReset];
    // 删除指令，这个方法应该在父类调用，子类不需要写
    [self clearSend];
}

- (void)onConnected {
    // 数据重置
    [self dataReset];

    // 判断是不是准备超时
    [self performSelector:@selector(readyTimeOut) withObject:nil afterDelay:4];
    // 定时发送心跳包
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTmr forMode:NSRunLoopCommonModes];
}

-(void)updateState:(NSTimer *)sender {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 如果指令队列没有指令，就一直获取电量
    if (self.commands.count == 0) {
        [self sendData:FSGenerateCmdData.ropeHeartbeat()];
    }
}

- (void)readyTimeOut {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)onFailedSend:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));

}

- (BOOL)start {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.ropeStarFreeMode()];
    self.startDate = [NSDate date];
    return YES;
}

- (void)stop {
    [self sendData:FSGenerateCmdData.ropeStop()];
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceCnts:(NSInteger)cnt {

//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceTime:(NSInteger)time {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minPause {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.ropePause()];
}

- (void)minRestore {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.ropeRestore()];
}


@end

/*
 !!!: 甩脂机  时间 速度使用父类的属性
 时间：sportTime 单位为分钟/秒，不管APP给液晶面板发什么数据，面板上就显示什么数据，而不需要判断是分钟还是秒。
 速度：speed     范围为1~100，速度设定必须在手动模式和运行的条件下设置才有效，自动模式和停止状态下设定无效
 卡路里：calory       内部自己计算
 故障码：errorCode
 运动时间：sportTime   内部自己计算
 */

@interface FSSlimming ()

// MARK: 最后一条指令，如果心跳包没有指令，发送最后一条指令
@property (nonatomic, strong) BleCommand *lastCmd;

/// 运动的定时器
@property (nonatomic, strong) NSTimer *sportTimer;

/// 210812 增加统计时间
@property (nonatomic) int timeIncrement;

@property (nonatomic) NSString *totalCalory;


@end


@implementation FSSlimming

@synthesize currentStatus = _currentStatus;
//@synthesize isRunning = _isRunning;
@synthesize hasStoped     = _hasStoped;

- (UInt8)identifyCode {
    return 0x90;
}

- (instancetype)initWithModule:(BleModule *)module {
    if (self = [super initWithModule:module]) {
        // MARK: 甩脂机状态变化只有运动/停止 因此在初始化把当天状态设置为0，不然会弹出设备休眠提示框
        [self setValue:@"0" forKey:@"currentStatus"];
        self.totalCalory = @"0";
        self.mode        = [FSSlimmingMode new];
    }
    return self;
}

#pragma mark  定时器方法
- (void)startSportTimer {
    if (!self.sportTimer) {
        self.sportTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sportTimeIncrement:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.sportTimer forMode:NSRunLoopCommonModes];
    }
}

// 运动时间 正向递增
- (void)sportTimeIncrement:(NSTimer *)sender {
    self.timeIncrement += 1;
}


- (void)stopSportTimer {
    [self.sportTimer invalidate];
    self.sportTimer = nil;
}

- (void)wakeUp {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.slimmingWakeUps()];
}

- (void)slimmingStartParagram {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
//    [self sendData:FSGenerateCmdData.slimmingMode()];
    [self sendData:FSGenerateCmdData.slimmingNewMode(self.lastCmd.data, self.mode)];
    self.isFirstStop = YES;
}

- (void)slimmingTargetSpeed:(int)speed {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // FIXME: 这个数据需要做过滤 最大速速不能超过配置的速度
    [self sendData:FSGenerateCmdData.slimmingSpeed(speed, self.lastCmd.data)];
}

- (void)slimmingTargetTime:(int)time {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // FIXME: 这个数据需要做过滤 最大速速不能超过配置的速度
    [self sendData:FSGenerateCmdData.slimmingTime(time, self.lastCmd.data)];
}

- (void)slimmingTargetTime:(int)time randomNum:(int)randomNum {
    [self sendData:FSGenerateCmdData.slimmingChangeTime(time, randomNum, self.lastCmd.data)];
    
}

- (void)slimmingSwitchMode {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.slimmingNewMode(self.lastCmd.data, self.mode)];
}

#pragma mark 重写父类属性的setter && getter 方法
- (void)setCurrentStatus:(FSDeviceState)currentStatus {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 22.7.5  重构方法
    switch (currentStatus) {
        case -1: {
            _currentStatus = FSDeviceStateDefault;
        }
            
            break;
        case 1: {
            _currentStatus = FSDeviceStateRunning;
        }
            break;
            
        default: {
            _currentStatus = currentStatus;
            // 回调蓝牙正在工作中
            if (self.connectState != FSConnectStateWorking) {
                self.connectState = FSConnectStateWorking;
                [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
            }
        }
            break;
    }
    
//    if (currentStatus == 1) {
//        _currentStatus = FSDeviceStateRunning;
//    }
//    _currentStatus = currentStatus;
//    // 回调蓝牙正在工作中
//    if (self.connectState != FSConnectStateWorking) {
//        self.connectState = FSConnectStateWorking;
//        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
//    }
    
}

//- (BOOL)isRunning {
//    FSLog(@"甩脂机  重写 isRunning 的 getter方法");
//    return NO;
//}

- (BOOL)hasStoped {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.oldStatus == FSDeviceStateRunning && self.currentStatus == FSDeviceStateNormal) {
        // 设备已经停止
        if (self.switchMode) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)onUpdateData:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    Byte *bytes = (Byte *)[cmd.data bytes];
    // 校验码
    Byte check = bytes[0];
    // 器材识别
    Byte identify = bytes[1];
    /* 判断蓝牙上报数据是否为甩脂机的， 这里只有判断 校验码&器材识别 */
    if (check != /*BLE_SLIMMING_CRC*/0x5A && identify != 0x90) {
        return YES;
    }
    /*
     校验码:Byte0    器材识别:Byte1    故障:Byte2    卡路里低:Byte3    模式:Byte4
     速度:Byte5    分+卡路里高:Byte6    秒:Byte7    运行/停止:Byte8    待机:Byte9
     校验和:Byte10
     0      1       2    3       4    5     6         7     8        9     10
     5A     90      00   00      00   04    0A        00    00       01    F9
     校验码 器材识别  故障 卡路里低  模式  速度  分+卡路里高   秒   运行/停止  待机  校验和
     */
    // 故障码
    self.errorCode = FSFM(@"%d", bytes[2]);
    // 判断故障码
    // 重写故障码
    if ([self slimmingError]) {
        // 有故障
        [self.heartbeatTmr invalidate];
        self.heartbeatTmr = nil;
        [self stopSportTimer];
//        FSLog(@"指令队列   移除所有指令");
        [self.commands removeAllObjects];
        [self disconnect];
        // FIXME: 22.3.31 如果是停止发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFitshoData object:self];
        return YES;
    }
    
    self.currentMode = bytes[4];
    // FIXME: 210722 运动秀的模块，返回的模式不会是A1-A7, 而是1-7 因此这里先做处理
    self.currentMode = bytes[4] % 0xA0 + 0xA0;
    // 速度
    self.speed = FSFM(@"%d", bytes[5]);
    // 运行/停止
    self.isRunning = bytes[8];
    // MARK: 210812  根据运行与否，对运动正向时间的定时做开启与关闭处理
    self.isRunning ? [self startSportTimer] : [self stopSportTimer];
    self.oldStatus = self.currentStatus;
    self.currentStatus = self.isRunning;
    
    self.isStandby = bytes[9];
    // 卡路里 BYTE3+((BYTE6&0X0F0)>>4)*256  第7个数据位高4位是卡路里的高位  &&  时间要高低位计算
    self.calory = FSFM(@"%d", bytes[3] + ((bytes[6] & 0xF0) >> 4) * 256);
    // 计算时间 BYTE6时间分 低4为，0~15；高4位，卡路里高位
    self.exerciseTime = FSFM(@"%d", bytes[7] + (bytes[6] & 0X0F) * 60);
    // 不是切换模式，新状态为未运动，老状态为运行中，才发送完全停止的通知
    if (self.hasStoped) {
        [self disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
    }
    // 解析完成以后，通过通知把数据传出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFitshoData object:self];
    
    return YES;
}

// 甩脂机 故障处理
- (BOOL)slimmingError {
    if (self.errorCode.integerValue >= SlimmingErrorO1 && self.errorCode.integerValue <= SlimmingErrorO7) {
        switch (self.errorCode.integerValue) {
            case SlimmingErrorO1: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingOvercurrentAlarm);
            }
                break;
            case SlimmingErrorO2: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingCommunicationFail);
            }
                break;
            case SlimmingErrorO3: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingMotorLossFailure);
            }
                break;
            case SlimmingErrorO4: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingDisconnectionAlarm);
            }
                break;
            case SlimmingErrorO5: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingFailedReceiveData);
            }
                break;
            case SlimmingErrorO6: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingControllerFailure);
            }
                break;
            case SlimmingErrorO7: {
                self.errorCode = FSFM(@"%ld", (long)SlimmingOtherFailures);
            }
                break;
                
            default:
                break;
        }
        
    }
    return NO;
}

#pragma mark 重写父类的方法
- (void)dataReset {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [super dataReset];
    // 删除指令，这个方法应该在父类调用，子类不需要写
    [self clearSend];
}

- (void)onConnected {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 刚刚连上的到时候，切换模式设为为NO
    self.switchMode = NO;
    // 连接成功先唤醒设备
    [self wakeUp];

    // 判断是不是准备超时
//    [self performSelector:@selector(readyTimeOut) withObject:nil afterDelay:4];
    // 定时发送心跳包
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTmr forMode:NSRunLoopCommonModes];
}

- (void)commit {
    // FIXME: xb  这个方法是否需要重写 应该好好考虑
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.switchMode) {
        // 判断甩脂机是否在运行
        if (self.isRunning) { // 是切换模式，并且甩脂机还在运行
            // 一定要把上一条指令删除
            [super commit];
            [self stop];
            return;
        }
        // 能走到这里，说明是切换模式，而且甩脂机不是在运行，可以发送新的模式指令下去
        [super commit];
        // 切换新模式
        [self slimmingSwitchMode];
        self.switchMode = NO;
        return;
    }
    [super commit];
}

- (void)sendCommand:(BleCommand *)command {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (command) {
        self.lastCmd = command;
    }
    [super sendCommand:command];
}

-(void)updateState:(NSTimer *)sender {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.commands.count == 0) { // 指令队列没有指令，发送送最后一条指令，
        [self sendCommand:self.lastCmd];
    }
}

- (void)readyTimeOut {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)onFailedSend:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));

}

- (BOOL)start {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendData:FSGenerateCmdData.slimmingStart(self.targetMode, self.lastCmd.data)];
    self.isFirstStop = YES;
    return YES;
}

- (void)stop {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceCnts:(NSInteger)cnt {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceTime:(NSInteger)time {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minPause {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minRestore {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

@end

@implementation FSPower

@synthesize currentStatus = _currentStatus;
@synthesize isRunning = _isRunning;
@synthesize hasStoped = _hasStoped;



#pragma mark 重写父类属性的setter && getter 方法
- (void)setCurrentStatus:(FSDeviceState)currentStatus {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // FIXME: 22.7.5 XB  力量训练这个方法需要重构，因为设备还没有出货，暂时不做处理
    _currentStatus = currentStatus;
    // 回调蓝牙正在工作中
    if (self.connectState != FSConnectStateWorking) {
        self.connectState = FSConnectStateWorking;
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
    }
    
}

- (BOOL)isRunning {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    return NO;
}

- (BOOL)hasStoped {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    
    return NO;
}

- (BOOL)onUpdateData:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 回调蓝牙正在工作中
    if (self.connectState != FSConnectStateWorking) {
        self.connectState = FSConnectStateWorking;
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
    }
    return YES;
}

#pragma mark 重写父类的方法
- (void)dataReset {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    [super dataReset];
    // 删除指令，这个方法应该在父类调用，子类不需要写
    [self clearSend];
}

- (void)onConnected {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    // 数据重置
    [self dataReset];

    // 判断是不是准备超时
    [self performSelector:@selector(readyTimeOut) withObject:nil afterDelay:4];
    // 定时发送心跳包
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTmr forMode:NSRunLoopCommonModes];
}

-(void)updateState:(NSTimer *)sender {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)readyTimeOut {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)onFailedSend:(BleCommand *)cmd {
//    FSLog(@"%@", NSStringFromSelector(_cmd));

}

- (BOOL)start {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    return YES;
}

- (void)stop {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceCnts:(NSInteger)cnt {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minDeviceTime:(NSInteger)time {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minPause {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)minRestore {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
}


@end

