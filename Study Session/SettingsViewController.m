//
//  SettingsViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/18/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "WallMapViewController.h"
#import "UIColor+FlatColors.h"
#import "UIImage+ImageEffects.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
}
- (IBAction)closeButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section == 0)
    {
        cell.textLabel.text = @"Preferences";
    }
    if (indexPath.section == 1)
    {
        cell.textLabel.text = @"About";
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    if (indexPath.section == 1)
    {
        AboutViewController *aboutViewController = [[AboutViewController alloc]init];
        [[self navigationController] pushViewController: aboutViewController animated:YES];
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
    
    switch (popup.tag)
    {
        case 1:
        {
            switch (buttonIndex)
            {
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 20)];

    if (section == 1)
    {
        UILabel *footerText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        UILabel *cuteTagline = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, 320, 20)];
        cuteTagline.text = @"Designed and coded in Texas";
        cuteTagline.textColor = [UIColor colorWithRed:0.553 green:0.552 blue:0.578 alpha:0.900];
        cuteTagline.font = [UIFont fontWithName:@"Helvetica" size:12];
        [cuteTagline setTextAlignment:NSTextAlignmentCenter];

        footerText.text = @"Study Session v0.2 (Build 200)";
        footerText.textColor = [UIColor colorWithRed:0.553 green:0.552 blue:0.578 alpha:0.900];
        footerText.font = [UIFont fontWithName:@"Helvetica" size:12];
        [footerText setTextAlignment:NSTextAlignmentCenter];
        
        [sectionView addSubview:cuteTagline];
        [sectionView addSubview:footerText];
    }
    return sectionView;
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor flatRedColor];
            NSString *buttonText = button.titleLabel.text;
            if ([buttonText isEqualToString:NSLocalizedString(@"Cancel", nil)])
            {
                button.titleLabel.textColor = [UIColor flatBlueColor];
            }
        }
    }];
}

//- (void)addBlurView
//{
//    CGRect screenCaptureRect = self.view.bounds;
//    UIView *viewScreenCapture = [[UIApplication sharedApplication] keyWindow];
//    
//    UIGraphicsBeginImageContextWithOptions(screenCaptureRect.size, NO, [UIScreen mainScreen].scale);
//    [viewScreenCapture drawViewHierarchyInRect:screenCaptureRect afterScreenUpdates:NO];
//    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIImage *blurredImage = [capturedImage applyBlurWithRadius:30 tintColor:[UIColor colorWithRed:0.235 green:0.251 blue:0.290 alpha:0.550] saturationDeltaFactor:0.5 maskImage:nil];
//    
//    UIImageView *blurView = [[UIImageView alloc] initWithFrame:screenCaptureRect];
//    
//    [blurView setImage:blurredImage];
//    [blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    self.tableView.backgroundView = blurView;
//}

@end
