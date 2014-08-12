//
//  NewUserLoginViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "NewUserLoginViewController.h"
#import "WallViewController.h"
#import "UIImage+ImageEffects.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface NewUserLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *passwordAgainField;
@property (strong, nonatomic) IBOutlet UITextField *schoolField;
@property (strong, nonatomic) IBOutlet UITextField *majorField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UIPickerView *pktStatePicker;
@property (nonatomic, strong) UITextField *currentField;
@property (strong, nonatomic) NSArray *schools;
@property (strong, nonatomic) NSArray *majors;
@property (strong, nonatomic) NSArray *currentArray;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (strong, nonatomic) UIToolbar *myPickerToolbar;

@end

@implementation NewUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *snapshotImage = [UIImage imageNamed:@"lake.jpg"];
    UIImage *blurredSnapshotImage = [snapshotImage applyBlurWithRadius:3 tintColor:nil saturationDeltaFactor:0.8 maskImage:nil];
    self.backgroundImage.image = blurredSnapshotImage;

    [self.navigationController setNavigationBarHidden:NO];

    self.emailField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.emailField.layer.borderWidth= 1.0f;
    self.emailField.layer.cornerRadius= 3.0;
    
    self.passwordField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.passwordField.layer.borderWidth= 1.0f;
    self.passwordField.layer.cornerRadius= 3.0;

    self.passwordAgainField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.passwordAgainField.layer.borderWidth= 1.0f;
    self.passwordAgainField.layer.cornerRadius= 3.0;

    self.majorField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.majorField.layer.borderWidth= 1.0f;
    self.majorField.layer.cornerRadius= 3.0;

    self.schoolField.layer.borderColor= [[UIColor whiteColor]CGColor];
    self.schoolField.layer.borderWidth= 1.0f;
    self.schoolField.layer.cornerRadius= 3.0;

    
    UIColor *color = [UIColor whiteColor];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordAgainField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter password again" attributes:@{NSForegroundColorAttributeName: color}];
    self.schoolField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"School" attributes:@{NSForegroundColorAttributeName: color}];
    self.majorField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Major" attributes:@{NSForegroundColorAttributeName: color}];

    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordAgainField setLeftViewMode:UITextFieldViewModeAlways];
    [self.majorField setLeftViewMode:UITextFieldViewModeAlways];
    [self.schoolField setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView *user = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail_Icon.png"]];
    user.frame = CGRectMake(0.0, 0.0, user.image.size.width+10.0, user.image.size.height);
    user.contentMode = UIViewContentModeCenter;
    self.emailField.leftView= user;
    
    UIImageView *password = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Padlock_Icon.png"]];
    password.frame = CGRectMake(0.0, 0.0, password.image.size.width+10.0, password.image.size.height);
    password.contentMode = UIViewContentModeCenter;
    self.passwordField.leftView= password;

    UIImageView *passwordAgain = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Padlock_Icon.png"]];
    passwordAgain.frame = CGRectMake(0.0, 0.0, passwordAgain.image.size.width+10.0, passwordAgain.image.size.height);
    passwordAgain.contentMode = UIViewContentModeCenter;
    self.passwordAgainField.leftView= passwordAgain;


    UIImageView *school = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"School_Icon.png"]];
    school.frame = CGRectMake(0.0, 0.0, school.image.size.width+10.0, school.image.size.height);
    school.contentMode = UIViewContentModeCenter;
    self.schoolField.leftView= school;
    
    UIImageView *major = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pencil_Icon.png"]];
    major.frame = CGRectMake(0.0, 0.0, major.image.size.width+10.0, major.image.size.height);
    major.contentMode = UIViewContentModeCenter;
    self.majorField.leftView= major;


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.emailField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordAgainField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.schoolField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.majorField];

	self.doneButton.enabled = NO;
    
    self.schools= [NSArray arrayWithObjects: @"The University of Texas at Dallas", @"University of Houston", nil];
    self.majors = [NSArray arrayWithObjects: @"Engineering", @"Math", @"Chemistry", nil];
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 43, 320, 480)];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self.picker  setShowsSelectionIndicator:YES];
    self.schoolField.inputView =  self.picker;
    self.majorField.inputView =  self.picker;

    self.myPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    self.myPickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.myPickerToolbar sizeToFit];
    
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                             action:@selector(pickerDoneClicked)];
    doneBtn.tintColor= [UIColor whiteColor];
    [barItems addObject:doneBtn];
    [self.myPickerToolbar setItems:barItems animated:YES];
    self.schoolField.inputAccessoryView = self.myPickerToolbar;
    self.majorField.inputAccessoryView = self.myPickerToolbar;

    
}

- (void)viewWillAppear:(BOOL)animated {
	[self.emailField becomeFirstResponder];
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.emailField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordAgainField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.schoolField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.majorField];

}

-(void)pickerDoneClicked

