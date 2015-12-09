//
//  TaskListTableViewCell.h
//  Task
//
//  Created by Team 4 on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *taskListTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskListDueLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskListNextTaskTitle;
@property (nonatomic, weak) IBOutlet UILabel *taskListNextTaskDue;
@property (nonatomic, weak) IBOutlet UILabel *taskListNextTaskLate;
@end
