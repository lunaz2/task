//
//  EditNoteTableViewController.m
//  Task
//
//  Created by Ryan on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditNoteTableViewController.h"
@interface EditNoteTableViewController ()
@property BOOL didCreate;
@property UITapGestureRecognizer *tap;
@end

@implementation EditNoteTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _didCreate = false;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_bg@2x.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    if(_note != nil) {
        self.title = _note[@"noteTitle"];
        _noteTitle.text = _note[@"noteTitle"];
        _noteContent.text = _note[@"noteContent"];
    }
    else {
        self.title = @"New Note";
        _didCreate = true;
        _note = [[PFObject alloc] initWithClassName:@"Note"];
    }
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    _tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tap];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(IBAction)saveNote:(id)sender{
    if(_didCreate)
        [_task incrementKey:@"totalNotes"];
    [_task saveInBackground];
    _note[@"taskId"] = [_task valueForKey:@"objectId"];
    _note[@"noteTitle"] = _noteTitle.text;
    _note[@"noteContent"] = _noteContent.text;
    if(_noteTitle.text.length == 0){
        UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error"
            message:@"Empty title"
            preferredStyle:UIAlertControllerStyleAlert
        ];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"typed: %@",error.textFields.firstObject.text);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [error addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"Type something";
        }];
        [error addAction:ok];
        [self presentViewController:error animated:YES completion:nil];
    }else{
        [_note saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [[self navigationController] popViewControllerAnimated:YES];
    }
}
@end