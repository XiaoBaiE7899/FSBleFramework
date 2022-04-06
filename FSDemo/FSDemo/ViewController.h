//
//  ViewController.h
//  FSBluetoothSDK
//
//  Created by zt on 2021/1/23.
//

#import <UIKit/UIKit.h>

#define weakObj(value) __weak typeof(value) weak##value = value;
#define SPBLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); }

@interface ViewController : UIViewController


@end

