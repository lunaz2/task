//
//  NotesTableViewController.m
//  Task
//
//  Created by Ryan on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "NotesTableViewController.h"
#import "NoteTableViewCell.h"
#import "EditNoteTableViewController.h"

@interface NotesTableViewController ()
@property NSMutableArray *notes;
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation NotesTableViewController

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
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Note"];
    [query whereKey:@"taskId" equalTo:[_task valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _notes = [temp mutableCopy];
            [_activityIndicator stopAnimating];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteTableViewCell" forIndexPath:indexPath];
    
    PFObject *object = [_notes objectAtIndex:indexPath.row];
    cell.noteTitleLabel.text = object[@"noteTitle"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/YYYY hh:mm a"];
    cell.noteCreatedDateLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:object[@"createdAt"]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"notesTableToEditNote" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [_notes objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error) {
                
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Note"];
        [query whereKey:@"objectId" equalTo:[object valueForKey:@"objectId"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSArray *temp = [[NSArray alloc] initWithArray:objects];
                for (PFObject *task in temp) {
                    
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
        
        [_notes removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"notesTableToEditNote"]) {
        EditNoteTableViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [_notes objectAtIndex:indexPath.row];
        vc.note = object;
        vc.task = _task;
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        vc.navigationItem.title = [object objectForKey:@"title"];
        
    }else if([segue.identifier  isEqual: @"notesTableToAddNote"]) {
        EditNoteTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    }
}
-(IBAction)addNote:(id)sender {
    [self performSegueWithIdentifier:@"notesTableToAddNote" sender:nil];
}
@end