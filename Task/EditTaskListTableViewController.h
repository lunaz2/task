//
//  EditTaskListTableViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditTaskListTableViewController : UITableViewController <UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *editTaskListField;
@property PFObject *taskList;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end
