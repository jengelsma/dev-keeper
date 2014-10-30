//
//  GVDressedUpTableViewCell.h
//  DevKeeper
//
//  Created by Jonathan Engelsma on 10/23/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Parse/Parse.h>
@interface GVDressedUpTableViewCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
