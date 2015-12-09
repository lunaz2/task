//
//  EditTaskTableViewController.m
//  Task
//
//  Created by Team 4 on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskTableViewController.h"
#import "TaskImageCollectionViewController.h"
#import "NotesTableViewController.h"
#import "EditNoteTableViewController.h"
#import "EMailTableViewController.h"


@interface EditTaskTableViewController ()
@property UIDatePicker *datePicker;
@property UITapGestureRecognizer* tap;
@property UIImage *image;
@property BOOL hideSection;
@property UIImagePickerController *cameraPicker;
@property UIImagePickerController *libraryPicker;
@end

@implementation EditTaskTableViewController
@synthesize datePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    _hideSection = false;
    _repeatingSwitch.on = NO;
    checked = NO;
    _repeatingSlider.enabled = NO;
    _repeatingUnit.enabled = NO;
    _repeatingSliderLabel.hidden = YES;
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [_editTaskDueField setInputView:datePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(showDate)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:space,doneBtn,nil]];
    [_editTaskDueField setInputAccessoryView:toolbar];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_bg@2x.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    if(_task != nil) {
        self.title = _task[@"title"];
        _editTaskTitleField.text = _task[@"title"];
        _editTaskDescTextView.text = _task[@"description"];
        [datePicker setDate:_task[@"deadline"]];
        [self showDate];
        checked = [[_task objectForKey:@"completed"] boolValue];
        _repeatingSwitch.on = [[_task objectForKey:@"isRecurring"] boolValue];
        if(_repeatingSwitch.isOn){
            _repeatingSlider.enabled = YES;
            _repeatingUnit.enabled = YES;
            _repeatingSliderLabel.hidden = NO;
            [_repeatingSlider setValue:[[_task objectForKey:@"recurringPeriod"] intValue] animated:YES];
            _repeatingSliderLabel.text = [NSString stringWithFormat:@"%d",[[_task objectForKey:@"recurringPeriod"] intValue]];
            _repeatingUnit.selectedSegmentIndex = [[_task objectForKey:@"recurringUnit"] intValue];
        }
        _notesCounter.text = [NSString stringWithFormat:@"%d Notes", [[_task valueForKey:@"totalNotes"] intValue]];
        _photosCounter.text = [NSString stringWithFormat:@"%d Photos", [[_task valueForKey:@"totalPhotos"] intValue]];
    }
    else {
        self.title = @"New Task";
        _hideSection = true;
        _task = [[PFObject alloc] initWithClassName:@"Task"];
        
    }

    if(checked)
        [_completeButton setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
    else [_completeButton setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    _tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tap];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _notesCounter.text = [NSString stringWithFormat:@"%d Notes", [[_task valueForKey:@"totalNotes"] intValue]];
    _photosCounter.text = [NSString stringWithFormat:@"%d Photos", [[_task valueForKey:@"totalPhotos"] intValue]];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)shareTask:(id)sender {
    if([MFMailComposeViewController canSendMail])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Attachment" message:@"Would you like to attach additional images or notes to your email?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"editTaskToEMail" sender:nil];
        }];
        [alert addAction:yesAction];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            [mail.navigationBar setBarTintColor:[UIColor darkGrayColor]];
            [self presentViewController:mail animated:YES completion:nil];
        }];
        [alert addAction:noAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No email found on device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"TaskDetailToTaskPhotoCollection"]) {
        TaskImageCollectionViewController *vc = [segue destinationViewController];
        vc.task = _task;
    } else if([segue.identifier  isEqual: @"editTaskToNotesTable"]) {
        NotesTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    } else if([segue.identifier  isEqual: @"editTaskToEditNote"]) {
        EditNoteTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    } else if([segue.identifier  isEqual: @"editTaskToEMail"]) {
        EMailTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    }
}

-(IBAction)viewNotesTable:(id)sender{
    [self performSegueWithIdentifier:@"editTaskToNotesTable" sender:nil];
}

-(IBAction)addNote:(id)sender {
    [self performSegueWithIdentifier:@"editTaskToEditNote" sender:nil];
}

-(void)showDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM/YYYY hh:mm a"];
    _editTaskDueField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:datePicker.date]];
    [_editTaskDueField resignFirstResponder];
}


-(IBAction)saveAction:(id)sender {
    
    _task[@"username"] = [[PFUser currentUser] username];
    _task[@"title"] = _editTaskTitleField.text;
    _task[@"description"] = _editTaskDescTextView.text;
    _task[@"deadline"] = datePicker.date;
    _task[@"taskListId"] = _taskListId;
    _task[@"completed"] = [NSNumber numberWithBool:checked];
    _task[@"isRecurring"] = [NSNumber numberWithBool:_repeatingSwitch.isOn];
    _task[@"recurringPeriod"] = [NSNumber numberWithInt:_repeatingSlider.value];
    _task[@"recurringUnit"] = [NSNumber numberWithInt:(int)_repeatingUnit.selectedSegmentIndex];
    if(_hideSection) {
        _task[@"totalNotes"] = @0;
        _task[@"totalPhotos"] = @0;
    }

    [_task saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[self navigationController] popViewControllerAnimated:YES];
    
}
- (IBAction)completeBtn:(id)sender {
    if(!checked) {
        [_completeButton setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
        checked = YES;
    }
    else {
        [_completeButton setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
        checked = NO;
    }
}

-(IBAction)sliderValueChanged:(id)sender{
    if(sender == _repeatingSlider){
        int sliderValue = (int)lroundf(_repeatingSlider.value);
        [_repeatingSlider setValue:sliderValue animated:YES];
        _repeatingSliderLabel.text = [NSString stringWithFormat:@"%d",sliderValue];
    }
}

-(IBAction)switchValueChanged:(id)sender{
    if(sender == _repeatingSwitch){
        if(_repeatingSwitch.isOn){
            _repeatingSlider.enabled = YES;
            _repeatingUnit.enabled = YES;
            _repeatingSliderLabel.hidden = NO;
        }else{
            _repeatingSlider.enabled = NO;
            _repeatingUnit.enabled = NO;
            _repeatingSliderLabel.hidden = YES;
        }
    }
}

- (IBAction)addImage:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Take image from" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseExisting];
    }]];
    
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)takePhoto {
    _cameraPicker = [[UIImagePickerController alloc] init];
    _cameraPicker.delegate = self;
    [_cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

- (void)chooseExisting {
    _libraryPicker = [[UIImagePickerController alloc] init];
    _libraryPicker.delegate = self;
    [_libraryPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:_libraryPicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [_task incrementKey:@"totalPhotos"];
    [_task saveInBackground];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    PFObject *object = [PFObject objectWithClassName:@"ImageData"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
    object[@"imageFile"] = imageFile;
    object[@"taskId"] = [_task valueForKey:@"objectId"];
    [object saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 2;
    else if (section == 4 || section == 5) {
        if(_hideSection)
            return 0;
        else return 1;
    } else return 1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 4 || section == 5) {
        if(_hideSection)
            return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 4 || section == 5) {
        if(_hideSection)
            return 1;
    }
    return 32;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
