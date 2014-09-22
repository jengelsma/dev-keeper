//
//  GVUserTableViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/8/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#define USER_EDIT_MODE 0
#define USER_SELECT_MODE 1
@interface GVUserTableViewController : PFQueryTableViewController
@property (assign,nonatomic) int displayMode;
@end
