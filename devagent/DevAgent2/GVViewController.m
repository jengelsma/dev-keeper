//
//  GVViewController.m
//  DevAgent2
//
//  Created by Jonathan Engelsma on 9/22/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVViewController.h"
#import "GVHTTPCommunication.h"

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
    _deviceId = [self retrieveDeviceId];
    self.idLabel.text = _deviceId;
    
    _http = [[GVHTTPCommunication alloc] init];
    NSString *ustr = [NSString stringWithFormat:@"{\"id\" : \"%@\",\"man\" : \"%@\",\"model\" : \"%@\"}",_deviceId, @"Apple", [UIDevice currentDevice].model];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)ustr,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8 ));
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",CHART_URL,encodedString]];
    
    [_http retrieveURL:url successBlock:^(NSData *response) {
        
        UIImage *bc = [UIImage imageWithData:response];
        if(bc) {
            self.barcodeImage.image = bc;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) retrieveDeviceId
{
    NSString *deviceId = nil;
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"youruniquestring" create:NO];
    //NSLog([pasteboard string]);
    if(pasteboard != nil) {
        deviceId = [pasteboard string];
        NSLog(@"unique device ID = %@", deviceId);
    } else {
        
        //Create a unique id as a string
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        
        //create a new pasteboard with a unique identifier
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"youruniquestring" create:YES];
        
        [pasteboard setPersistent:YES];
        
        //save the unique identifier string that we created earlier
        deviceId = ((__bridge NSString*)string);
        [pasteboard setString:deviceId];
        
        NSLog(@"newly generated device ID = %@", deviceId);
        
    }
    return deviceId;
}

@end
