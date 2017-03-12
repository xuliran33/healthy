//
//  ViewController.m
//  healthy
//
//  Created by 徐丽然 on 17/3/10.
//  Copyright © 2017年 徐丽然. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManage.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)stepsClick:(id)sender {
    // 获取健康数据管理单例
    HealthKitManage *manage = [HealthKitManage shareInstance];
    [manage authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            [manage getStepCount:^(double value, NSError *error) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   self.stepLabel.text = [NSString stringWithFormat:@"steps : %.0f步", value];
               });
            }];
        }
        else{
            NSLog(@"fail");
        }
    }];
    
}

- (IBAction)distanceClick:(id)sender {
    HealthKitManage *manage = [HealthKitManage shareInstance];
    [manage authorizeHealthKit:^(BOOL success, NSError *error) {
        
        if (success) {
            NSLog(@"success");
            [manage getDistance:^(double value, NSError *error) {
                NSLog(@"2count-->%.2f", value);
                NSLog(@"2error-->%@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.distanceLabel.text = [NSString stringWithFormat:@"公里数：%.2f公里", value];
                });
                
            }];
        }
        else {
            NSLog(@"fail");
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
