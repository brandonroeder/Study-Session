//
//  DescriptionViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 8/11/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "DescriptionViewController.h"
@interface DescriptionViewController ()
@end

@implementation DescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.descriptionText.text = self.oldText;
    self.descriptionText.backgroundColor = [UIColor whiteColor];
    self.descriptionText.editable = YES;
    self.descriptionText.userInteractionEnabled = YES;
    self.descriptionText.textColor = [UIColor blackColor];
    self.descriptionText.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    self.title = @"Description";
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.view addSubview:self.descriptionText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.descriptionText becomeFirstResponder];

}

- (void)done
{
    NSString *itemToPassBack = self.descriptionText.text;
    [self.delegate addItemViewController:self didFinishEnteringItem:itemToPassBack];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
