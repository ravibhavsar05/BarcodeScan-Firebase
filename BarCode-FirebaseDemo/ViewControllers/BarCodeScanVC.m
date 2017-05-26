//
//  BarCodeScanVC.m
//  BarCode-FirebaseDemo
//
//  Created by Ravi Bhavsar on 04/05/17.
//  Copyright © 2017 . All rights reserved.
//

#import "BarCodeScanVC.h"
#import "AppDelegate.h"
#import "ListOfScannedVC.h"

@interface BarCodeScanVC ()
@end

@implementation BarCodeScanVC


@synthesize scannerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
     [self seUpScannerLib];
}
-(void)viewWillAppear:(BOOL)animated{
//    [scannerView stopScanSession];
//    [scannerView stopCaptureSession];
//    [self seUpScannerLib];
    
}
#pragma mark Initial setup methods
-(void)seUpScannerLib{
    // Set verbose logging to YES so we can see exactly what's going on
    [scannerView setVerboseLogging:YES];
    
    // Set animations to YES for some nice effects
    [scannerView setAnimateScanner:YES];
    
    // Set code outline to YES for a box around the scanned code
    [scannerView setDisplayCodeOutline:YES];
    
    // Start the capture session when the view loads - this will also start a scan session
    [scannerView startCaptureSession];
    
    // Set the title of the toggle button
    self.scanBtnOutlet.title = @"Stop";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
   
}
#pragma mark Action methods
- (IBAction)scanBtnAction:(UIBarButtonItem *)sender {
    if ([scannerView isScanSessionInProgress]) {
        [scannerView stopScanSession];
        self.scanBtnOutlet.title = @"Start";
    } else {
        [scannerView setAnimateScanner:YES];
        [scannerView startScanSession];
        self.scanBtnOutlet.title = @"Stop";
    }
}


- (IBAction)btnScanListAction:(UIButton *)sender {
    [scannerView stopScanSession];
    self.scanBtnOutlet.title = @"Start";
    
    [self performSegueWithIdentifier:@"ListOfScannedVC" sender:sender];
}
#pragma mark Save Firebase method
-(void)callWebAPI:(NSString *)strCode{
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //third party api.upcdatabase.org API for getting product name
    NSString *urlString = [NSString stringWithFormat:@"http://api.upcdatabase.org/json/8d133a11a19b9a29a0cf662862ae2377/%@",strCode];
    NSLog(@"%@",urlString);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
       
        NSLog(@"Responce Data:%@",responseObject);
        NSMutableDictionary *dictData=(NSMutableDictionary *)responseObject;
        
        if ([dictData[@"valid"] isEqualToString:@"false"]) {
            NSDictionary *dictRes=[NSDictionary dictionaryWithObjectsAndKeys:@"No Name",@"Value",strCode,@"Code", nil];
            [self saveInFirebase:dictRes];
        }
        else
        {
            NSDictionary *dictRes=[NSDictionary dictionaryWithObjectsAndKeys:dictData[@"itemname"],@"Value",strCode,@"Code", nil];
            [self saveInFirebase:dictRes];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.scannerView makeToast:@"Something wrong for barcode scan API"];
        NSDictionary *dictRes=[NSDictionary dictionaryWithObjectsAndKeys:@"No Name",@"Value",strCode,@"Code", nil];
        
        [self saveInFirebase:dictRes];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    }];

}

//save scanned product in Firebase
-(void)saveInFirebase:(NSDictionary *)dicData{
  
    
    FIRDatabaseReference *refFIRBase=[APPDELEGATE refFIRBase];
    [[refFIRBase child:SCANDATA] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDate *date = [NSDate date];
        NSTimeInterval timeStamp = [date timeIntervalSince1970];
        [[[refFIRBase child:SCANDATA] child:[NSString stringWithFormat:@"%0.f",timeStamp]] setValue:dicData];
         [self.scannerView makeToast:@"Scanned Product saved Successfully"];
    }];
}




#pragma mark RMScannerViewDelegate methods

- (void)didScanCode:(NSString *)scannedCode onCodeType:(NSString *)codeType {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Scanned %@", [scannerView humanReadableCodeTypeForCode:codeType]]
                                                                   message:scannedCode
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button one");
                                                              self.scanBtnOutlet.title = @"Start";
                                                              [scannerView startScanSession];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Save"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button two");
                                                                self.scanBtnOutlet.title = @"Start";
//                                                                 [self saveInFirebase:scannedCode];
                                                               
                                                                 [self callWebAPI:scannedCode];
                                                               
                                                           }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"Another Scan"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button three");
                                                               [scannerView startScanSession];
                                                               self.scanBtnOutlet.title = @"Stop";
                                                          }];

    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    

    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)errorGeneratingCaptureSession:(NSError *)error {
    [scannerView stopCaptureSession];
    
    [self.scannerView makeToast:@"This device does not have a camera. Run this app on an iOS device that has a camera."];
    
    self.scanBtnOutlet.title = @"Error";
}

- (void)errorAcquiringDeviceHardwareLock:(NSError *)error {
    [self.scannerView makeToast:@"Tap to focus is currently unavailable. Try again in a little while."];

}

- (BOOL)shouldEndSessionAfterFirstSuccessfulScan {
    // Return YES to only scan one barcode, and then finish - return NO to continually scan.
    // If you plan to test the return NO functionality, it is recommended that you remove the alert view from the "didScanCode:" delegate method implementation
    // The Display Code Outline only works if this method returns NO
    return YES;
}

@end
