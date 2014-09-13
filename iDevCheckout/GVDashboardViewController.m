//
//  GVDashboardViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/12/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVDashboardViewController.h"
#import "GVUserTableViewController.h"

@implementation GVDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"CheckOutDevice"]) {
        GVUserTableViewController *dest = [segue destinationViewController];
        dest.displayMode = USER_SELECT_MODE;
    } else if ([segue.identifier isEqualToString:@"EditUsers"]) {
        GVUserTableViewController *dest = [segue destinationViewController];
        dest.displayMode = USER_EDIT_MODE;
    }
}

@end
