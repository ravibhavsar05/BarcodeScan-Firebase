//
//  ListOfScannedVC.h
//  BarCode-FirebaseDemo
//
//  Created by Ravi Bhavsar on 04/05/17.
//  Copyright © 2017 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListOfScannedVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblOutlet;
- (IBAction)btnBackAction:(UIBarButtonItem *)sender;

@end
