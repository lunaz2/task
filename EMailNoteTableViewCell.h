//
//  EMailNoteTableViewCell.h
//  Task
//
//  Created by Quynh Nguyen on 11/28/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMailNoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *selectedSwitch;

@end
