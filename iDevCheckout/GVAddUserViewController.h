//
//  GVAddUserViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/10/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVAddUserViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;

@end
