//
//  GVMasterViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/3/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import <Parse/Parse.h>
#import "GVMasterViewController.h"
#import "GVDetailViewController.h"
#import "GVDressedUpTableViewCell.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface GVMasterViewController () {
    NSArray *_objects;
}
@end

@implementation GVMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-iPhone6.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 85;
    
    /*
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
     //UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystem target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     */
    self.detailViewController = (GVDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCheckouts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCheckouts
{
    PFQuery *query = [PFQuery queryWithClassName:@"DevOut"];
    [query includeKey:@"device_obj"];
    [query includeKey:@"user_obj"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
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

- (IBAction)refreshTable:(id)sender {
    [self loadCheckouts];
    [sender endRefreshing];
}

- (void)insertNewObject:(id)sender
{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    GVDressedUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    PFObject *object = _objects[indexPath.row];
    PFObject *device = object[@"device_obj"];
    PFObject *user = object[@"user_obj"];
    
    
    cell.titleLabel.text = user[@"user_name"];
    cell.detailLabel.text = device[@"name"];
    
    // make thumbnails circular
    cell.thumbnail.layer.cornerRadius = 27;
    
    PFFile *userImageFile = user[@"user_photo"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.thumbnail.image = image;
            
        }
    }];
    
    NSDate* checkoutDate = object.createdAt;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"Out on %@",[dateFormatter stringFromDate:checkoutDate]];
    
 /*
    cell.textLabel.text = user[@"user_name"];
    cell.detailTextLabel.text = device[@"name"];
    
    PFFile *userImageFile = user[@"user_photo"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.imageView.image = image;
        }
    }];


    UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowCellBG2"]];
    cell.backgroundView = cellBg;
*/
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
