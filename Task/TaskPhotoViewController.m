//
//  TaskPhotoViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/17/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskPhotoViewController.h"

@interface TaskPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TaskPhotoViewController

- (void)viewDidLoad {
    [_activityIndicator startAnimating];
    [super viewDidLoad];
    
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 6.0;
    [_scrollView setClipsToBounds:YES];
   
    if(_image) {
        _imageView.image = _image;
        [_activityIndicator stopAnimating];
    }
    else {
        [_imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(!error) {
                _image = [UIImage imageWithData:data];
                _imageView.image = _image;
                [_activityIndicator stopAnimating];
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}


@end
