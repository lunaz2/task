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
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteTableViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    
    PFObject *object = [_notes objectAtIndex:indexPath.row];
    cell.noteTitleLabel.text = object[@"noteTitle"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd YYYY"];
    cell.noteCreatedDateLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[object valueForKey:@"createdAt"]]];
    
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
        [_task incrementKey:@"totalNotes" byAmount:@-1];
        [_task saveInBackground];
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
        vc.navigationItem.title = [object objectForKey:@"noteTitle"];
        
    }else if([segue.identifier  isEqual: @"notesTableToAddNote"]) {
        EditNoteTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    }
}
-(IBAction)addNote:(id)sender {
    [self performSegueWithIdentifier:@"notesTableToAddNote" sender:nil];
}
@end