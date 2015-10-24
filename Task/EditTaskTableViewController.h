//
//  EditTaskTableViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>

@interface EditTaskTableViewController : UITableViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate>{
    BOOL checked;
}

@property (weak, nonatomic) IBOutlet UITextField *editTaskTitleField;
@property (weak, nonatomic) IBOutlet UITextView *editTaskDescTextView;
@property (weak, nonatomic) IBOutlet UITextField *editTaskDueField;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UISlider *repeatingSlider;
@property (weak, nonatomic) IBOutlet UILabel *repeatingSliderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *repeatingSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *repeatingUnit;

@property PFObject *task;
@property NSString *taskListId;
-(IBAction)setRecurring:(id)sender;
@end
