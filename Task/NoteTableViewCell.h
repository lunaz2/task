//
//  NoteTableViewCell.h
//  Task
//
//  Created by Team 4 on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface NoteTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noteTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *noteCreatedDateLabel;
//@property (nonatomic, weak) IBOutlet UIButton *taskListEditButton;
@end
