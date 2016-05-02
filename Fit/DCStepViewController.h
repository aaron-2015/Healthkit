//
//  DCStepViewController.h
//  Fit
//
//  Created by aaron on 16/4/30.
//  Copyright © 2016年 Apple. All rights reserved.
//

@import UIKit;
@import HealthKit;

@interface DCStepViewController : UITableViewController

@property (nonatomic) HKHealthStore *healthStore;

@end
