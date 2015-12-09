//
//  EditTaskListTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskListTableViewController.h"

@interface EditTaskListTableViewController ()
@property NSArray *pickerData;
@end

@implementation EditTaskListTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _pickerData = @[@"Custom",@"Family",@"Friends",@"School",@"Work",@"Birthdays",@"Holidays"];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_bg@2x.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    if(_taskList != nil) {
        _editTaskListField.text = _taskList[@"title"];
        self.title = _taskList[@"title"];
    }
    else {
        _taskList = [[PFObject alloc] initWithClassName:@"TaskList"];
        self.title = @"New Task List";
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

-(IBAction)saveAction:(id)sender {
    if(_editTaskListField.text.length == 0){
        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Empty Title"
            message:@"Please type in the title for the task list"
            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            _editTaskListField.text = error.textFields.firstObject.text;
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [error addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"Type something";
            
        }];
        [error addAction:ok];
        [self presentViewController:error animated:YES completion:nil];
    }else{
        _taskList[@"username"] = [[PFUser currentUser] username];
        _taskList[@"title"] = _editTaskListField.text;
        [_taskList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row != 0){
        _editTaskListField.text = _pickerData[row];
    }else{
        _editTaskListField.text = @"";
    }
}
@end
