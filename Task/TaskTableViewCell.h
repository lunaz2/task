//
//  TaskTableViewCell.h
//  Task
//
//  Created by Team 4 on 10/13/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *taskTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskDueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIImageView *repeatIcon;
@property (weak, nonatomic) IBOutlet UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UIButton *photosButton;
@property (weak, nonatomic) IBOutlet UIImageView *noteIcon;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UILabel *noteCount;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;

@end
