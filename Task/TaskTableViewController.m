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
@property NSMutableArray *allTasks;
@property UIImage *checkImage;
@property UIImage *uncheckImage;
@end

@implementation TaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _checkImage = [UIImage imageNamed:@"checked_checkbox.png"];
    _uncheckImage = [UIImage imageNamed:@"unchecked_checkbox.png"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fetchAllObjects];
}

-(void) fetchAllObjects{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Task"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query whereKey:@"taskListId" equalTo:[_taskList valueForKey:@"objectId"]];
    [query orderByAscending:@"completed"];
    [query addAscendingOrder:@"deadline"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _tasks = [temp mutableCopy];
            _allTasks = [temp mutableCopy];
            
            _taskList[@"totalTask"] = [NSNumber numberWithInt:[_tasks count]];
            int completed = 0;
            for(PFObject *task in _tasks) {
                if([task[@"completed"] boolValue])
                    completed++;
            }
            _taskList[@"completed"] = [NSNumber numberWithInt:completed];
            [_taskList saveInBackground];
            
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

- (IBAction)filterTasksByCompleted {
    _tasks = [_allTasks mutableCopy];
    for (int i = 0; i<[_tasks count]; i++){
        PFObject *object = [_tasks objectAtIndex:i];
        if(![[object valueForKey:@"completed"] boolValue]){
            [_tasks removeObject:object];
            i--;
        }
    }
    [self.tableView reloadData];
}

- (IBAction)filterTasksByRecurring {
    _tasks = [_allTasks mutableCopy];
    for (int i = 0; i<[_tasks count]; i++){
        PFObject *object = [_tasks objectAtIndex:i];
        if(![[object valueForKey:@"isRecurring"] boolValue]){
            [_tasks removeObject:object];
            i--;
        }
    }
    [self.tableView reloadData];
}

- (IBAction)filterTasksByInProgress {
    _tasks = [_allTasks mutableCopy];
    for (int i = 0; i<[_tasks count]; i++){
        PFObject *object = [_tasks objectAtIndex:i];
        if([[object valueForKey:@"completed"] boolValue]){
            [_tasks removeObject:object];
            i--;
        }
    }
    [self.tableView reloadData];
}

- (IBAction)filterTasksByLate {
    _tasks = [_allTasks mutableCopy];
    for (int i = 0; i<[_tasks count]; i++){
        PFObject *object = [_tasks objectAtIndex:i];
        if(![[object valueForKey:@"completed"] boolValue]){
            NSDate *today = [NSDate date];
            NSDate *dueday = object[@"deadline"];
            NSTimeInterval secondBetween = [dueday timeIntervalSinceDate:today];
            if(secondBetween >= 0){
                [_tasks removeObject:object];
                i--;
            }
            
        }else{
            [_tasks removeObject:object];
            i--;
        }
    }
    [self.tableView reloadData];
}
- (IBAction)showAllTasks {
    _tasks = _allTasks;
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskTableViewCell" forIndexPath:indexPath];
    
    PFObject *object = [_tasks objectAtIndex:indexPath.row];
    
    cell.taskTitleLabel.text = object[@"title"];
    
    if(![[object valueForKey:@"completed"] boolValue]) {
        cell.checkView.hidden = YES;
        cell.taskDueLabel.hidden = NO;
        NSDate *today = [NSDate date];
        NSDate *dueday = object[@"deadline"];
        NSTimeInterval secondBetween = [dueday timeIntervalSinceDate:today];
        if(secondBetween < 0){
            cell.taskDueLabel.text = @"Late!";
            cell.taskDueLabel.textColor = [UIColor redColor];
        }
        else if(secondBetween >= 86400) {
            int days = secondBetween/86400;
            cell.taskDueLabel.text = [NSString stringWithFormat:@"%d days left",days];
            cell.taskDueLabel.textColor = [UIColor blackColor];
        }
        else if(secondBetween < 86400 && secondBetween >= 3600) {
            int hours = secondBetween/3600;
            cell.taskDueLabel.text = [NSString stringWithFormat:@"%d hours left",hours];
            cell.taskDueLabel.textColor = [UIColor blackColor];
        }
        else if(secondBetween < 3600) {
            int minutes = secondBetween/60;
            cell.taskDueLabel.text = [NSString stringWithFormat:@"%d minutes left",minutes];
            cell.taskDueLabel.textColor = [UIColor blackColor];
        }
    }
    else {
        cell.checkView.hidden = NO;
        cell.taskDueLabel.hidden = YES;
    }
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"taskToEditTask" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [_tasks objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error) {
                
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        [_tasks removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
