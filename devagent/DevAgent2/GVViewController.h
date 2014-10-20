//
//  GVViewController.h
//  DevAgent2
//
//  Created by Jonathan Engelsma on 9/22/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NOTIFICATION_NAME @"GVDeviceCheckOutNotification"

@interface GVViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImage;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImage;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *checkOutHeader;
@end
