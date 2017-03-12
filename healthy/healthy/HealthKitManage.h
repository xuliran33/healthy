//
//  HealthKitManage.h
//  healthy
//
//  Created by 徐丽然 on 17/3/10.
//  Copyright © 2017年 徐丽然. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <uikit/UIDevice.h>

// 获取系统版本
#define HKVersion [[[UIDevice currentDevice] systemVersion] doubleValue]
#define CustomHealthErrorDomain @"com.sdqt.healthError"

@interface HealthKitManage : NSObject

// 存储健康类数据
@property (nonatomic, strong)HKHealthStore *healthStore;

// 创建单例方法
+(id)shareInstance;

/**
 * 检查是否支持获取健康数据, 系统大于8.0才支持健康数据的访问
 */
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;

// 读取步数
- (void)getStepCount:(void(^)(double value, NSError *error))completion;

//获取公里数, 跑步加行走距离
- (void)getDistance:(void(^)(double value, NSError *error))completion;

@end
