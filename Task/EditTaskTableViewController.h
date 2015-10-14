//
//  EditTaskTableViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditTaskTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *editTaskTitleField;
@property (weak, nonatomic) IBOutlet UITextView *editTaskDescTextView;
@property (weak, nonatomic) IBOutlet UITextField *editTaskDueField;
@property PFObject *task;
@property NSString *taskListId;
@end
