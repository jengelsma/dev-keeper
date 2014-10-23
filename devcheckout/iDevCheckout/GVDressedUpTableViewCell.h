//
//  GVDressedUpTableViewCell.h
//  DevKeeper
//
//  Created by Jonathan Engelsma on 10/23/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVDressedUpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@end
