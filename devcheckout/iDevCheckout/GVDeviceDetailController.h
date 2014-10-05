//
//  GVDeviceDetailController
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/17/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GVDeviceDetailController : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//@property (strong,nonatomic) PFObject *user;
@property (strong,nonatomic) PFObject *device;
//@property (strong,nonatomic) NSString *barcode;
//@property (strong,nonatomic) NSString *os;
//@property (strong,nonatomic) NSString *form;
//@property (strong,nonatomic) NSString *desc;
@property (weak, nonatomic) IBOutlet UILabel *deviceId;
@property (weak, nonatomic) IBOutlet UITextField *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *formFactor;
@property (weak, nonatomic) IBOutlet UITableViewCell *formFactorPickerCell;

@property (weak, nonatomic) IBOutlet UIPickerView *formFactorPicker;

@property (weak, nonatomic) IBOutlet UITableViewCell *osPickerCell;
@property (weak, nonatomic) IBOutlet UILabel *osPickerLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *osPicker;
@property (weak, nonatomic) IBOutlet PFImageView *deviceImage;
@end
