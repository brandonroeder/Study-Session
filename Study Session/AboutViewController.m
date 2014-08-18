//
//  AboutViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 8/15/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "AboutViewController.h"
#import <FontasticIcons.h>

@interface AboutViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"About";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.872 green:0.207 blue:0.182 alpha:1.000];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];

    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor blackColor];

    if (indexPath.row == 0)
    {
        FIIcon *icon = [FIEntypoSocialIcon twitterIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];

        cell.textLabel.text = @"Follow me on Twitter";
    }
    if (indexPath.row == 1)
    {
        FIIcon *icon = [FIEntypoSocialIcon facebookIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];
        
        cell.textLabel.text = @"Don't add me on Facebook";
    }
    if (indexPath.row == 2)
    {
        FIIcon *icon = [FIEntypoIcon mailIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];
        
        cell.textLabel.text = @"Email me shit";
    }
    if (indexPath.row == 3)
    {
        FIIcon *icon = [FIEntypoIcon airplaneIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];
        
        cell.textLabel.text = @"I just liked the plane icon";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 20)];
    
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
    
    return sectionView;
}

@end
