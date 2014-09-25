//
//  ViewController.h
//  QRCodeReader
//
//  Created by Gabriel Theodoropoulos on 27/11/13.
//  Copyright (c) 2013 Gabriel Theodoropoulos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>

#define CHECK_IN_MODE 0
#define CHECK_OUT_MODE 1

@interface GVScanBarCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) PFObject *user;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSString *formFactor;
@property (strong, nonatomic) NSString *desc;

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (assign,nonatomic) int displayMode;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;

- (IBAction)startStopReading:(id)sender;


@end
