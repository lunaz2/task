//
//  EditTaskListTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskListTableViewController.h"

@interface EditTaskListTableViewController ()

@end

@implementation EditTaskListTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(_taskList != nil) {
        _editTaskListField.text = _taskList[@"title"];
    }
    else {
        _taskList = [[PFObject alloc] initWithClassName:@"TaskList"];
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

-(IBAction)saveAction:(id)sender {
    _taskList[@"username"] = [[PFUser currentUser] username];
    _taskList[@"title"] = _editTaskListField.text;
    if(_editTaskListField.text.length == 0){
        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error"
            message:@"Empty title"
            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"typed: %@",error.textFields.firstObject.text);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [error addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"Type something";
            
        }];
        [error addAction:ok];
        [self presentViewController:error animated:YES completion:nil];
    }else{
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


@end
