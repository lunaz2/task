//
//  PhotoTableViewCell.h
//  Task
//
//  Created by Team 4 on 11/28/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UISwitch *selectedSwitch;

@end
