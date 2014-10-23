//
//  GVDressedUpTableViewCell.m
//  DevKeeper
//
//  Created by Jonathan Engelsma on 10/23/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVDressedUpTableViewCell.h"

@implementation GVDressedUpTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowCellBG2"]];
    self.backgroundView = cellBg;
    self.thumbnail.layer.cornerRadius = 8.0f;
    self.thumbnail.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
