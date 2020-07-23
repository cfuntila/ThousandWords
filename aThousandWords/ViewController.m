//
//  ViewController.m
//  aThousandWords
//
//  Created by Charity Funtila on 7/22/20.
//  Copyright © 2020 Charity Funtila. All rights reserved.
//

#import "ViewController.h"

#import "MobileNetV2.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set default UI options
    [self.openCamera setTitle:@"Camera" forState:UIControlStateNormal];
    [self.imageTitle setText:@"No image selected"];
    self.imageTitle.textAlignment = NSTextAlignmentCenter;
    
    // accessibility settings
    [self.imageTitle setAccessibilityLabel:@"Welcome, use the camera button below to begin"];
    
    // allow multiline results
    self.imageTitle.lineBreakMode = UILineBreakModeWordWrap;
    self.imageTitle.numberOfLines = 0;
    [self.imageTitle sizeToFit];
}

// Opens Gallery allows you to chose a photo
- (IBAction)openGallery:(id)sender {
    NSLog(@"Open Gallery button is pressed!");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    picker.delegate = self;
    picker.editing = YES;
    picker.allowsEditing = YES;

    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

// camera button
- (IBAction)openCamera:(id)sender {
    NSLog(@"Camera button is pressed!");
    [self takePhoto];
}

// opens camera
- (void)takePhoto {
    NSLog(@"take photo!");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];

}

// sets image 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (chosenImage == NULL){
        printf("image is null!");
    }
    CIImage* myImageCI = [[CIImage alloc] initWithCGImage:chosenImage.CGImage];
    self.image.image = chosenImage;
    self.imageTitle.text = @"Processing...";
    
    //image processing
    [self processImage: myImageCI];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// Use the ML model to define the image
- (void) processImage: (CIImage *)image {
    NSLog(@"in processImage!");
    MLModel *model = [[[MobileNetV2 alloc] init] model];
    VNCoreMLModel *myConvertedModel = [VNCoreMLModel modelForMLModel: model error:nil];
    VNCoreMLRequest *requestImageGuess = [[VNCoreMLRequest alloc] initWithModel: myConvertedModel completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.results = [request.results copy];
            VNClassificationObservation *firstResult = ((VNClassificationObservation *)(self.results[0]));
            float percent = firstResult.confidence * 100;
            self.imageTitle.text = [NSString stringWithFormat: @"Confidence: %.f%@ %@", percent,@"%", firstResult.identifier];
            NSLog(@"RESULT: %@", self.imageTitle.text);
        });
    }];
    
    NSDictionary *options = [[NSDictionary alloc] init];
    NSArray *requestAllImageGuesses = @[requestImageGuess];

    // make the request!
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image options:options];
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler performRequests:requestAllImageGuesses error:nil];
    });
}


@end
