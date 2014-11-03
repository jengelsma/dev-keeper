//
//  GVDetailViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/3/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVDetailViewController.h"
#import <Parse/Parse.h>

@interface GVDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation GVDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        

        

        
        // device
        PFObject *object = self.detailItem;
        PFObject *device = object[@"device_obj"];
        PFObject *user = object[@"user_obj"];
        self.deviceId.text = object[@"dev_id"];
        self.deviceName.text = device[@"name"];
        self.deviceOsForm.text = [NSString stringWithFormat:@"%@/%@", device[@"type"],device[@"os"]];
        self.checkoutDate.text = object.createdAt.description;
        PFFile *deviceThumbnail = device[@"device_photo"];
        if(deviceThumbnail) {
            [deviceThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.deviceThumbnail.image = image;
                    self.userThumbnail.layer.cornerRadius = 8.0f;
                    self.userThumbnail.clipsToBounds = YES;
                }
            }];
        }
        

        
        // checkout
        self.userName.text = user[@"user_name"];
        self.userId.text = object[@"user_id"];
        PFFile *userThumbnail = user[@"user_photo"];
        if(userThumbnail) {
            [userThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.userThumbnail.image = image;
                    self.deviceThumbnail.layer.cornerRadius = 8.0f;
                    self.deviceThumbnail.clipsToBounds = YES;
                }
            }];
        }
        
        // signature
        PFFile *thumbnail = object[@"signature"];
        if(thumbnail) {
            [thumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.signatureImage.image = image;
                }
            }];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if(buttonIndex) {
        PFObject *_checkout = self.detailItem;
        if(_checkout != nil) {
            PFObject *archiveLog = [PFObject objectWithClassName:@"CheckoutLog"];
            archiveLog[@"dev_id"] = _checkout[@"dev_id"];
            archiveLog[@"user_id"] = _checkout[@"user_id"];
            archiveLog[@"signature"] = _checkout[@"signature"];
            archiveLog[@"checkout_date"] = [_checkout createdAt];
//            [archiveLog saveInBackground];
//            [_checkout deleteInBackground];
            
            [archiveLog saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                // delete the checkout, then notify client agent that device is now available and pop to dashboard.
                [_checkout deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [PFPush sendPushMessageToChannelInBackground:[NSString stringWithFormat:@"CH%@",archiveLog[@"dev_id"]] withMessage:archiveLog[@"user_id"]];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } ];
            }];

        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}


- (IBAction)returnDeviceButtonPress:(id)sender {
    NSString *msg;
    msg = [NSString stringWithFormat:@"Are you sure you would like to return this device without scanning its barcode?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checking in a device"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
