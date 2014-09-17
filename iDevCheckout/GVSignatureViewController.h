//
//  GVSignatureViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/13/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GVSignatureViewController : UIViewController
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
}
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) PFObject *user;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) PFObject *device;

@end
