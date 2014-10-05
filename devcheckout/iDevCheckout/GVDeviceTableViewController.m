//
//  GVDeviceTableViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/12/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVDeviceTableViewController.h"
#import "GVDeviceDetailController.h"

@implementation GVDeviceTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Devices";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
        self.imageKey = @"device_photo";
        
        self.placeholderImage = [UIImage imageNamed:@"deviceMenu"];
        // The title for this table in the Navigation Controller.
        self.title = @"Devices";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    return self;
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createAt"];
    
    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = object[@"name"];
    cell.detailTextLabel.text = object[@"device_id"];
    cell.imageView.image = [UIImage imageNamed:@"deviceImage"];
    
    PFFile *devThumbnail = object[@"device_photo"];
    if(devThumbnail) {
        [devThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                cell.imageView.image = image;
            }
        }];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PFObject *object = nil;
    
    GVDeviceDetailController *destCtrl = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    object = self.objects[indexPath.row];
    destCtrl.device = object;
}

@end
