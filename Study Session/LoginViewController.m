//
//  LoginViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "LoginViewController.h"
#import "NewUserLoginViewController.h"
#import "WallViewController.h"
#import "NSMutableArray+Shuffle.h"
#import "UIColor+FlatColors.h"
#import "SVProgressHUD.h"
#import "MKParallaxView.h"
#import "UIImage+ImageEffects.h"
#import <POP/POP.H>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()
@property (nonatomic, strong) NSTimer *backgroundTimer;
@property (nonatomic, strong) NSArray *backgroundArray;
@property (nonatomic, strong) NSMutableArray *randomizeImages;
@property (nonatomic, strong) UIImage *snapshotImage;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [PFFacebookUtils initializeFacebook];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.424 green:0.476 blue:0.479 alpha:0.900]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    
    self.backgroundArray = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg", @"8.jpg", @"9.jpg"];
    
    self.randomizeImages = [[NSMutableArray alloc]initWithArray:self.backgroundArray];
    
    [self.randomizeImages shuffle];
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];

    [self changeImage];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)changeImage
{
    static int counter = 0;
    static int isFirstRun = 0;
    if ([self.randomizeImages count] == counter+1)
    {
        counter = 0;
    }
    self.snapshotImage = [UIImage imageNamed:[self.randomizeImages objectAtIndex:counter]];
    
    UIImage *blurredSnapshotImage = [[UIImage imageNamed:[self.randomizeImages objectAtIndex:counter]] applyBlurWithRadius:3 tintColor:nil saturationDeltaFactor:0.8 maskImage:nil];
    
    MKParallaxView *basicBackground = [[MKParallaxView alloc] initWithFrame:self.view.frame]; basicBackground.backgroundImage = blurredSnapshotImage;
    if (isFirstRun != 0)
    {
        basicBackground.alpha = 0.00;
    }
    [basicBackground setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:1.0 animations:^{
        basicBackground.alpha = 1.0;
    }];

    [self.backgroundImage addSubview:basicBackground];
    counter++;
    isFirstRun++;

}


- (IBAction)TwitterLoginButton:(id)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error)
    {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        }
        else if (user.isNew)
        {
            NSLog(@"User with Twitter signed up and logged in!");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
            [self presentViewController:wallNavigationController animated:YES completion:nil];

        }
        else
        {
            NSLog(@"User logged in with Twitter!");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
            [self presentViewController:wallNavigationController animated:YES completion:nil];

        }
    }];
}

- (IBAction)FBLoginButton:(id)sender
{
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"email", @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Login PFUser using Facebook
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
        {
            if (!user)
            {
                if (!error)
                {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                }
                else
                {
                    NSLog(@"Uh oh. An error occurred: %@", error);
                }
            }
            else if (user.isNew)
            {
                NSLog(@"User with facebook signed up and logged in!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
                [self presentViewController:wallNavigationController animated:YES completion:nil];
            }
            else
            {
                NSLog(@"User with facebook logged in!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
                [self presentViewController:wallNavigationController animated:YES completion:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });

        }];
    });
}

- (IBAction)signupButton:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
	NewUserLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"NewUserLoginViewController"];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navController.navigationBarHidden = YES;
    
	self.viewController = loginViewController;
    
}
@end
