//
//  EditNoteTableViewController.h
//  Task
//
//  Created by Ryan on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditNoteTableViewController : UITableViewController
@property PFObject *note;
@property PFObject *task;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteContent;
@end