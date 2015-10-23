//
//  TaskPhotoViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/17/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskPhotoViewController.h"

@interface TaskPhotoViewController ()
@property UIImagePickerController *libraryPicker;
@property UIImagePickerController *cameraPicker;
@property UIImage *image;
@property IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation TaskPhotoViewController

- (void)viewDidLoad {
    [_activityIndicator startAnimating];
    [super viewDidLoad];
    
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 6.0;
    
    PFFile *imageFile = _task[@"imageFile"];
    
    if(imageFile == nil) {
        _noImageLabel.hidden = NO;
        _imageView.hidden = YES;
        [_activityIndicator stopAnimating];
    }
    else {
        [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(!error) {
                _image = [UIImage imageWithData:data];
                _noImageLabel.hidden = YES;
                _imageView.hidden = NO;
                _imageView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
                _imageView.image = _image;
            
                _scrollView.contentSize = _imageView.frame.size;
                _scrollView.bounces = NO;
            
                [_activityIndicator stopAnimating];
            }
            else {
            
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

- (IBAction)saveAction:(id)sender {
    NSData *imageData = UIImageJPEGRepresentation(_image, 0.9f);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
    _task[@"imageFile"] = imageFile;
    [_task saveInBackground];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)takePhoto:(id)sender {
    _cameraPicker = [[UIImagePickerController alloc] init];
    _cameraPicker.delegate = self;
    [_cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

- (IBAction)chooseExisting:(id)sender {
    _cameraPicker = [[UIImagePickerController alloc] init];
    _cameraPicker.delegate = self;
    [_cameraPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.image = _image;
    _imageView.hidden = NO;
    _noImageLabel.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
