//
//  EditTaskTableViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditTaskTableViewController.h"
#import "TaskImageCollectionViewController.h"
#import "NotesTableViewController.h"
#import "EditNoteTableViewController.h"


@interface EditTaskTableViewController ()
@property UIDatePicker *datePicker;
@property UITapGestureRecognizer* tap;
@property UIImage *image;
@property BOOL hideSection;
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
    
    if(_task != nil) {
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
    }
    else {
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

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _notesCounter.text = [NSString stringWithFormat:@"%d Notes", [[_task valueForKey:@"totalNotes"] intValue]];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)shareTask:(id)sender {
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        [mail setSubject:_task[@"title"]];
        [mail setMessageBody:_task[@"description"] isHTML:false];
        [self presentViewController:mail animated:true completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No email found on device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(result == MFMailComposeResultFailed) {
        NSLog(@"email fail");
    }
    else if (result == MFMailComposeResultSent) {
        NSLog(@"email sent");
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)viewImage:(id)sender {
    [self performSegueWithIdentifier:@"TaskDetailToTaskImage" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"TaskDetailToTaskImage"]) {
        TaskImageCollectionViewController *vc = [segue destinationViewController];
        vc.taskId = [_task valueForKey:@"objectId"];
    }else if([segue.identifier  isEqual: @"editTaskToNotesTable"]) {
        NotesTableViewController *vc = [segue destinationViewController];
        vc.task = _task;
    }else if([segue.identifier  isEqual: @"editTaskToEditNote"]) {
        EditNoteTableViewController *vc = [segue destinationViewController];
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
    _task[@"recurringUnit"] = [NSNumber numberWithInt:_repeatingUnit.selectedSegmentIndex];

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
        int sliderValue = lroundf(_repeatingSlider.value);
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

/*
-(IBAction) setRecurring:(id)sender{
    UIButton *button = (UIButton *) sender;
    UIAlertController *repeatDialog = [UIAlertController alertControllerWithTitle:@"Repeating task"
        message:@"Set the frequency of this task"
        preferredStyle:UIAlertControllerStyleAlert
    ];
    
    [repeatDialog addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Time integer";
        textField.keyboardType = UIKeyboardTypePhonePad;
    }];
    UIAlertAction *week = [UIAlertAction actionWithTitle:@"Week" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        button.titleLabel.text = [NSString stringWithFormat:@"%@ Weeks", repeatDialog.textFields.firstObject.text];
        NSLog(@"%@ Week(s)", repeatDialog.textFields.firstObject.text);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [repeatDialog addAction:week];
    [self presentViewController:repeatDialog animated:YES completion:nil];
}
 */

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
