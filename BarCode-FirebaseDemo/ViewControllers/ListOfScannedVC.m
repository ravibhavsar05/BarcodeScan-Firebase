//
//  ListOfScannedVC.m
//  BarCode-FirebaseDemo
//
//  Created by Ravi Bhavsar on 04/05/17.
//  Copyright © 2017 . All rights reserved.
//

#import "ListOfScannedVC.h"

@interface ListOfScannedVC ()
{
    NSMutableArray *arrProductList;
}
@end

@implementation ListOfScannedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get the lis of products from Firebase
    [self getListFromFirebase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Get Firebase method

-(void)getListFromFirebase{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    FIRDatabaseReference *refFIRBase=[APPDELEGATE refFIRBase];
    arrProductList=[[NSMutableArray alloc]init];
    [[refFIRBase child:SCANDATA] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSMutableDictionary *dictData=snapshot.value;
            
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
            NSArray* arrayRef = [[dictData allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            

            for (id obje in arrayRef) {
                NSDictionary *dictRef= [dictData objectForKey:obje];
                [arrProductList addObject:dictRef];
            }
           
            [self.tblOutlet reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
    }];
    
    
}

- (IBAction)btnBackAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES
     ];
}

#pragma mark UITableView delegate-datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrProductList.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *dictData=[arrProductList objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@-%@",[dictData objectForKey:@"Value"],[dictData objectForKey:@"Code"]];
    return cell;
    
}

@end
