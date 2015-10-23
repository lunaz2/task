//
//  TaskPhotoViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/17/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TaskPhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *noImageLabel;
@property PFObject *task;
@end
