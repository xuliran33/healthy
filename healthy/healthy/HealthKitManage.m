//
//  HealthKitManage.m
//  healthy
//
//  Created by 徐丽然 on 17/3/10.
//  Copyright © 2017年 徐丽然. All rights reserved.
//

#import "HealthKitManage.h"

@implementation HealthKitManage

+ (id)shareInstance{
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

/**
 * 检查是否支持获取健康数据, 系统大于8.0才支持健康数据的访问
 */
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion{
    if (HKVersion >= 8.0) {
        if (![HKHealthStore isHealthDataAvailable]) {
            NSError *error = [NSError errorWithDomain:@"com.raywenderlich.tutorials.healthkit" code:2 userInfo:[NSDictionary dictionaryWithObject:@"HealthKit is not available in th is Device"                                                                      forKey:NSLocalizedDescriptionKey]];
            NSLog(@"==============%@", error);
            if (compltion != nil) {
                compltion(false, error);
            }
            
            return;
            
        }
        
        if ([HKHealthStore isHealthDataAvailable]) {
            if (self.healthStore == nil) {
                self.healthStore = [[HKHealthStore alloc] init];
            }
            
            /**
             * 组装需要读写的数据类型
             */
            NSSet *writeDataTypes = [self dataTypesToWrite];
            NSSet *readDataTypes = [self dataTypeRead];
            /**
             * 注册需要读写的数据类型, 也可以在"健康"App中重新修改
             */
            [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
                if (compltion != nil) {
                    NSLog(@"error ->%@", error.localizedDescription);
                    compltion(success, error);
                }
            }];
        }
    }else{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:CustomHealthErrorDomain code:0 userInfo:userInfo];
        compltion(0,aError);
    }

}

/**
 * 需要写入健康数据的类型
 */
- (NSSet *)dataTypesToWrite{
    // 声明我们想写入的健康数据类型
    // 身高
    HKQuantityType * heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    // 体重
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    // 体温
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    // 活动消耗的能量
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType, weightType, activeEnergyType, nil];
}

/**
 * 想要读取的数据权限
 */
- (NSSet *)dataTypeRead{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, distance, activeEnergyType,nil];
}

// 读取步数
- (void)getStepCount:(void(^)(double value, NSError *error))completion{
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    // 排序, 升序
    NSSortDescriptor *timeSortDescript = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[HealthKitManage predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescript] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            completion(0, error);
        }else{
            NSInteger totalSteps = 0;
            for (HKQuantitySample *sample in results) {
                HKQuantity *quantity = sample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double userHeight = [quantity doubleValueForUnit:heightUnit];
                
                totalSteps += userHeight;
            }
            
            completion(totalSteps, error);
        
        }
    }];
    [self.healthStore executeQuery:query];
}

//获取公里数, 跑步加行走距离
- (void)getDistance:(void(^)(double value, NSError *error))completion
{
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:distanceType predicate:[HealthKitManage predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if(error)
        {
            NSLog(@"==========+++++++%@", error);
            completion(0,error);
        }
        else
        {
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *distanceUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                double usersHeight = [quantity doubleValueForUnit:distanceUnit];
                totleSteps += usersHeight;
            }
            NSLog(@"当天行走距离 = %.2f",totleSteps);
            completion(totleSteps,error);
        }
    }];
    [self.healthStore executeQuery:query];
}

// 当天时间段的方法实现
+ (NSPredicate *)predicateForSamplesToday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    // 用来保存当前获取的时间, 当前获取年月日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    // 开始时间
    NSDate *startDate = [calendar dateFromComponents:components];
    // 结束时间
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    NSLog(@"========%@/n========%@/n========%@", startDate, endDate, predicate);
    
    return predicate;
}
@end
