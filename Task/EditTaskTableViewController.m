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
    
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
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
        [self showDate];
        
        
    }
    else {
        _task = [[PFObject alloc] initWithClassName:@"Task"];
    }
    
}

-(void)showDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/YYYY"];
    _editTaskDueField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:datePicker.date]];
    [_editTaskDueField resignFirstResponder];
}


-(IBAction)saveAction:(id)sender {
    
    _task[@"username"] = [[PFUser currentUser] username];
    _task[@"title"] = _editTaskTitleField.text;
    _task[@"description"] = _editTaskDescTextView.text;
    _task[@"deadline"] = datePicker.date;
    _task[@"taskListId"] = _taskListId;
    
    [_task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Information successfully saved" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
