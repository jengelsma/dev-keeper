//
//  GVNewDeviceTableViewController.m
//  iDevCheckout
//
//  Created by Jonathan Engelsma on 9/17/14.
//  Copyright (c) 2014 Jonathan Engelsma. All rights reserved.
//

#import "GVNewDeviceTableViewController.h"
#import "GVSignatureViewController.h"

#define kFormPickerIndex 4
#define kOsPickerIndex 6
#define kPickerCellHeight 82

@interface GVNewDeviceTableViewController ()
{
    NSArray *_formPickerData;
    NSArray *_osPickerData;
    PFObject *_device;
}
@property (assign) BOOL formPickerIsShowing;
@property (assign) BOOL osPickerIsShowing;
@property (strong, nonatomic) UITextField *activeTextField;
@end

@implementation GVNewDeviceTableViewController

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
    
    _formPickerData = [NSArray arrayWithObjects:@"Phone", @"Tablet", nil];
    _osPickerData = [NSArray arrayWithObjects:@"Apple", @"Android", nil];
    
    self.deviceId.text = [NSString stringWithFormat:@"Device ID: %@", self.barcode];
    self.deviceName.delegate = self;
    self.osPickerLabel.text = self.os;
    self.formFactor.text = self.form;
    self.deviceName.text = self.desc;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [self hideFormPickerCells];
    self.formFactorPicker.delegate = self;
    self.formFactorPicker.dataSource = self;
    self.osPicker.delegate = self;
    self.osPicker.dataSource = self;
    [self resizePickerHeight:self.formFactorPicker];
    [self resizePickerHeight:self.osPicker];
    
}

-(void)resizePickerHeight:(UIPickerView*)picker
{
    // interface builder doesn't let you change height of the UIPickerView so we do it here manually
    CGAffineTransform t0 = CGAffineTransformMakeTranslation (0, picker.bounds.size.height/2);
    CGAffineTransform s0 = CGAffineTransformMakeScale       (1.0, 0.5);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation (0, -picker.bounds.size.height/2);
    picker.transform = CGAffineTransformConcat          (t0, CGAffineTransformConcat(s0, t1));
}

- (void)keyboardWillShow {
    
    if (self.formPickerIsShowing || self.osPickerIsShowing){
        
        [self hideFormPickerCells];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerView delegate & data source methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(!self.formPickerIsShowing) {
        return _formPickerData.count;
    } else {
        return _osPickerData.count;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(self.formPickerIsShowing) {
        return _formPickerData[row];
    } else {
        return _osPickerData[row];
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == self.formFactorPicker) {
        self.formFactor.text = _formPickerData[row];
    } else if(pickerView == self.osPicker) {
        self.osPickerLabel.text = _osPickerData[row];
    }
}


#pragma mark - Table view methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.tableView.rowHeight;
    
    if (indexPath.row == kFormPickerIndex) {
        
        height = self.formPickerIsShowing ? kPickerCellHeight : 0.0f;
        
    } else if (indexPath.row == kOsPickerIndex) {
        
        height = self.osPickerIsShowing ? kPickerCellHeight : 0.0f;
        
    } else if(indexPath.row == 0) {
        height = 120;
    }
    
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 3){
        
        if (self.formPickerIsShowing || self.osPickerIsShowing){
            
            [self hideFormPickerCells];
            
        }else {

            [self.activeTextField resignFirstResponder];
            self.formPickerIsShowing = YES;
            [self showPickerCell:self.formFactorPicker];
        }
    } else if(indexPath.row == 5) {
        if (self.formPickerIsShowing || self.osPickerIsShowing){
            
            [self hideFormPickerCells];
            
        }else {
            [self.activeTextField resignFirstResponder];
            self.osPickerIsShowing = YES;
            [self showPickerCell:self.osPicker];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)showPickerCell:(UIPickerView*)picker {
    
    
    [self.tableView beginUpdates];
    
    [self.tableView endUpdates];
    
    picker.hidden = NO;
    picker.alpha = 0.0f;
    [picker reloadAllComponents];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        picker.alpha = 1.0f;
        
    }];
}

- (void)hideFormPickerCells {
    
    self.formPickerIsShowing = NO;
    self.osPickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.formFactorPicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.formFactorPicker.hidden = YES;
                         self.osPicker.hidden = YES;
                     }];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.activeTextField = textField;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.activeTextField resignFirstResponder];
    return YES;
}
- (IBAction)saveButtonPressed:(id)sender {
    _device = [PFObject objectWithClassName:@"Devices"];
    _device[@"device_id"] = self.barcode;
    _device[@"name"] = self.deviceName.text;
    _device[@"os"] = self.osPickerLabel.text;
    _device[@"type"] = self.formFactor.text;
    
    [_device saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        [self performSegueWithIdentifier: @"signature" sender: self];
    }];
    
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"signature"]) {
        GVSignatureViewController *destCtrl = segue.destinationViewController;
        destCtrl.user = self.user;
        destCtrl.deviceId = self.barcode;
        destCtrl.device = _device;
    }
}


@end
