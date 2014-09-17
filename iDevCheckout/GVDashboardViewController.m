//
//  GVDashboardViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/12/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVDashboardViewController.h"
#import "GVUserTableViewController.h"
#import "GVSignatureViewController.h"

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

- (IBAction)unwindCancelCheckin:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"You have cancled checkout!");
    //Notify user that the checkout was canceled.  
}

- (IBAction)unwindToSaveCheckin:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"You have saved!");

    
    GVSignatureViewController* src = unwindSegue.sourceViewController;
    
    PFObject *checkInRecord = [PFObject objectWithClassName:@"DevOut"];
    PFObject *user = src.user;
    PFObject *device= src.device;
    
    checkInRecord[@"dev_id"] = device[@"device_id"];
    checkInRecord[@"user_id"] = user[@"user_id"];
    
    [checkInRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // alert here.
        
    }];
    
}
@end
