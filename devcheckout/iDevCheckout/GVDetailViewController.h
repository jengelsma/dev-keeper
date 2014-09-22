//
//  GVDetailViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/3/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *deviceId;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (weak, nonatomic) IBOutlet UILabel *checkoutDate;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImage;
@end
