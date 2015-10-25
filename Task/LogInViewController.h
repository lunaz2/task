//
//  LogInViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/24/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface LogInViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
