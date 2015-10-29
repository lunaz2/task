//
//  LogInViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/24/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()
@end

@implementation LogInViewController

- (void)viewDidLoad {
    [_activityIndicator startAnimating];
    [super viewDidLoad];
    _passwordField.text = nil;
    _usernameField.text = nil;
    if([PFUser currentUser] != nil) {
        [_activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"LogInToTaskList" sender:nil];
    }
    else [_activityIndicator stopAnimating];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

- (IBAction)logIn:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill out all information" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    
    alert.popoverPresentationController.sourceView = self.view;
    
    if(_usernameField.text.length == 0 || _passwordField.text.length == 0) {
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [_activityIndicator startAnimating];
        [PFUser logInWithUsernameInBackground:_usernameField.text password:_passwordField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            [_activityIndicator stopAnimating];
            if (user != nil)
                [self performSegueWithIdentifier:@"LogInToTaskList" sender:nil];
            else {
                [alert setTitle:@"Unable to log in"];
                [alert setMessage:@"Username does not exist or wrong password"];
                [self presentViewController:alert animated:YES completion:nil];
        
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else if (theTextField == _passwordField) {
        [_passwordField resignFirstResponder];
        [self logIn:self];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
