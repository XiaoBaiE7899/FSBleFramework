
#import "FSGenerateCmdData.h"

#pragma mark 调试相关的
const int fsRopeDeviceInfo         = 4; // 获取设备信息
const int fsRopeBatteryMainCmd     = 2; // 读取设备电量 主指令
const int fsRopeBatterySubCmd      = 0; // 读取设备电量的子命令
const int fsRopeSetDateTimeMainCmd = 1; // 设置时间，获取时间 主指令
const int fsRopeSetDateTimeSubCmd  = 0; // 设备时间， 子指令
const int fsRopeDeviceControl      = 3; // 控制指令

#pragma mark 力量器械的控制指令
const int fsPowerControlGroupCnts  = 1; // 每组个数设定

const int fsPowerControl           = 2; // 控制
const int fsPowerControlPause      = 1; // 暂停/停止
const int fsPowerControlStop       = 2; // 停止
const int fsPowerControlStart      = 3; // 开始

const int fsPowerClean             = 3; // 清空
const int fsPowerCleanAll          = 0; // 清空当前数据的次数与卡路里以及训练时长；
const int fsPowerCleanCnts         = 1; // 清空当前数据的次数；
const int fsPowerCleanCal          = 2; // 清空当前数据的卡路里；
const int fsPowerCleanTime         = 3; // 清空当前数据的训练时长；

const int fsPowerMode              = 5; // 模式
const int fsPowerModeGroup         = 1; // 每次根据APP设定每组个数；
const int fsPowerModeFree          = 2; // 自由模式

const int fsPowerReadData          = 6; // 读取数据
const int fsPowerState             = 0; // 读取数据

typedef NS_ENUM(NSInteger, BLE_CMD) {
    // 帧头
    BLE_CMD_START    = 0x02,
    // 帧尾
    BLE_CMD_END      = 0x03,
    /* 甩脂机的指令帧头   帧尾是校验和含帧头 */
    BLE_SLIMMING_CRC = 0x5A,
};

typedef NS_ENUM(NSInteger, FSMainCmd) {
    // 配置设备型号：0x02 0x50 0x00 0x50 0x03  可以获取设备品牌、机型
    FSMainCmdModel             = 0x50,
    // 车表：参数
    FSMainCmdSectionParam      = 0x41,
    // 车表：状态
    FSMainCmdSectionStatus     = 0x42,
    // 车表：数据
    FSMainCmdSectionData       = 0x43,
    // 车表：控制
    FSMainCmdSectionControl    = 0x44,
    // 跑步机：状态
    FSMainCmdTreadmillStatus   = 0x51,
    // 跑步机：数据
    FSMainCmdTreadmillData     = 0x52,
    // 跑步机：控制
    FSMainCmdTreadmillControl  = 0x53,
};

// 二级数据指令
typedef NS_ENUM(NSInteger, FSSubDataCmd) {
    /*
     跑步机：读取当前运动量
     */
    FSSubDataCmdTreadmillDataSport   = 0x00,
    /*
     跑步机：当前运动信息 实际没使用
     车表：  时间W 距离W 热量W 计数W  获取0x02 0x43 0x01 0x43 0x03
     */
    FSSubDataCmd_SportInfo_Data      = 0x01,
    /*
     跑步机:速度数据(程式模式)  实际没使用
     车表: 获取0x02 0x43 0x02 0x41 0x03：  用户L 运动L 模式B 段数B 目标W  没使用
     */
    FSSubDataCmd_Speed_SportInfo     = 0x02,
    /*
     跑步机：坡度数据(程式模式)   实际没使用
     车表：  获取：  索引B 数据N  这个可能不会用到  没使用
     */
    FSSubDataCmd_Incline_ProgramData = 0x03,
};

