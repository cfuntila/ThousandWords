//
//  ViewController.h
//  aThousandWords
//
//  Created by Charity Funtila on 7/22/20.
//  Copyright © 2020 Charity Funtila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate >

// Variables
@property (retain, nonatomic) NSArray *results;

// UI views
@property (weak, nonatomic) IBOutlet UIButton *openCamera;
@property (weak, nonatomic) IBOutlet UILabel *imageTitle;
@property (weak, nonatomic) IBOutlet UIButton *openGallery;
@property (weak, nonatomic) IBOutlet UIImageView *image;

// functions
- (IBAction)openGallery:(id)sender;
- (void)takePhoto;
- (void)imagePickerController:(UIImagePickerController *)picker;


@end

