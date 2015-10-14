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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(IBAction)saveAction:(id)sender {
    _taskList[@"username"] = [[PFUser currentUser] username];
    _taskList[@"title"] = _editTaskListField.text;
    
    [_taskList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
