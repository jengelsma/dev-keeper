//
//  ViewController.m
//  QRCodeReader
//
//  Created by Gabriel Theodoropoulos on 27/11/13.
//  Copyright (c) 2013 Gabriel Theodoropoulos. All rights reserved.
//

#import "GVScanBarCodeViewController.h"
#import "Constants.h"
#import "GVSignatureViewController.h"
#import "GVNewDeviceTableViewController.h"

@interface GVScanBarCodeViewController ()
{
    UIView *_highlightView;
    int _scanCnt;
    PFObject *_device;
    PFObject *_checkout;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) NSString *barcode;
-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;
-(void)confirmScan:(id)barcode;

@end

@implementation GVScanBarCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.viewPreview addSubview:_highlightView];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startReading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation

- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            [_bbitemStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code..."];
        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        [_bbitemStart setTitle:@"Start!"];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    _scanCnt = 0;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    // Start video capture.
    [_captureSession startRunning];
    

    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    //[_videoPreviewLayer removeFromSuperlayer];
}


-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];

    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    [self dismissViewControllerAnimated:YES completion:nil];
    if(buttonIndex) {
        
        if(self.displayMode == CHECK_OUT_MODE) {
            [self performSegueWithIdentifier: @"signature" sender: self];
        } else {
            if(_checkout != nil) {
                PFObject *archiveLog = [PFObject objectWithClassName:@"CheckoutLog"];
                archiveLog[@"dev_id"] = _checkout[@"dev_id"];
                archiveLog[@"user_id"] = _checkout[@"user_id"];
                archiveLog[@"signature"] = _checkout[@"signature"];
                archiveLog[@"checkout_date"] = [_checkout createdAt];
                [archiveLog saveInBackground];
                // notify client agent that device is now available.
                [PFPush sendPushMessageToChannelInBackground:archiveLog[@"dev_id"] withMessage:archiveLog[@"user_id"]];
                [_checkout deleteInBackground];
            }

            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    } else {
        _isReading = YES;
        [self startReading];
    }
}

- (void)reportCheckOut:(id)barcode
{
    NSString *msg;
    if(self.displayMode == CHECK_OUT_MODE) {
        msg = [NSString stringWithFormat:@"Device %@ is already checked out.", barcode];
    } else {
        msg = [NSString stringWithFormat:@"Device %@ is currently not checked out!", barcode];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Scanned!"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    
}

- (void)reportInvalidBarCode
{
    NSString *msg = @"This is not a valid barcode!  This app only accepts barcodes generated by the DevKeeper agent!";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Barcode Scanned!"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)confirmScan:(id)barcode
{
    NSString *msg;
    if(self.displayMode == CHECK_OUT_MODE) {
        msg= [NSString stringWithFormat:@"Device %@ will be checked out by %@?", barcode,self.user[@"user_name"]];
    } else {
        msg = [NSString stringWithFormat:@"User is returning device %@?", barcode];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Scanned!"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    //CGRect highlightViewRect = CGRectMake(0, 0, 100, 100);
    AVMetadataMachineReadableCodeObject *barCodeObject;
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            barCodeObject = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObj];
            highlightViewRect = barCodeObject.bounds;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _highlightView.frame = highlightViewRect;
                [self.viewPreview bringSubviewToFront:_highlightView];
                
            });
            
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            /*
             [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
             
             
             [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
             */
            // make user hold steady on the barcode for a few seconds to make sure its the correct one.
            if(++_scanCnt > 25) {
                _isReading = NO;
                NSLog(@"scanned barcode %@",[metadataObj stringValue]);
                

                // If the audio player is not nil, then play the sound effect.
                if (_audioPlayer) {
                    [_audioPlayer play];
                }
                _scanCnt = 0;
                
                NSData *jsonData = [[metadataObj stringValue] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *e;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&e];
                
                if(e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopReading];
                        [self reportInvalidBarCode];
                    });
                    return;
                    
                }
                self.os = dict[@"os"];
                self.formFactor = dict[@"form_factor"];
                self.desc = dict[@"model"];
                self.barcode = dict[@"id"];
                
                if(self.displayMode == CHECK_OUT_MODE) {
                    // Check if a record already exists.  If not, we need to create one.
                    PFQuery *query = [PFQuery queryWithClassName:@"Devices"];
                    [query whereKey:@"device_id" equalTo:self.barcode];
                    NSArray *objects = [query findObjects];
                    if(objects.count == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopReading];
                            [self performSegueWithIdentifier: @"newdevice" sender: self];
                        });
                    } else {
                        // check if device is already checked out.
                        _device = objects[0];
                        PFQuery *query = [PFQuery queryWithClassName:@"DevOut"];
                        [query whereKey:@"dev_id" equalTo:self.barcode];
                        NSArray *checkouts = [query findObjects];
                        if(checkouts.count == 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self stopReading];
                                [self confirmScan:self.barcode];
                            });
                        } else {
                            // alert that this device is already checked out.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self stopReading];
                                [self reportCheckOut:self.barcode];
                            });
                            
                        }
                    }
                } else {
                    // check if device is already checked out.
                    PFQuery *query = [PFQuery queryWithClassName:@"DevOut"];
                    [query whereKey:@"dev_id" equalTo:self.barcode];
                    NSArray *checkouts = [query findObjects];
                    if(checkouts.count > 0) {
                        _checkout = checkouts[0];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopReading];
                            [self confirmScan:self.barcode];
                        });
                    } else {
                        // alert that this device is already checked out.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopReading];
                            [self reportCheckOut:self.barcode];
                        });
                    }

                }
                
            }
        }
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"signature"]) {
        GVSignatureViewController *destCtrl = segue.destinationViewController;
        destCtrl.user = self.user;
        destCtrl.deviceId = self.barcode;
        destCtrl.device = _device;
    } else     if([segue.identifier isEqualToString:@"newdevice"]) {
        GVNewDeviceTableViewController *destCtrl = segue.destinationViewController;
        destCtrl.barcode = self.barcode;
        destCtrl.user = self.user;
        destCtrl.form = self.formFactor;
        destCtrl.os = self.os;
        destCtrl.desc = self.desc;
    }
}


- (IBAction)cancelScan:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
