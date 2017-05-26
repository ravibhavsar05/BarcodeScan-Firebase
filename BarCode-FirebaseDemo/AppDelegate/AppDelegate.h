//
//  AppDelegate.h
//  BarCode-FirebaseDemo
//
//  Created by Ravi Bhavsar on 04/05/17.
//  Copyright © 2017 . All rights reserved.
//

#import <UIKit/UIKit.h>



@import Firebase;
@import FirebaseMessaging;

//Constants for whole app

#define SCANDATA @"ScanData"
#define APPDELEGATE (AppDelegate*)[UIApplication sharedApplication].delegate
#define NSLog(...) {}
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FIRDatabaseReference *refFIRBase;

@end

