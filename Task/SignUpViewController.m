//
//  SignUpViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/24/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUp:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill out all information" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:_emailField.text options:0 range:NSMakeRange(0, [_emailField.text length])];
    
    [alert addAction:ok];

    if(_usernameField.text.length == 0 || _passwordField.text.length == 0 || _emailField.text.length == 0) {
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (regExMatches == 0) {
        [alert setTitle:@"Invalid email"];
        [alert setMessage:@"Email is not valid, please try a valid email"];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [_activityIndicator startAnimating];
        PFUser *user = [[PFUser alloc] init];
        user.username = _usernameField.text;
        user.password = _passwordField.text;
        user.email = _emailField.text;
        
        [alert setTitle:@"Unable to sign up"];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            [_activityIndicator stopAnimating];
            if (succeeded)
                [self performSegueWithIdentifier:@"SignUpToTaskList" sender:nil];
            else {
                if(error.code == 202) {
                    [alert setMessage:@"Username already existed"];
                    [self presentViewController:alert animated:YES completion:nil];
                } else if(error.code == 203) {
                    [alert setMessage:@"Email already used for different account"];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    [alert setMessage:[NSString stringWithFormat:@"%@", error]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }

}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else if (theTextField == _passwordField) {
        [_emailField becomeFirstResponder];
    }
    else if (theTextField == _emailField) {
        [theTextField resignFirstResponder];
        [self signUp:self];
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
