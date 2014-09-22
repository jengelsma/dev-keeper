//
//  GVDashboardViewController.h
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/12/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVDashboardViewController : UIViewController <UIAlertViewDelegate>
- (IBAction)unwindToSaveCheckin:(UIStoryboardSegue *)unwindSegue;
- (IBAction)unwindCancelCheckin:(UIStoryboardSegue *)unwindSegue;
@end
