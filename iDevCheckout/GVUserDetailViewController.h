//
//  GVAddUserViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/10/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GVUserDetailViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (strong,nonatomic) PFObject* user;
@end
