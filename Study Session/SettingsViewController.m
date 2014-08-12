//
//  SettingsViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/18/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "SettingsViewController.h"
#import "WallMapViewController.h"
#import "UIColor+FlatColors.h"
#import "UIImage+ImageEffects.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.tableView.backgroundColor = [UIColor flatGrayColor];
    self.title = @"Settings";
    self.tableView.tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor flatGrayColor];

    [self addBlurView];

}
- (IBAction)closeButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Test New Shit";
    }
    if (indexPath.row == 1)
    {
        cell.textLabel.text = @"About This App";
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WallMapViewController *mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
        [self presentViewController:mapViewController animated:YES completion:nil];

    }
    
    
}
- (IBAction)logout:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Logout",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    

}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [PFUser logOut];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    [self presentViewController:loginViewController animated:YES completion:nil];
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor flatRedColor];
            NSString *buttonText = button.titleLabel.text;
            if ([buttonText isEqualToString:NSLocalizedString(@"Cancel", nil)]) {
                button.titleLabel.textColor = [UIColor flatBlueColor];
            }
        }
    }];
}


- (void)addBlurView
{
    CGRect screenCaptureRect = self.view.bounds;
    UIView *viewScreenCapture = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContextWithOptions(screenCaptureRect.size, NO, [UIScreen mainScreen].scale);
    [viewScreenCapture drawViewHierarchyInRect:screenCaptureRect afterScreenUpdates:NO];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurredImage = [capturedImage applyBlurWithRadius:30 tintColor:[UIColor colorWithRed:0.235 green:0.251 blue:0.290 alpha:0.550] saturationDeltaFactor:0.5 maskImage:nil];
    
    UIImageView *blurView = [[UIImageView alloc] initWithFrame:screenCaptureRect];
    
    [blurView setImage:blurredImage];
    [blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.tableView.backgroundView = blurView;
}


-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}



@end
