//
//  EditTaskTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskTableViewController.h"

@interface EditTaskTableViewController ()
@property UIDatePicker *datePicker;
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
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Information successfully saved" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
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
