//
//  EditTaskTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskTableViewController.h"
#import "TaskPhotoViewController.h"

@interface EditTaskTableViewController ()
@property UIDatePicker *datePicker;
@property UITapGestureRecognizer* tap;
@property UIImage *image;
@end

@implementation EditTaskTableViewController
@synthesize datePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    checked = NO;
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [_editTaskDueField setInputView:datePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(showDate)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:space,doneBtn,nil]];
    [_editTaskDueField setInputAccessoryView:toolbar];
    
    if(_task != nil) {
        _editTaskTitleField.text = _task[@"title"];
        _editTaskDescTextView.text = _task[@"description"];
        [datePicker setDate:_task[@"deadline"]];
        [self showDate];
        checked = [[_task objectForKey:@"completed"] boolValue];
    }
    else {
        _task = [[PFObject alloc] initWithClassName:@"Task"];
    }

    if(checked)
        [_completeButton setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
    else [_completeButton setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    _tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tap];
    
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)shareTask:(id)sender {
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        [mail setSubject:_task[@"title"]];
        [mail setMessageBody:_task[@"description"] isHTML:false];
        [self presentViewController:mail animated:true completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No email found on device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)addImage:(id)sender {
    [self performSegueWithIdentifier:@"editTaskToTaskPhoto" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TaskPhotoViewController *vc = [segue destinationViewController];
    vc.task = _task;
}



-(void)showDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/YYYY hh:mm a"];
    _editTaskDueField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:datePicker.date]];
    [_editTaskDueField resignFirstResponder];
}


-(IBAction)saveAction:(id)sender {
    
    _task[@"username"] = [[PFUser currentUser] username];
    _task[@"title"] = _editTaskTitleField.text;
    _task[@"description"] = _editTaskDescTextView.text;
    _task[@"deadline"] = datePicker.date;
    _task[@"taskListId"] = _taskListId;
    _task[@"completed"] = [NSNumber numberWithBool:checked];

    [_task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[self navigationController] popViewControllerAnimated:YES];
    
}
- (IBAction)completeBtn:(id)sender {
    if(!checked) {
        [_completeButton setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
        checked = YES;
    }
    else {
        [_completeButton setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
        checked = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
