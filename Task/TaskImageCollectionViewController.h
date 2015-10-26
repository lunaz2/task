//
//  TaskImageCollectionViewController.h
//  Task
//
//  Created by Quynh Nguyen on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TaskImageCollectionViewController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property NSString *taskId;@end
