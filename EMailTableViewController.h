//
//  EMailTableViewController.h
//  Task
//
//  Created by Quynh Nguyen on 11/28/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface EMailTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property PFObject *task;
@end
