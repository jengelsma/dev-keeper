//
//  GVMasterViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/3/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GVDetailViewController;

@interface GVMasterViewController : UITableViewController

@property (strong, nonatomic) GVDetailViewController *detailViewController;
@property (nonatomic,strong) NSString* deviceId;
- (void)loadCheckouts;
@end
