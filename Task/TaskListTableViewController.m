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
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation TaskListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _activityIndicator.center = self.view.center;
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.color = [UIColor grayColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_activityIndicator startAnimating];
    [self fetchAllObjects];
}

-(void) fetchAllObjects{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"TaskList"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _taskList = [temp mutableCopy];
            [_activityIndicator stopAnimating];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    [[self navigationController] popToRootViewControllerAnimated:YES];
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
    cell.taskListDueLabel.text = [NSString stringWithFormat:@"%d out of %d completed", [object[@"completed"] intValue], [object[@"totalTask"] intValue]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"taskListToTask" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error) {
                
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Task"];
        [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"taskListId" equalTo:[object valueForKey:@"objectId"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSArray *temp = [[NSArray alloc] initWithArray:objects];
                for (PFObject *task in temp) {
                    PFQuery *noteQuery = [[PFQuery alloc] initWithClassName:@"Note"];
                    [noteQuery whereKey:@"taskId" equalTo:[task valueForKey:@"objectId"]];
                    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            NSArray *temp = [[NSArray alloc] initWithArray:objects];
                            for (PFObject *note in temp) {
                                
                                [note deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if(!error) {
                                        
                                    }
                                    else {
                                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                                    }
                                }];
                            }
                        } else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    PFQuery *imageQuery = [[PFQuery alloc] initWithClassName:@"ImageData"];
                    [imageQuery whereKey:@"taskId" equalTo:[task valueForKey:@"objectId"]];
                    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            NSArray *temp = [[NSArray alloc] initWithArray:objects];
                            for (PFObject *image in temp) {
                                
                                [image deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if(!error) {
                                        
                                    }
                                    else {
                                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                                    }
                                }];
                            }
                        } else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    [task deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(!error) {
                            
                        }
                        else {
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [_taskList removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"taskListToTask"]) {
        TaskTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        vc.taskList = object;
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        vc.navigationItem.title = [object objectForKey:@"title"];
        
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
