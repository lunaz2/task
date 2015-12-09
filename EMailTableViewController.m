//
//  EMailTableViewController.m
//  Task
//
//  Created by Team 4 on 11/28/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EMailTableViewController.h"
#import "PhotoTableViewCell.h"
#import "EMailNoteTableViewCell.h"

@interface EMailTableViewController ()
@property NSMutableArray *notes, *photos, *selectedNotes, *selectedPhotos;
@end

@implementation EMailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _notes = [[NSMutableArray alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _selectedNotes = [[NSMutableArray alloc] init];
    _selectedPhotos = [[NSMutableArray alloc] init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundView = nil;
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
    [self fetchAllNotes];
    [self getImage];
}

-(void) fetchAllNotes{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Note"];
    [query whereKey:@"taskId" equalTo:[_task valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *temp = [[NSArray alloc] initWithArray:objects];
            _notes = [temp mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

-(void) getImage {
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"ImageData"];
    [query whereKey:@"taskId" equalTo:[_task valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(PFObject *object in objects) {
                PFFile *imageFile = object[@"imageFile"];
                [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if(!error) {
                        [_photos addObject:data];
                        [self.tableView reloadData];
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
}
- (IBAction)sendEmail:(id)sender {
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    
    for(NSNumber *i in _selectedPhotos) {
        NSString *fileName = [NSString stringWithFormat:@"image%d", [i intValue]];
        fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
        [mail addAttachmentData:[_photos objectAtIndex:[i intValue]] mimeType:@"image/jpeg" fileName:fileName];
    }
    
    NSString *content = @"===============\nNotes:\n===============\n";
    
    for(NSNumber *i in _selectedNotes) {
        PFObject *note = [_notes objectAtIndex:[i intValue]];
        NSString *noteText = [NSString stringWithFormat:@"%d.%@: %@\n",[i intValue] + 1, note[@"noteTitle"], note[@"noteContent"]];
        content = [content stringByAppendingString:noteText];
    }
    
    [mail setMessageBody:content isHTML:NO];
    [self presentViewController:mail animated:YES completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photoSwitchChange:(id)sender {
    CGPoint position = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    PhotoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectedSwitch.isOn) {
        [_selectedPhotos addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    else {
        for(NSNumber *path in _selectedPhotos) {
            if(indexPath.row == [path integerValue])
               [_selectedPhotos removeObject:path];
        }
    }
}

- (IBAction)noteSwitchChange:(id)sender {
    CGPoint position = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    EMailNoteTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectedSwitch.isOn) {
        [_selectedNotes addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    else {
        for(NSNumber *path in _selectedNotes) {
            if(indexPath.row == [path integerValue])
                [_selectedNotes removeObject:path];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return [[_task valueForKey:@"totalPhotos"] intValue];
    else return [[_task valueForKey:@"totalNotes"] intValue];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) return 150;
    else return 71;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"Photos";
    else return @"Notes";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:indexPath.section];
    
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
    if(indexPath.section == 0) {
        PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        
        UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;
        if(_photos.count == [[_task valueForKey:@"totalPhotos"] intValue])
            cell.photoView.image = [UIImage imageWithData:[_photos objectAtIndex:indexPath.row]];
        return cell;
    }
    else {
        EMailNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        
        UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;
        if(_notes.count == [[_task valueForKey:@"totalNotes"] intValue])
            cell.titleLabel.text = [_notes objectAtIndex:indexPath.row][@"noteTitle"];
        return cell;
    }
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
