//
//  GVUserTableViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/8/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <Parse/Parse.h>
#import "GVUserTableViewController.h"
#import "GVUserDetailViewController.h"
#import "GVScanBarCodeViewController.h"
#import "GVDressedUpTableViewCell.h"

@interface GVUserTableViewController ()
{
//    NSArray *_objects;
    NSIndexPath* lastSelectedIndexPath;
}
@end

@implementation GVUserTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Users";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"user_name";
        
        self.placeholderImage = [UIImage imageNamed:@"userImage"];
        
        self.imageKey = @"user_photo";
        
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
    
    [query orderByDescending:@"user_name"];
    
    return query;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    lastSelectedIndexPath = nil;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-iPhone6.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 85;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // The title for this table in the Navigation Controller.
    self.title = (self.displayMode == USER_SELECT_MODE) ? @"Select A User" : @"Users";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void) loadUserData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d users.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            _objects = objects;
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)refreshUsers:(UIRefreshControl *)sender {
    [self loadUserData];
    [sender endRefreshing];
}
*/

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  _objects.count;
}
*/
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GVDressedUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.titleLabel.text = object[@"user_name"];
    cell.detailLabel.text = object[@"user_id"];
    cell.dateLabel.text = [object.createdAt description];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"User created on %@",[dateFormatter stringFromDate:object.createdAt]];
//    if(self.displayMode == USER_SELECT_MODE) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    PFFile *userImageFile = object[@"user_photo"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.thumbnail.image = image;
            cell.thumbnail.layer.cornerRadius = 27.0f;
            cell.thumbnail.clipsToBounds = YES;
            //cell.thumbnail.frame = CGRectMake(cell.thumbnail.frame.origin.x, cell.thumbnail.frame.origin.y+15, 40,40);
        }
    }];
    UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBg"]];
    cell.backgroundView = cellBg;
    return cell;

    /*
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //PFObject *object = _objects[indexPath.row];
    cell.textLabel.text = object[@"user_name"];
    if(self.displayMode == USER_EDIT_MODE) {
        cell.detailTextLabel.text = object[@"user_id"];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    PFFile *userImageFile = object[@"user_photo"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.imageView.image = image;
            cell.imageView.layer.cornerRadius = 8.0f;
            cell.imageView.clipsToBounds = YES;
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y+15, 40,40);
        }
    }];
    UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBg"]];
    cell.backgroundView = cellBg;
    return cell;
*/

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.displayMode == USER_SELECT_MODE) {
        if(lastSelectedIndexPath) {
            
            UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
            lastCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        
        lastSelectedIndexPath = indexPath;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PFObject *object = nil;
    if(self.displayMode == USER_EDIT_MODE) {

        GVUserDetailViewController *destCtrl = [segue destinationViewController];
        
        // if we are editing an existing user, set the model.
        if(![sender isKindOfClass:[UIBarButtonItem class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            //object = _objects[indexPath.row];
            object = self.objects[indexPath.row];
        }
        destCtrl.user = object;
    } else {
        GVScanBarCodeViewController *destCtrl = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        object = self.objects[indexPath.row];
        destCtrl.user = object;
        destCtrl.displayMode = CHECK_OUT_MODE;
    }
}

#pragma mark - Cancel / Save Buttons for User Select Mode
- (IBAction)cancelUserSelect:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
