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
@property PFObject *selectedTaskList;
@property NSMutableDictionary *topTasks;
@end

@implementation TaskListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_bg@2x.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    UIEdgeInsets inset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.tableView.contentInset = inset;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([PFUser currentUser] == nil) {
        [self performSegueWithIdentifier:@"TaskListToLogIn" sender:nil];
    }
    else {
        [self fetchAllObjects];
    }
}


-(void) fetchAllObjects{
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"TaskList"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _taskList = [temp mutableCopy];
            //[self getTasks];
            NSMutableDictionary* taskDue = [[NSMutableDictionary alloc] init];
            __block int i = [_taskList count];
            for(PFObject* object in _taskList){
                NSLog(@"%@",object.objectId);
                PFQuery *tasks = [[PFQuery alloc] initWithClassName:@"Task"];
                
                [tasks whereKey:@"taskListId" equalTo:object.objectId];
          
                [tasks whereKey:@"completed" equalTo:[NSNumber numberWithBool:NO]];
                [tasks orderByAscending:@"deadline"];
                [tasks setLimit: 1];
                [tasks getFirstObjectInBackgroundWithBlock:^(PFObject * taskObject, NSError * taskError) {
                    if(taskObject){
                        [taskDue setObject:taskObject forKey:object.objectId];
                        NSLog(@"%@", [[taskDue objectForKey:object.objectId] objectForKey:@"title"]);
                        
                    }
                    i -= 1;
                    if(i <= 0){
                        
                        _topTasks = [taskDue mutableCopy];
                        [self.tableView reloadData];
                    }
                    
                    
                }];
                
                

                
            }
            
            [self.tableView reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    //NSLog(@"%@",[taskDue[3] objectForKey:@"title"]);
    
}



- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    [_taskList removeAllObjects];
    [self.tableView reloadData];
    [self performSegueWithIdentifier:@"TaskListToLogIn" sender:nil];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskList.count;
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top@2x.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom@2x.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle@2x.png"];
    }
    
    return background;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    
    PFObject *object = [_taskList objectAtIndex:indexPath.row];
    cell.taskListTitleLabel.text = object[@"title"];
    cell.taskListDueLabel.text = [NSString stringWithFormat:@"Tasks Remaining: %d",[object[@"totalTask"] intValue] - [object[@"completed"] intValue]];
    
    PFObject *task = _topTasks[object.objectId];
    cell.taskListNextTaskLate.hidden = TRUE;
    if(task != NULL){
        cell.taskListNextTaskTitle.hidden = FALSE;
        NSString *timeLeft = @" ";
        NSDate* now = [NSDate date];
        if([task[@"deadline"] compare:now] == NSOrderedDescending){
            cell.taskListNextTaskDue.hidden = FALSE;
            NSString *dateString = [NSDateFormatter localizedStringFromDate:task[@"deadline"]
                                dateStyle:NSDateFormatterShortStyle
                                timeStyle:NSDateFormatterShortStyle];
            
            timeLeft = dateString;
            cell.taskListNextTaskDue.text = [NSString stringWithFormat:@"Due: %@", timeLeft];
            cell.taskListNextTaskTitle.text =[ NSString stringWithFormat:@"Next up: %@",task[@"title"]];
        }else{
            cell.taskListNextTaskLate.hidden = FALSE;
            cell.taskListNextTaskDue.hidden = TRUE;
            cell.taskListNextTaskTitle.text =[ NSString stringWithFormat:@"Next up: %@",task[@"title"]];
        }
        
        
    }else{
        cell.taskListNextTaskTitle.hidden = TRUE;
        cell.taskListNextTaskDue.hidden = TRUE;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"taskListToTask" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                 editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *object = [_taskList objectAtIndex:indexPath.row];
    _selectedTaskList = object;
    
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self performSegueWithIdentifier:@"editTaskList" sender:nil];
    }];
    edit.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        
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
        
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error) {
                
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [_taskList removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    return @[delete, edit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual: @"taskListToTask"]) {
        TaskTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_taskList objectAtIndex:indexPath.row];
        vc.taskList = object;
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        vc.navigationItem.title = [object objectForKey:@"title"];
        
    }
    else if([segue.identifier isEqual: @"editTaskList"]) {
        EditTaskListTableViewController *vc = [segue destinationViewController];
        vc.taskList = _selectedTaskList;
    }
}
@end
