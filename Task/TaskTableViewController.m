//
//  TaskTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskTableViewController.h"
#import "TaskTableViewCell.h"
#import "EditTaskTableViewController.h"

@interface TaskTableViewController ()
@property NSMutableArray *tasks;
@end

@implementation TaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fetchAllObjects];
}

-(void) fetchAllObjects{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Task"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query whereKey:@"taskListId" equalTo:[_taskList valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Retrieved %lu tasks", (unsigned long)objects.count);
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _tasks = [temp mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tasks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskTableViewCell" forIndexPath:indexPath];
    
    PFObject *object = [_tasks objectAtIndex:indexPath.row];
    cell.taskTitleLabel.text = object[@"title"];
    
    NSDate *today = [NSDate date];
    NSDate *dueday = object[@"deadline"];
    NSTimeInterval secondBetween = [dueday timeIntervalSinceDate:today];
    int days = secondBetween/86400;
    cell.taskDueLabel.text = [NSString stringWithFormat:@"%d days left",days];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"taskToEditTask" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"taskToEditTask"]) {
        EditTaskTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_tasks objectAtIndex:indexPath.row];
        vc.task = object;
        vc.taskListId = [_taskList valueForKey:@"objectId"];
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        
    }
    else if([segue.identifier isEqual:@"addTask"]) {
        EditTaskTableViewController *vc = [segue destinationViewController];
        vc.taskListId = [_taskList valueForKey:@"objectId"];
    }
}

@end
