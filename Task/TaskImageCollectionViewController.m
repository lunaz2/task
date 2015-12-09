//
//  TaskImageCollectionViewController.m
//  Task
//
//  Created by Team 4 on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskImageCollectionViewController.h"
#import "TaskPhotoViewController.h"
#import "CollectionViewCell.h"

@interface TaskImageCollectionViewController ()
@property NSMutableArray *imageArray;
@property NSMutableArray *deleteImage;
@property NSMutableArray *addImage;
@property NSMutableArray *objectArray;
@property UIImagePickerController *cameraPicker;
@property UIImagePickerController *libraryPicker;
@end

@implementation TaskImageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageArray = [[NSMutableArray alloc] init];
    _deleteImage = [[NSMutableArray alloc] init];
    _addImage = [[NSMutableArray alloc] init];
    _objectArray = [[NSMutableArray alloc] init];
    
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor clearColor];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_bg@2x.png"]];
    [tempImageView setFrame:self.collectionView.frame];
    self.collectionView.backgroundView = tempImageView;
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
    press.minimumPressDuration = 0.5;
    press.delaysTouchesBegan = YES;
    press.delegate = self;
    [self.collectionView addGestureRecognizer:press];
    
    [self getImage];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

-(void)deleteImage: (UILongPressGestureRecognizer *) gestureRecognizer {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];
        
    if(indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Image" message:@"Are you sure you want to delete this image?" preferredStyle:UIAlertControllerStyleAlert];
            
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
            
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            if(indexPath.row < _objectArray.count) {
                [_deleteImage addObject:[_objectArray objectAtIndex:indexPath.row]];
            } else {
                [_addImage removeObjectAtIndex:indexPath.row - _objectArray.count];
            }
            
            [_imageArray removeObjectAtIndex:indexPath.row];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }]];
            
        [self presentViewController: alert animated: YES completion: nil];

    }
}


-(void) getImage {
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"ImageData"];
    [query whereKey:@"taskId" equalTo:[_task valueForKey:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(PFObject *object in objects) {
                PFFile *imageFile = object[@"imageFile"];
                [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if(!error) {
                        [_objectArray addObject:object];
                        [_imageArray addObject:[UIImage imageWithData:data]];
                        [self.collectionView reloadData];
                    }
                    else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)addImage:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Take image from" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseExisting];
    }]];
    
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (IBAction)saveAction:(id)sender {
    if(_deleteImage.count > 0) {
        [_task incrementKey:@"totalPhotos" byAmount:[NSNumber numberWithInt:0 - (int)_deleteImage.count]];
        for(PFObject *object in _deleteImage) {
            [object deleteInBackground];
        }
    }
    if(_addImage.count > 0) {
        [_task incrementKey:@"totalPhotos" byAmount:[NSNumber numberWithInt: (int)_addImage.count]];
        
        for(UIImage *image in _addImage) {
            PFObject *object = [PFObject objectWithClassName:@"ImageData"];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
            PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
            object[@"imageFile"] = imageFile;
            object[@"taskId"] = [_task valueForKey:@"objectId"];
            [object saveInBackground];
        }
    }
    [_task saveInBackground];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)takePhoto {
    _cameraPicker = [[UIImagePickerController alloc] init];
    _cameraPicker.delegate = self;
    [_cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

- (void)chooseExisting {
    _libraryPicker = [[UIImagePickerController alloc] init];
    _libraryPicker.delegate = self;
    [_libraryPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:_libraryPicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_imageArray addObject:image];
    [_addImage addObject:image];
    [self.collectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)infoAction:(id)sender {
    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Information"
                                                                   message:@"Tap and hold photo to delete it"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    [error addAction:ok];
    [self presentViewController:error animated:YES completion:nil];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TaskPhotoViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
    vc.image = [_imageArray objectAtIndex:indexPath.row];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [_imageArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ImageCollectionToDetail" sender:nil];
}

@end