// 二级控制指令
typedef NS_ENUM(NSInteger, FSStartModeCmd) {
    /*
     跑步机：正常模式，用于快速启动
     车表：  自由
     */
    FSStartModeCmdFree              = 0x00,
    // 时间
    FSStartModeCmdTime              = 0x01,
    // 距离
    FSStartModeCmdDistance          = 0x02,
    // 卡路里
    FSStartModeCmdCalory            = 0x03,
    // 车表：次数
    FSStartModeCmdSectionCount      = 0x04,
    // 跑步机  程序
    FSStartModeCmdTreadmillPogram   = 0x05,
    // 车表：阻力
    FSStartModeCmdSectionResistance = 0x10,
    // 车表：心率
    FSStartModeCmdSectionHeartRate  = 0x20,
    // 车表：瓦特
    FSStartModeCmdSectionWatt       = 0x30
};

// 二级控制指令
typedef NS_ENUM(NSInteger, FSSubControlCmd) {
    // 跑步机 写入用户数据
    FSSubControlCmdTreadmillUserData     = 0x00,
    /*
     跑步机： 准备开始（1.1）（START 前写入运动数据）
     车表： 准备就绪
     */
    FSSubControlCmdReady                 = 0x01,
    /*
     跑步机：控制速度、坡度（用户手动操作）
     车表：开始
     */
    FSSubControlCmd_SpeedIncline_Start   = 0x02,
    /*
     跑步机：停止设备（此指令直接停止设备）
     车表： 暂停
     */
    FSSubControlCmd_Stop_Pause           = 0x03,
    /*
     跑步机：速度数据(程式模式)
     车表：停止
     */
    FSSubControlCmd_Speed_Stop           = 0x04,
    /*
     跑步机：坡度数据(程式模式)
     车表：设置参数  设置阻力  坡度
    */
    FSSubControlCmd_Incline_SrAndI       = 0x05,
    // 车表：设置步进  设置阻力  坡度
    FSSubControlCmdSectionStep           = 0x06,
    // 跑步机：开始或恢复设备运行（1.1 正式启动）
    FSSubControlCmdTreadmillStart        = 0x09,
    /*
     跑步机：暂停设备（1.1）
     车表：写入用户信息
     */
    FSSubControlCmd_Pause_UserData       = 0x0A,
    // 车表：运动模式
    FSSubControlCmdSectionSportMode      = 0x0B,
    // 车表：功能关开
    FSSubControlCmdSectionFunctionSwitch = 0x0C,
    // 车表： 设置程式模式
    FSSubControlCmdSectionProgram        = 0x0D
};


// 二级参数指令
typedef NS_ENUM(NSInteger, FSSubParamCmd) {
    // 获取设备机型 (必需实现)
    FSSubParamCmdTreadmillModel = 0x00,
    // 同步设备日期，返回版本日期1.0.5
    FSSubParamCmdTreadmillDate  = 0x01,
    /*
     跑步机:速度
     车表: 阻力B  坡度B  配置B  段数B
     */
    FSSubParamCmd_Speed_Param   = 0x02,
    /*
     跑步机：坡度
     车表：  累计值
     */
    FSSubParamCmd_Incline_Total = 0x03,
    /*
     跑步机：累计里程
     车表：  同步时间：传入数据  年月日周时分秒 年传入后2位
     */
    FSSubParamCmd_Total_Date    = 0x04
};

@implementation FSGenerateCmdData

+ (NSData *(^)(UInt8 *, int))prepareSendData {
    return ^NSData *(UInt8 *data, int len) {
        UInt8 crc = self.calculateCheckNum(data + 1, len - 3);
        data[len - 2] = crc;
        NSData *rst = [NSData dataWithBytes:data length:len];
        return rst;
    };
}

+ (UInt8 (^)(UInt8 *, int))calculateCheckNum {
    return ^UInt8 (UInt8 *data, int len) {
        uint16_t temp = data[0];
        for (int i = 1; i < len; i++) {
            temp =  temp^data[i];
        }
        temp = (temp & 0xff);
        return temp;
    };
}

