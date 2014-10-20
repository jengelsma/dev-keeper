//
//  GVViewController.m
//  DevAgent2
//
//  Created by Jonathan Engelsma on 9/22/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVViewController.h"
#import "GVHTTPCommunication.h"
#import "GVAppDelegate.h"
#import <Parse/Parse.h>

#define CHART_URL @"http://chart.apis.google.com/chart?cht=qr&chld=L&choe=UTF-8&chs=400x400&chl="

@interface GVViewController ()
{
    GVHTTPCommunication *_http;
    NSString *_deviceId;
}

@end

@implementation GVViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register for server side notifications of checkout events
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationWithString:)
     name:NOTIFICATION_NAME
     object:nil];

    _deviceId = [(GVAppDelegate*)[[UIApplication sharedApplication] delegate] retrieveDeviceId];
    self.idLabel.text = _deviceId;
    
    _http = [[GVHTTPCommunication alloc] init];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *form;
    if([model hasPrefix:@"iPhone"] || [model hasPrefix:@"iPod"]) {
        form = @"Phone";
    } else {
        form = @"Tablet";
    }
    
    NSString *ustr = [NSString stringWithFormat:@"{\"id\" : \"%@\",\"model\" : \"%@\",\"os\" : \"%@\",\"form_factor\" : \"%@\"}",_deviceId, model, @"Apple", form];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)ustr,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
    
                                                                                                    kCFStringEncodingUTF8 ));
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",CHART_URL,encodedString];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [_http retrieveURL:url successBlock:^(NSData *response) {
        
        UIImage *bc = [UIImage imageWithData:response];
        if(bc) {
            self.barcodeImage.image = bc;
        }
    }];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getCheckoutRecord];
    // query for checkup message here.
    
}

- (void) updateViewPerCheckoutStatus:(BOOL)status
{
    //self.view.backgroundColor = status ? [UIColor redColor] : [UIColor greenColor];
    self.status.text = status ? @"Status: Checked Out" : @"Status: Available";
    self.userThumbnail.hidden = !status;
    self.signatureImage.hidden = !status;
    self.userId.hidden = !status;
    self.userName.hidden = !status;
    self.checkOutHeader.hidden = !status;
}

- (void)getCheckoutRecord
{
    PFQuery *query = [PFQuery queryWithClassName:@"DevOut"];
    [query whereKey:@"dev_id" equalTo:_deviceId];
    [query includeKey:@"device_obj"];
    [query includeKey:@"user_obj"];
    NSArray *checkouts = [query findObjects];
    if(checkouts.count == 1) {
        PFObject *checkout = checkouts[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            PFObject *user = checkout[@"user_obj"];
            self.userName.text = user[@"user_name"];
            self.userId.text = user[@"user_id"];
            PFFile *userImageFile = user[@"user_photo"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.userThumbnail.image = image;
                }
            }];
            PFFile *signatureFile = checkout[@"signature"];
            [signatureFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.signatureImage.image = image;
                } else {
                    self.signatureImage.image = nil;
                }
            }];
            
            
        });
    }
    
    // whether we had a checkout or not, we need to make sure the screen config
    // is correct.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewPerCheckoutStatus:(checkouts.count == 1)];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)refreshView:(id)sender {
        [self getCheckoutRecord];
}

- (void)useNotificationWithString:(NSString *)str
{
    NSLog(@"your message is: %@", str);
    [self getCheckoutRecord];
}

@end
