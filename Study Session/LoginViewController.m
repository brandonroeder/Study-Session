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
    
    self.backgroundArray= @[@"lake.jpg", @"utdallas.jpg", @"utdallas.jpg", @"lake.jpg"];
    
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];

    [self changeImage];
    [self.navigationController setNavigationBarHidden:YES];

    self.emailField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.emailField.layer.borderWidth= 1.0f;
    self.emailField.layer.cornerRadius= 3.0;

    self.passwordField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.passwordField.layer.borderWidth= 1.0f;
    self.passwordField.layer.cornerRadius= 3.0;
    self.loginButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.loginButton.layer.borderWidth = 1.0;
    self.loginButton.layer.cornerRadius= 3.0;

    
    UIColor *color = [UIColor whiteColor];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];

    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];

    UIImageView *user = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail_Icon.png"]];
    user.frame = CGRectMake(0.0, 0.0, user.image.size.width+10.0, user.image.size.height);
    user.contentMode = UIViewContentModeCenter;
    self.emailField.leftView= user;
    
    UIImageView *password = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Padlock_Icon.png"]];
    password.frame = CGRectMake(0.0, 0.0, password.image.size.width+10.0, password.image.size.height);
    password.contentMode = UIViewContentModeCenter;
    self.passwordField.leftView= password;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (IBAction)login:(id)sender
{
    [self processFieldEntries];
}

- (void)changeImage
{
    
    static int counter = 0;
    static int isFirstRun = 0;
    if([self.backgroundArray count] == counter+1)
    {
        counter = 0;
    }
    self.snapshotImage = [UIImage imageNamed:[self.backgroundArray objectAtIndex:counter]];
    
    UIImage *blurredSnapshotImage = [[UIImage imageNamed:[self.backgroundArray objectAtIndex:counter]] applyBlurWithRadius:3 tintColor:nil saturationDeltaFactor:0.8 maskImage:nil];
    
    MKParallaxView *basicBackground = [[MKParallaxView alloc] initWithFrame:self.view.frame]; basicBackground.backgroundImage = blurredSnapshotImage;
    if(isFirstRun != 0)
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.emailField) {
		[self.passwordField becomeFirstResponder];
	}
	if (textField == self.passwordField) {
		[self.passwordField resignFirstResponder];
		[self processFieldEntries];
	}
	return YES;
}

- (IBAction)TwitterLoginButton:(id)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
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
            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else {
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)processFieldEntries
{
	// Get the username text, store it in the app delegate for now
	NSString *username = self.emailField.text;
	NSString *password = self.passwordField.text;
	NSString *noUsernameText = @"username";
	NSString *noPasswordText = @"password";
	NSString *errorText = @"No ";
	NSString *errorTextJoin = @" or ";
	NSString *errorTextEnding = @" entered";
	BOOL textError = NO;
    
	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (username.length == 0 || password.length == 0) {
		textError = YES;
        
		// Set up the keyboard for the first field missing input:
		if (password.length == 0) {
			[self.passwordField becomeFirstResponder];
		}
		if (username.length == 0) {
			[self.emailField becomeFirstResponder];
		}
	}
    
	if (username.length == 0) {
		textError = YES;
		errorText = [errorText stringByAppendingString:noUsernameText];
	}
    
	if (password.length == 0) {
		textError = YES;
		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:errorTextJoin];
		}
		errorText = [errorText stringByAppendingString:noPasswordText];
	}
    
	if (textError) {
		errorText = [errorText stringByAppendingString:errorTextEnding];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
         {
             if (user)
             {
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 UINavigationController *wallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MapNavBar"];
                 [self presentViewController:wallNavigationController animated:YES completion:nil];
             }
             else
             {
                 POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                 positionAnimation.velocity = @2000;
                 positionAnimation.springBounciness = 20;
                 
                 [positionAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                     self.loginButton.userInteractionEnabled = YES;
                 }];
                 [self.loginButton.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
                 // Didn't get a user.
                 NSLog(@"%s didn't get a user!", __PRETTY_FUNCTION__);
                 
                 
                 //                 double delayInSeconds = 0.5;
                 //                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                 //                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 //                     UIAlertView *alertView = nil;
                 //
                 //                     if (error == nil) {
                 //                         // the username or password is probably wrong.
                 //                         alertView = [[UIAlertView alloc] initWithTitle:@"Couldn’t log in:\nThe username or password were wrong." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                 //                     } else {
                 //                         // Something else went horribly wrong:
                 //                         alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect username or password" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                 //                     }
                 //                     [alertView show];
                 //                 });
                 
                 // Bring the keyboard back up, because they'll probably need to change something.
                 [self.emailField becomeFirstResponder];
             }
         }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}




@end
