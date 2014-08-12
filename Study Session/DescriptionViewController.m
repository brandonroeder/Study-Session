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

    // Do any additional setup after loading the view.
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