// 计算校验和
+ (NSData *(^)(UInt8 *, int))slimmingCheckSum {
    return ^NSData *(UInt8 *data, int lenth) {
        int sum = 0;
        UInt8 checkSum = 0;
        for (int i = 0; i < lenth; i++) {
            sum += data[i];
        }
        // 检验和
        checkSum = sum & 0xff;
        data[lenth - 1] = checkSum;
        NSData *rst = [NSData dataWithBytes:data length:lenth];
        return rst;
    };
}

// 跑步机 -----------------------
/* MARK: 跑步机没有调用指令先注释掉
//+ (NSData *(^)(void))resumeTreadmill; // 恢复跑步机 没调用
//+ (NSData *(^)(void))totalInfo;       // 没调用
//+ (NSData *(^)(void))deviceInfoMode;  // 没调用
//+ (NSData *(^)(int))fixedTime;        // 固定时间  没有调用
//+ (NSData *(^)(int))fixedDistance;    // 固定距离 没有调用
//+ (NSData *(^)(int))fixedCaloriesr;   // 固定卡路里  没有调用
//+ (NSData *(^)(void))deviceDataSport; // 获取设备运动数据 没有调用
//+ (NSData *(^)(void))deviceDataInfo;  // 获取跑步机信息 没有调用
//+ (NSData *(^)(void))pauseTreadmill;  // 暂停跑步机  没有调用
*/

+ (NSData *(^)(void))treadmillSpeedParam {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdModel, FSSubParamCmd_Speed_Param, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))treadmillInclineParam {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START,FSMainCmdModel, FSSubParamCmd_Incline_Total, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))treadmillStart {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdTreadmillControl, FSSubControlCmdReady, 0x00, 0x01, 0x00, 0x00, FSStartModeCmdFree, 0x00, 0x00, 0x00, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))treadmillStatus {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdTreadmillStatus, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))treadmillStop {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdTreadmillControl,
            FSSubControlCmd_Stop_Pause,0, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, int))treadmillControlSpeedAndIncline {
    return ^NSData *(int speed, int incline){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdTreadmillControl, FSSubControlCmd_SpeedIncline_Start, speed, incline,0, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, int, int, int, int))treadmillWriteUserData {
    return ^NSData *(int uid, int w, int h, int a, int s){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdTreadmillControl, FSSubControlCmdTreadmillUserData, 0x00, 0x00, 0x00, 0x00, w, h, a, s, 0x00,  BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}


// ------  车表
/* MARK: 没有调用的方法
 // 运动模式，
 + (NSData *(^)(void))carTableSportModeFree;
 + (NSData *(^)(int))carTableSportModeTime;
 + (NSData *(^)(int))carTableSportModeDistance;
 + (NSData *(^)(int))carTableSportModeCalory;
 + (NSData *(^)(int))carTableSportModeCount;
 + (NSData *(^)(int))carTableSportModeResistance;
 + (NSData *(^)(int))carTableSportModeheartRate;
 + (NSData *(^)(int))carTableSportModeWatt;
 + (void)carTableFunctionSwitch; // 设置功能开关
 - (void)carTableProgarm; // 设置程式数据
 + (void)carTableControlStep:(int)zuli incline:(int)slope; // 不明白什么意思
 + (NSData *(^)(void))carTablePause; // 没有调用
 + (NSData *(^)(void))carTableParamDate; // 同步时间 年月日周时分秒 年传入后2位
 + (NSData *(^)(void))carTableParamTotal; // 累计值  没有调用
 + (NSData *(^)(void))deviceInfoMode; // 模块信息  没有调用
 */

// 获取设备参数 阻力B  坡度B  配置B  段数B
+ (NSData *(^)(void))sectionParamInfo {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionParam, FSSubParamCmd_Speed_Param, 0x40, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))sectionStatue {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionStatus, 0x42, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))sectionSportDada {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionData, FSSubDataCmd_SportInfo_Data, 0x42, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))sectionReady {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionControl, FSSubControlCmdReady, 0x45, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))sectionStart {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionControl, FSSubControlCmd_SpeedIncline_Start, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(void))sectionStop {
    return ^NSData *(){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionControl, FSSubControlCmd_Speed_Stop, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, int))sectionControlParam {
    return ^NSData *(int r, int incline){
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionControl, FSSubControlCmd_Incline_SrAndI, r, incline, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, int, int, int, int))sectionWriteUserData {
    return ^NSData *(int u_id, int w, int h, int a, int sex ) {
        uint8_t cmd[] = {BLE_CMD_START, FSMainCmdSectionControl, FSSubControlCmd_Pause_UserData, (Byte)((u_id >> 24) & 0xFF), (Byte)((u_id >> 16) & 0xFF), (Byte)((u_id >> 8) & 0xFF), (Byte)(u_id & 0xFF), w, h, a, sex, 0x00, BLE_CMD_END};
        return self.prepareSendData(cmd, sizeof(cmd));
    };
}

