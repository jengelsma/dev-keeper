//
//  GVHTTPCommunication.m
//  TopTracksDemo
//
//  Created by Jonathan Engelsma on 7/17/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVHTTPCommunication.h"
#import "GVAppDelegate.h"

@interface GVHTTPCommunication()
@property (nonatomic,copy) void (^successBlock)(NSData*);
@end

@implementation GVHTTPCommunication

-(void) retrieveURL:(NSURL *)url successBlock:(void (^) (NSData*))successBlk
{
    [(GVAppDelegate*)[[UIApplication sharedApplication] delegate] incrementNetworkActivity];
    self.successBlock = successBlk;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

-(void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    dispatch_async(dispatch_get_main_queue(), ^{
        [(GVAppDelegate*)[[UIApplication sharedApplication] delegate] decrementNetworkActivity];
        self.successBlock(data);
    });
}

@end
