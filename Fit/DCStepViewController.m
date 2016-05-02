//
//  DCStepViewController.m
//  Fit
//
//  Created by aaron on 16/4/30.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "DCStepViewController.h"

@interface DCStepViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *readStepLabel;
@property (weak, nonatomic) IBOutlet UITextField *writeStepTextField;

@end

@implementation DCStepViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _writeStepTextField.delegate = self;
    
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    [self fetchSumOfSamplesTodayForType:stepType unit:[HKUnit countUnit] completion:^(double stepCount, NSError *error) {
        NSLog(@"%f",stepCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            _readStepLabel.text = [NSString stringWithFormat:@"%.f",stepCount];
        });
    }];
}

#pragma mark - #pragma mark - Reading HealthKit Data

- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesToday];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - Convenience

- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}


#pragma mark - #pragma mark - writing HealthKit Data

- (IBAction)doneDidiClick:(UIButton *)sender {
    
    [self addstepWithStepNum:_writeStepTextField.text.doubleValue];
}

- (void)addstepWithStepNum:(double)stepNum {
    // Create a new food correlation for the given food item.
    HKQuantitySample *stepCorrelationItem = [self stepCorrelationWithStepNum:stepNum];
    
    [self.healthStore saveObject:stepCorrelationItem withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.view endEditing:YES];
                UIAlertView *doneAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [doneAlertView show];
            }
            else {
                NSLog(@"The error was: %@.", error);
                UIAlertView *doneAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [doneAlertView show];
                return ;
            }
        });
    }];
}

- (HKQuantitySample *)stepCorrelationWithStepNum:(double)stepNum {
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [NSDate dateWithTimeInterval:-300 sinceDate:endDate];
    
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepNum];
    
    HKQuantityType *stepConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKDevice *device = [[HKDevice alloc] initWithName:@"iPhone" manufacturer:@"Apple" model:@"iPhone" hardwareVersion:@"iPhone6s plus" firmwareVersion:@"iPhone6s plus" softwareVersion:@"9.3.1" localIdentifier:@"aaron" UDIDeviceIdentifier:@"aaron"];
//    NSDictionary *stepCorrelationMetadata = @{HKMetadataKeyUDIDeviceIdentifier: @"aaron's test equipment",
//                                                  HKMetadataKeyDeviceName:@"iPhone",
//                                                  HKMetadataKeyWorkoutBrandName:@"Apple",
//                                                  HKMetadataKeyDeviceManufacturerName:@"Apple"};
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:startDate endDate:endDate device:device metadata:nil];
    return stepConsumedSample;
}




@end
