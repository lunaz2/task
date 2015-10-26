//
//  TaskImageCollectionViewController.m
//  Task
//
//  Created by Quynh Nguyen on 10/25/15.
//  Copyright © 2015 Group 4. All rights reserved.
//

#import "TaskImageCollectionViewController.h"
#import "TaskPhotoViewController.h"
#import "CollectionViewCell.h"

@interface TaskImageCollectionViewController ()
@property NSMutableArray *imageArray;
@property NSMutableArray *addImage;
@property UIImagePickerController *cameraPicker;
@property UIImagePickerController *libraryPicker;
@end

@implementation TaskImageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    _addImage = [[NSMutableArray alloc] init];
    _imageArray = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self getImage];
}

-(void) getImage {
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"ImageData"];
    [query whereKey:@"taskId" equalTo:_taskId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [_imageArray removeAllObjects];
            [_imageArray addObjectsFromArray:objects];
            NSLog(@"%d", _imageArray.count);
            [self.collectionView reloadData];
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
    for(UIImage *image in _addImage) {
        PFObject *object = [PFObject objectWithClassName:@"ImageData"];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
        PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
        object[@"imageFile"] = imageFile;
        object[@"taskId"] = _taskId;
        [object saveInBackground];
    }
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
    [_addImage addObject:image];
    NSLog(@"after choose image : %d", _addImage.count);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TaskPhotoViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    if(indexPath.row < _imageArray.count) {
        PFFile *imageFile = [_imageArray objectAtIndex:indexPath.row][@"imageFile"];
        vc.imageFile = imageFile;
    } else {
        UIImage *image= [_addImage objectAtIndex:_addImage.count - indexPath.row];
        vc.image = image;
    }
    [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count + _addImage.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(indexPath.row < _imageArray.count) {
        PFFile *imageFile = [_imageArray objectAtIndex:indexPath.row][@"imageFile"];
        [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.imageView.image = image;
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    } else {
        NSLog(@"row : %d, count: %d ", _addImage.count, indexPath.row);
        cell.imageView.image = [_addImage objectAtIndex:_addImage.count - indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ImageCollectionToDetail" sender:nil];
}

@end
