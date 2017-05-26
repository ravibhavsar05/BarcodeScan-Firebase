//
//  BarCodeScanVC.h
//  BarCode-FirebaseDemo
//
//  Created by Ravi Bhavsar on 04/05/17.
//  Copyright © 2017 . All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RMScannerView.h"


@interface BarCodeScanVC : UIViewController<RMScannerViewDelegate>

@property (weak, nonatomic) IBOutlet RMScannerView *scannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanBtnOutlet;
- (IBAction)btnScanListAction:(UIButton *)sender;

@end
