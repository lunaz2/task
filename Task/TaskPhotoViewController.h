//
//  TaskPhotoViewController.h
//  Task
//
//  Created by Team 4 on 10/17/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TaskPhotoViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *image;
@property PFFile *imageFile;
@end
