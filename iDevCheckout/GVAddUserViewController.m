//
//  GVAddUserViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/10/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVAddUserViewController.h"
#import "Constants.h"

#import <Parse/Parse.h>

@interface GVAddUserViewController ()

@end

@implementation GVAddUserViewController
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
        [UIView animateWithDuration:0.5 animations:^{
            self.userImage.bounds = CGRectZero;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveUser:(id)sender {
    [self.userEmail resignFirstResponder];
    [self.userName resignFirstResponder];
     
    PFQuery *query = [PFQuery queryWithClassName:USER_TABLE];
    [query whereKey:@"user_id" equalTo:self.userEmail.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            if(objects.count == 0) {
                NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg" , self.userName.text];
                NSData *imageData = UIImageJPEGRepresentation(self.userImage.image, 0.05f);
                PFFile *file = [PFFile fileWithName:imageFileName data:imageData];
                [file saveInBackground];
                PFObject *newUser = [PFObject objectWithClassName:USER_TABLE];
                newUser[@"user_id"] = self.userEmail.text;
                newUser[@"user_name"] = self.userName.text;
                newUser[@"user_photo"] = file;
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
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Duplicate Email Address"
                                                          message:@"A user with that email address already exists!"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
            [av show];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
