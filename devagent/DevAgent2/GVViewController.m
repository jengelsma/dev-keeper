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
- (IBAction)pushTestMessage:(id)sender {
    
    [PFPush sendPushMessageToChannelInBackground:_deviceId withMessage:@"Hello World!"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
