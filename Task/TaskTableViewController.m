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
#import "NotesTableViewController.h"

@interface TaskTableViewController ()
@property NSMutableArray *tasks;
@property NSMutableArray *allTasks;
@property PFObject *selectedTask;
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
        if([[object valueForKey:@"completed"] boolValue] && ![[object valueForKey:@"isRecurring"] boolValue]){
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
    cell.repeatIcon.hidden = YES;
    
    bool isRecurring = [[object valueForKey:@"isRecurring"] boolValue];
    NSDate *today = [NSDate date];
    NSDate *dueday = object[@"deadline"];
    NSTimeInterval secondBetween = [dueday timeIntervalSinceDate:today];
    if(isRecurring){
        cell.repeatIcon.hidden = NO;
        if(secondBetween < 0){
            while(secondBetween < 0){
                int period = [[object valueForKey:@"recurringPeriod"] intValue];
                int unit = [[object valueForKey:@"recurringUnit"] intValue];
                int seconds = 0;
                switch(unit){
                    case 0:
                        seconds = period * 60;
                        break;
                    case 1:
                        seconds = period * 60 * 60;
                        break;
                    case 2:
                        seconds = period * 60 * 60 * 24;
                        break;
                    case 3:
                        seconds = period * 60 * 60 * 24 * 7;
                        break;
                    case 4:
                        seconds = period * 60 * 60 * 24 * 31;
                        break;
                    case 5:
                        seconds = period * 60 * 60 * 24 * 365;
                        break;
                    default:
                        break;
                }
                dueday = [dueday dateByAddingTimeInterval:seconds];
                secondBetween = [dueday timeIntervalSinceDate:today];
                object[@"deadline"] = dueday;
            }
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        
    }
    
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
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *object = [_tasks objectAtIndex:indexPath.row];
    _selectedTask = object;
    UITableViewRowAction *complete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Completed" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        object[@"completed"] = [NSNumber numberWithBool: ![object[@"completed"] boolValue]];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                [self.tableView reloadData];
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    complete.backgroundColor = [UIColor orangeColor];
    
    UITableViewRowAction *viewNote = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"View Notes" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self performSegueWithIdentifier:@"taskToNote" sender:nil];
    }];
    viewNote.backgroundColor = [UIColor purpleColor];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                [self.tableView reloadData];
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        PFQuery *noteQuery = [[PFQuery alloc] initWithClassName:@"Note"];
        [noteQuery whereKey:@"taskId" equalTo:[object valueForKey:@"objectId"]];
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
        [imageQuery whereKey:@"taskId" equalTo:[object valueForKey:@"objectId"]];
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

        [_tasks removeObjectAtIndex:indexPath.row];
    }];
    
    return @[complete, viewNote, delete];
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
    else if([segue.identifier isEqual:@"taskToNote"]) {
        NotesTableViewController *vc = [segue destinationViewController];
        vc.task = _selectedTask;
    }
}

@end
