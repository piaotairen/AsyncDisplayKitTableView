//
//  ViewController.m
//  AsyncDisplayKitTableView
//
//  Created by Zihai on 15/11/11.
//  Copyright © 2015年 Zihai. All rights reserved.
//

#import "ViewController.h"
#import "JZImagePickerController.h"

@interface ViewController ()<JZImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)showPhotos:(id)sender {
    JZImagePickerController *imagePickerController = [[JZImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;
    imagePickerController.maximumNumberOfSelection = 10;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JZImagePickerControllerDelegate

- (void)imagePickerController:(JZImagePickerController *)imagePickerController didSelectImgs:(NSArray *)images
{
    [self dismissImagePickerController];
    
    NSLog(@"images is %@",images);
}

- (void)imagePickerDidCancel:(JZImagePickerController *)imagePickerController
{
    NSLog(@"*** imagePickerControllerDidCancel:");
    
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

@end
