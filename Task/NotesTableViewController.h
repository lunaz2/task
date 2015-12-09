//
//  NotesTableViewController.h
//  Task
//
//  Created by Team 4 on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface NotesTableViewController : UITableViewController
@property PFObject *task;
@end