// 甩脂机、筋膜枪----------
/*
 甩脂机指令发送格式
 校验码:Byte0
 器材识别:Byte1
 运行/停止:Byte2      0：停止：停止运动  1：运行：开始运动
 时间设定/显示:Byte3   单位为分钟/秒，不管APP给液晶面板发什么数据，面板上就显示什么数据，而不需要判断是分钟还是秒。
 速度设定/显示:Byte4 范围为1~100，速度设定必须在手动模式和运行的条件下设置才有效，自动模式和停止状态下设定无效
 模式设定/显示:Byte5 手动档和自动档标志位，1为手动，0为自动。自动模式P1~P3，手动模式
 上一曲/下一曲:Byte6 0：未操作 1：上一曲 2：下一曲
 音乐播放/停止:Byte7 0：停止播放音乐 1：播放音乐
 音量控制:Byte8     0：未操作音量，不加不减  1：音量加  2：音量减
 待机:Byte9        0：不待机  1：待机
 校验和:Byte10
 */

// 唤醒设备  不让设备处于待机状态
+ (NSData *(^)(void))slimmingWakeUps {
    
    return ^NSData * {
        uint8_t cmd[] = {BLE_SLIMMING_CRC, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(SlimmingMode, NSData *))slimmingStart {
    return ^NSData *(SlimmingMode mode, NSData *lastData) {

        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        
        cmd[2] = 1;
        cmd[4] = 1;
        cmd[5] = mode;
        // 最后一位校验和置为0
        cmd[10] = 0x00;
        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(NSData *))slimmingStop {
    return ^NSData *(NSData *lastData) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        
        // 第3位 数据设置为0x00
        cmd[2] = 0;
        // 最后一位校验和置为0
        cmd[10] = 0x00;
        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

// 切换新模式 跟 启动程序模式 代码一样
+ (NSData *(^)(NSData *, FSSlimmingMode *))slimmingNewMode {
    return ^NSData *(NSData *lastData, FSSlimmingMode *mode) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        
        // 第3位 数据设置为0x00
        cmd[2] = mode.run;
        // 时间
        cmd[3] = mode.time;
        // 速度
        cmd[4] = mode.speed;
        // 模式
        cmd[5] = mode.mode;
        // 最后一位校验和置为0
        cmd[10] = 0x00;
        // 切换模式
        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, NSData *))slimmingTime {
    return ^NSData *(int time, NSData *lastData) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        // 第4位  设置时间
        cmd[3] = time;
        // 最后一位校验和置为0
        cmd[10] = 0x00;

        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, int, NSData *))slimmingChangeTime {
    return ^NSData *(int time ,int randomNum, NSData *lastData) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        // 第4位  设置时间
        cmd[3] = time;
        // 5.6.7位数是为了传入相同时间有效果，加了几位进行区别指令不完全相同
        // 上一曲/下一曲
        cmd[6] = random() % 2;
        // 音乐播放/停止
        cmd[7] = random() % 1;
        // 第八位 音量控制 要求是0-3的，但没用到，我就随机数传入了
        cmd[8] = random() % 2;
        // 最后一位校验和置为0
        cmd[10] = 0x00;

        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}

+ (NSData *(^)(int, NSData *))slimmingSpeed {
    return ^NSData *(int speed, NSData *lastData) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        // 第5位  设置速度
        cmd[4] = speed;
        // 最后一位校验和置为0
        cmd[10] = 0x00;
        return self.slimmingCheckSum(cmd, sizeof(cmd));

    };
}

+ (NSData *(^)(SlimmingMode, NSData *))slimmingMode {
    return ^NSData *(SlimmingMode mode, NSData *lastData) {
        Byte *databytes = (Byte *)[lastData bytes];
        UInt8 cmd[11] = {0,0,0,0,0,0,0,0,0,0,0};
        
        for (int i = 0; i < 11; i++) {
            cmd[i] = databytes[i];
        }
        
        // 第6位 设置模式
        cmd[5] = mode;
        // 最后一位校验和置为0
        cmd[10] = 0x00;
        return self.slimmingCheckSum(cmd, sizeof(cmd));
    };
}


// 跳绳、健腹轮


/*
 !!!: 跳绳的指令不用计算校验码，直接发送指令就行
 */
// 获取设备信息
+ (NSData *(^)(void))ropeInfo {
    return ^NSData *(void) {
        UInt8 data[2] = {fsRopeDeviceInfo, 0};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 启动自由模式
+ (NSData  *(^)(void))ropeStarFreeMode {
    return ^NSData *(void) {
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypeFree, 0, 0};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 启动定数模式
+ (NSData *(^)(NSInteger))ropeStarCountsMode {
    return ^NSData * (NSInteger cnt) {
        // MARK: 小端对齐
        NSInteger num1 = (cnt & 0xff00 ) >> 8;
        NSInteger num2 = cnt & 0x00ff;
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypeCount, num2, num1};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 启动定时模式
+ (NSData *(^)(NSInteger))ropeStarTimeMode {
    return ^NSData * (NSInteger time) {
        NSInteger num1 = (time & 0xff00 ) >> 8;
        NSInteger num2 = time & 0x00ff;
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypeTime, num2, num1};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 停止
+ (NSData *(^)(void))ropeStop {
    return ^NSData * (void) {
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypeStop, 0, 0};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 暂停
+ (NSData *(^)(void))ropePause {
    return ^NSData * (void) {
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypePause, 0, 0};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}


// 恢复
+ (NSData *(^)(void))ropeRestore {
    return ^NSData *(void) {
        UInt8 data[] = {fsRopeDeviceControl, FSCountersControlTypeRecover, 0, 0};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}
// 设置设备的时间
+ (NSData *(^)(void))ropeSetDeviceDate {
    return ^NSData *(void) {
        /*
         let dateTimeS = Math.trunc( new Date().getTime()/1000) // 时间戳  秒级别的
         let byte_1 = dateTimeS >> 24,byte_2 = date >> 16 & 0xff ,byte_3 = date >> 8 & 0xff,byte_4 = date & 0xff
         */
        NSDate *date = [NSDate date];
        NSInteger timeInterval = (NSInteger)[date timeIntervalSince1970];
        NSInteger byte_1 = timeInterval >> 24;
        NSInteger byte_2 = timeInterval >> 16 & 0xff;
        NSInteger byte_3 = timeInterval >> 8 & 0xff;
        NSInteger byte_4 = timeInterval & 0xff;
        UInt8 data[] = {fsRopeSetDateTimeMainCmd, fsRopeSetDateTimeSubCmd, byte_1, byte_2, byte_3, byte_4};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}
// 读取设备的时间
+ (NSData *(^)(void))ropeReadDeviceDate {
    return ^NSData *(void) {
        UInt8 data[] = {fsRopeSetDateTimeMainCmd, fsRopeSetDateTimeSubCmd};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 读取设备的电量，心跳包也是发这条指令
+ (NSData *(^)(void))ropeHeartbeat {
    return ^NSData *(void) {
        UInt8 data[] = {fsRopeBatteryMainCmd, fsRopeBatterySubCmd};
        NSData *rst = [NSData dataWithBytes:data length:sizeof(data)];
        return rst;
    };
}

// 力量器械

@end
