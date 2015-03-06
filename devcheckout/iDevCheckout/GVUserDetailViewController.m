//
//  GVAddUserViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/10/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVUserDetailViewController.h"
#import "Constants.h"

#import <Parse/Parse.h>

@interface GVUserDetailViewController ()
@property (assign, nonatomic) BOOL newImage;
@end

@implementation GVUserDetailViewController
{
    UIImagePickerController *photoPick;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.newImage = NO;
    self.userImage.userInteractionEnabled = YES;
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTouched:)];
    self.userImage.gestureRecognizers = @[tapRecognizer];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.userImage.layer.cornerRadius = 24.0f;
        
    } else {
        self.userImage.layer.cornerRadius = 12.0f;
    }
    self.userImage.clipsToBounds = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        photoPick = [[UIImagePickerController alloc] init];
        photoPick.modalPresentationStyle = UIModalPresentationCurrentContext;
        photoPick.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        photoPick.delegate = self;
        photoPick.showsCameraControls = YES;
        photoPick.allowsEditing = YES;
    } else {
        photoPick = nil;
    }
    self.userEmail.delegate = self;
    self.userName.delegate = self;
    
    // if a model was provided, populate fields.
    if(self.user != nil) {
        self.userName.text = self.user[@"user_name"];
        self.userEmail.text = self.user[@"user_id"];
        PFFile *userImageFile = self.user[@"user_photo"];
        if(userImageFile) {
            self.userImage.file = userImageFile;
            [self.userImage loadInBackground];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == self.userName) {
        [self.userEmail becomeFirstResponder];
    }

    return YES;
}

#pragma mark - UIPickerViewControllerDelegate
- (void)photoTouched:(UITapGestureRecognizer *)gesture
{
    if (photoPick)
    {
        CGRect origRect = self.userImage.bounds;
        [UIView animateWithDuration:0.5 animations:^{
            self.userImage.bounds = CGRectZero;
        } completion:^(BOOL flag) {
            /* must restore the bounds to the original rectangle */
            self.userImage.bounds = origRect;
        }];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self.splitViewController presentViewController:photoPick animated:YES completion:nil];
        } else {
            [self presentViewController:photoPick animated:YES completion:nil];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /* The size of OriginalImage seems to be camera pixel size (1936x2592 on iPod Touch)
     * The size of EditedImage is 640x640 on iPod Touch
     * CropRect is {-1,48}, {1937,1937} on iPodTouch
     */
    //    UIImage *origImage = info[UIImagePickerControllerOriginalImage];
    //    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    UIImage *capturedPhoto = info[UIImagePickerControllerEditedImage];
    self.userImage.image = capturedPhoto;
    self.newImage = YES;
/*
#ifdef DEBUG
    NSLog(@"%s updating photo of %@ %@ (%.0fx%.0f)", __FUNCTION__,
          self.detailItem.firstName, self.detailItem.lastName,
          capturedPhoto.size.width, capturedPhoto.size.height);
#endif

    [JSONUtil postImageWithData:UIImageJPEGRepresentation(capturedPhoto, 1.0)
                            for:self.detailItem.uic
                   onCompletion:^(int status, NSData *resp){
                       UIAlertView *av = nil;
                       switch (status) {
                           case 200:
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshMasterTable"
                                                                                   object:self
                                                                                 userInfo:@{@"photo" : self.detailItem}];
                               av = [[UIAlertView alloc] initWithTitle:@"Image Update"
                                                               message:[NSString stringWithFormat:@"%@ %@'s photo updated", self.detailItem.firstName, self.detailItem.lastName]
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil];
                               break;
                           case 401:
                               av = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                               message:@"Your Authorization token has expired. Please signout and relogin"
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil];
                               break;
                           default:
                               [self showNetworkErrorWithMessage:@"Unable to save new student image"];
                               break;
                       }
                       if (av)
                           [av show];
                       
                   }
                        onError:^(NSError *err){
#ifdef DEBUG
                            NSLog(@"Image post error is %@", [err localizedDescription]);
#endif
                            [self showNetworkErrorWithMessage:@"Unable to save new student image"];
                        }];
           */
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)cancelAddUser:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveUser:(id)sender {
    
    if(self.user != nil) {
        self.user[@"user_id"] = self.userEmail.text;
        self.user[@"user_name"] = self.userName.text;
        if(self.newImage) {
            NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg" , self.userName.text];
            NSData *imageData = UIImageJPEGRepresentation(self.userImage.image, 0.05f);
            PFFile *file = [PFFile fileWithName:imageFileName data:imageData];
            [file saveInBackground];
            self.user[@"user_photo"] = file;
        }
        [self.user saveInBackground];
    } else {
        
        // this is a brand new user!  Make sure we don't already have that email address out there.
        PFQuery *query = [PFQuery queryWithClassName:USER_TABLE];
        [query whereKey:@"user_id" equalTo:self.userEmail.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                if(objects.count == 0) {
                    PFObject *newUser = [PFObject objectWithClassName:USER_TABLE];
                    if(self.newImage) {
                        NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg" , self.userName.text];
                        NSData *imageData = UIImageJPEGRepresentation(self.userImage.image, 0.05f);
                        PFFile *file = [PFFile fileWithName:imageFileName data:imageData];
                        [file saveInBackground];
                        newUser[@"user_photo"] = file;
                    }
                    newUser[@"user_id"] = self.userEmail.text;
                    newUser[@"user_name"] = self.userName.text;
                    
                    [newUser saveInBackground];
                } else {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Duplicate Email Address"
                                                                 message:@"A user with that email address already exists!"
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"OK", nil];
                    [av show];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Could not save!"
                                                             message:@"Unable to save user detail.  Check your network connection and try again."
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil];
                [av show];
            }
        }];
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
