//
//  EditNoteTableViewController.m
//  Task
//
//  Created by Ryan on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "EditNoteTableViewController.h"
@interface EditNoteTableViewController ()

@end

@implementation EditNoteTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(_note != nil) {
        _noteTitle.text = _note[@"noteTitle"];
        _noteContent.text = _note[@"noteContent"];
    }
    else {
        _note = [[PFObject alloc] initWithClassName:@"Note"];
    }
}

-(IBAction)saveNote:(id)sender{
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