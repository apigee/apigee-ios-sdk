//
//  ViewController.m
//  Assets
//
//  Created by Robert Walsh on 10/7/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ViewController.h"
#import "APIClient.h"

@import MobileCoreServices;

@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImage* selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *pickedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *uploadedImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUploadedImage:nil];
}

#pragma mark Picking the Image from the devices albums
- (IBAction)pickImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes =  @[(NSString*)kUTTypeImage];
        imagePicker.allowsEditing = YES;

        [self presentViewController:imagePicker
                           animated:YES
                         completion:nil];
    }
}

#pragma mark Uploading and downloading IBActions
- (IBAction)uploadImage:(id)sender {
    if( [self selectedImage] ) {
        [[APIClient sharedClient] attachAssetData:UIImagePNGRepresentation([self selectedImage])
                                       completion:^(NSString *rawResponse, NSString *errorDescription) {
                                           if( [rawResponse length] > 0 && [errorDescription length] <= 0 ) {
                                               [self getUploadedImage:nil];
                                           }
                                       }];
    }
}

- (IBAction)getUploadedImage:(id)sender {
    [[APIClient sharedClient] retrieveAssetData:^(NSData *assetData, NSString *errorDescription) {
        if( [assetData length] > 0 && [errorDescription length] <= 0 ) {
            UIImage* image = [UIImage imageWithData:assetData];
            [[self uploadedImageView] setImage:image];
        }
    }];
}


#pragma mark UIImagePickerControllerDelegate Methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self setSelectedImage:(UIImage*)info[UIImagePickerControllerOriginalImage]];
    [[self pickedImageView] setImage:[self selectedImage]];
    [picker setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self setSelectedImage:nil];
    [picker setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
