//
//  TaskTableViewController.h
//  Task
//
//  Created by Team 4 on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TaskTableViewController : UITableViewController
@property PFObject *taskList;
@end