{
  	NSLog(@"Done Clicked");
    [self.schoolField resignFirstResponder];
    self.myPickerToolbar.hidden=YES;
    self.pktStatePicker.hidden=YES;
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView

{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
    return [self.currentArray count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component

{
    return [self.currentArray objectAtIndex:row];
}


- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component

{
    [self.currentField setText:[self.currentArray objectAtIndex:row]];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentField = textField;
    if (textField == self.schoolField)
    {
        self.currentArray = self.schools;
        self.myPickerToolbar.hidden= NO;
        self.pktStatePicker.hidden= NO;

        [self.picker reloadAllComponents];
    }
    
    if (textField == self.majorField)
    {
        self.currentArray = self.majors;
        self.myPickerToolbar.hidden= NO;
        self.pktStatePicker.hidden= NO;

        [self.picker reloadAllComponents];
    }
    return YES;

}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.emailField) {
		[self.passwordField becomeFirstResponder];
	}
	if (textField == self.passwordField) {
		[self.passwordAgainField becomeFirstResponder];
	}
	if (textField == self.passwordAgainField) {
		[self.schoolField becomeFirstResponder];
	}
    if (textField == self.schoolField) {
        [self.majorField becomeFirstResponder];
    }
    if (textField == self.majorField) {
        [self.majorField resignFirstResponder];
        [self processFieldEntries];
    }

    
	return YES;
}

#pragma mark - ()

- (BOOL)shouldEnableDoneButton
{
	BOOL enableDoneButton = YES;
	if (self.emailField.text != nil &&
		self.emailField.text.length > 0 &&
		self.passwordField.text != nil &&
		self.passwordField.text.length > 0 &&
        self.schoolField.text != nil &&
		self.schoolField.text.length > 0 &&
		self.majorField.text != nil &&
		self.majorField.text.length > 0 &&
		self.passwordAgainField.text != nil &&
		self.passwordAgainField.text.length > 0) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	self.doneButton.enabled = [self shouldEnableDoneButton];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[self.emailField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	[self.passwordAgainField resignFirstResponder];
    [self.schoolField resignFirstResponder];
	[self.majorField resignFirstResponder];
	[self processFieldEntries];
}

- (void)processFieldEntries
{
	// Check that we have a non-zero email and passwords.
	// Compare password and passwordAgain for equality
	// Throw up a dialog that tells them what they did wrong if they did it wrong.
    
	NSString *email = self.emailField.text;
	NSString *password = self.passwordField.text;
	NSString *passwordAgain = self.passwordAgainField.text;
    NSString *school = self.schoolField.text;
    NSString *major = self.majorField.text;
	NSString *errorText = @"Please ";
	NSString *emailBlankText = @"enter a email";
	NSString *passwordBlankText = @"enter a password";
	NSString *joinText = @", and ";
	NSString *passwordMismatchText = @"enter the same password twice";
    
	BOOL textError = NO;
    
	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (email.length == 0 || password.length == 0 || passwordAgain.length == 0 || school.length == 0 || major.length == 0) {
		textError = YES;
        
		// Set up the keyboard for the first field missing input:
		if (passwordAgain.length == 0) {
			[self.passwordAgainField becomeFirstResponder];
		}
		if (password.length == 0) {
			[self.passwordField becomeFirstResponder];
		}
		if (email.length == 0) {
			[self.emailField becomeFirstResponder];
		}
        if (major.length == 0) {
			[self.majorField becomeFirstResponder];
		}
		if (school.length == 0) {
			[self.schoolField becomeFirstResponder];
		}
		if (email.length == 0)
        {
			errorText = [errorText stringByAppendingString:emailBlankText];
		}
        
		if (password.length == 0 || passwordAgain.length == 0) {
			if (email.length == 0) { // We need some joining text in the error:
				errorText = [errorText stringByAppendingString:joinText];
			}
			errorText = [errorText stringByAppendingString:passwordBlankText];
		}
	}
    
    else if ([password compare:passwordAgain] != NSOrderedSame)
    {
		// We have non-zero strings.
		// Check for equal password strings.
		textError = YES;
		errorText = [errorText stringByAppendingString:passwordMismatchText];
		[self.passwordField becomeFirstResponder];
	}
    
	if (textError)
    {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}
    
//    if ([self NSStringIsValidEmail:email] == NO)
//    {
//        errorText = @"Please enter a valid email address";
//    }

	// Everything looks good; try to log in.
	// Disable the done button for now.
	self.doneButton.enabled = NO;
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFUser *user = [PFUser user];
        user.username = email;
        user.email = email;
        user.password = password;
        user[@"major"] = major;
        user[@"school"]= school;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                 [alertView show];
                 self.doneButton.enabled = [self shouldEnableDoneButton];
                 [self.emailField becomeFirstResponder];
                 return;
             }
             
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
         }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });


}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}



@end
