//
//  TaskListTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskListTableViewController.h"
#import "TaskListTableViewCell.h"
#import "EditTaskListTableViewController.h"
#import "TaskTableViewController.h"

@interface TaskListTableViewController ()
@property NSMutableArray *taskList;
@end

@implementation TaskListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loginSetup];
}

-(void) fetchAllObjects{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"TaskList"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Retrieved %lu objects", (unsigned long)objects.count);
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _taskList = [temp mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    [self loginSetup];
}

-(void) loginSetup {
    if(PFUser.currentUser == nil) {
        PFLogInViewController* logInViewController = [[PFLogInViewController alloc] init];
        PFSignUpViewController* signUpViewController = [[PFSignUpViewController alloc] init];
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsDismissButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsSignUpButton;
        
        UILabel *logInTitle = [[UILabel alloc] init];
        logInTitle.text = @"Task Management";
        logInViewController.logInView.logo = logInTitle;
        logInViewController.delegate = self;
        
        UILabel *signUpTitle = [[UILabel alloc] init];
        signUpTitle.text = @"Task Management";
        signUpViewController.signUpView.logo = signUpTitle;
        signUpViewController.delegate = self;
        
        logInViewController.signUpController = signUpViewController;
        [self presentViewController:logInViewController animated:true completion:nil];
    } else {
        [self fetchAllObjects];
    }
}

#pragma mark - Log In Delegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password {
    if(username && password && username.length != 0 && password.length !=0)
        return true;
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Fill out all information" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    return false;
    
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sign Up Delegate

-(BOOL) signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for(id key in info) {
        NSString *field = [info objectForKey:key];
        if(!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if(!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Fill out all information" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController
    didFailToSignUpWithError:(PFUI_NULLABLE NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"Cancel sign up...");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListTableViewCell" forIndexPath:indexPath];
    
    PFObject *object = [_taskList objectAtIndex:indexPath.row];
    cell.taskListTitleLabel.text = object[@"title"];
    cell.taskListDueLabel.text = @"";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"taskListToTask" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"taskListToTask"]) {
        TaskTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        vc.taskList = object;
        NSLog(@"TaskList object sent: %@", object);
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    else if([segue.identifier  isEqual: @"editTaskList"]) {
        EditTaskListTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        vc.taskList = object;
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        
    }
}
@end
