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

    GVSignatureViewController* src = unwindSegue.sourceViewController;
    
    PFObject *checkInRecord = [PFObject objectWithClassName:@"DevOut"];
    PFObject *user = src.user;
    PFObject *device= src.device;
    
    checkInRecord[@"dev_id"] = device[@"device_id"];
    checkInRecord[@"user_id"] = user[@"user_id"];
    
    NSString *imageFileName = @"sign.jpg" ;
    NSData *imageData = UIImageJPEGRepresentation(src.mainImage.image, 0.05f);
    PFFile *file = [PFFile fileWithName:imageFileName data:imageData];
    [file saveInBackground];
    checkInRecord[@"signature"] = file;
    
    [checkInRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            NSString *msg = [NSString stringWithFormat:@"Device %@ has been checked out by %@", device[@"device_id"],user[@"user_name"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Checked Out!"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else {
            NSLog(@"oops, probs");
        }
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    // ok, now have the table reload
    UITableViewController *tbc = (UITableViewController *)self.childViewControllers[0];
    [tbc.tableView reloadData];

}


@end
