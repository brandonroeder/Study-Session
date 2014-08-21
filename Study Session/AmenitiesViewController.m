//
//  AmenitiesViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 8/13/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "AmenitiesViewController.h"
#import "UIColor+FlatColors.h"
#import "M13Checkbox.h"
#import <FontasticIcons.h>
@interface AmenitiesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) M13Checkbox *quietCheckbox;
@property (nonatomic, strong) M13Checkbox *wifiCheckbox;
@property (nonatomic, strong) M13Checkbox *outletsCheckbox;
@property (nonatomic, strong) M13Checkbox *foodCheckbox;
@property (nonatomic, strong) M13Checkbox *tablesCheckbox;

@end

@implementation AmenitiesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, 320, 400) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"Amenities";
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.872 green:0.207 blue:0.182 alpha:1.000];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    UIView *checkbox = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 40, cell.textLabel.frame.origin.y+5,self.quietCheckbox.frame.size.width, self.quietCheckbox.frame.size.height)];

    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Quiet";
        
        self.quietCheckbox = [[M13Checkbox alloc] init];
        [self.quietCheckbox setValue:[NSNumber numberWithBool:YES] forKeyPath:@"checkedValue"];
        [self.quietCheckbox setValue:[NSNumber numberWithBool:NO] forKeyPath:@"uncheckedValue"];

        self.quietCheckbox.frame = CGRectMake(0, 0, self.quietCheckbox.frame.size.width, self.quietCheckbox.frame.size.height);
        self.quietCheckbox.flat = YES;
        self.quietCheckbox.strokeWidth = 0.5;
        self.quietCheckbox.strokeColor =  [UIColor colorWithRed:0.625 green:0.627 blue:0.657 alpha:0.900];
        self.quietCheckbox.checkColor = [UIColor flatGrayColor];
        self.quietCheckbox.radius = 0.0;
        [checkbox addSubview:self.quietCheckbox];
        [cell.contentView addSubview:checkbox];
    }
    
    if (indexPath.row == 1)
    {
        cell.textLabel.text = @"WiFi";
        
        self.wifiCheckbox = [[M13Checkbox alloc] init];
        [self.wifiCheckbox setValue:[NSNumber numberWithBool:YES] forKeyPath:@"checkedValue"];
        [self.wifiCheckbox setValue:[NSNumber numberWithBool:NO] forKeyPath:@"uncheckedValue"];

        self.wifiCheckbox.frame = CGRectMake(0, 0, self.wifiCheckbox.frame.size.width, self.wifiCheckbox.frame.size.height);
        self.wifiCheckbox.flat = YES;
        self.wifiCheckbox.strokeWidth = 0.5;
        self.wifiCheckbox.strokeColor =  [UIColor colorWithRed:0.625 green:0.627 blue:0.657 alpha:0.900];
        self.wifiCheckbox.checkColor = [UIColor flatGrayColor];
        self.wifiCheckbox.radius = 0.0;
        [checkbox addSubview:self.wifiCheckbox];
        [cell.contentView addSubview:checkbox];

    }
    if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Tables";
        
        self.tablesCheckbox = [[M13Checkbox alloc] init];
        [self.tablesCheckbox setValue:[NSNumber numberWithBool:YES] forKeyPath:@"checkedValue"];
        [self.tablesCheckbox setValue:[NSNumber numberWithBool:NO] forKeyPath:@"uncheckedValue"];

        self.tablesCheckbox.frame = CGRectMake(0, 0, self.tablesCheckbox.frame.size.width, self.tablesCheckbox.frame.size.height);
        self.tablesCheckbox.flat = YES;
        self.tablesCheckbox.strokeWidth = 0.5;
        self.tablesCheckbox.strokeColor =  [UIColor colorWithRed:0.625 green:0.627 blue:0.657 alpha:0.900];
        self.tablesCheckbox.checkColor = [UIColor flatGrayColor];
        self.tablesCheckbox.radius = 0.0;
        [checkbox addSubview:self.tablesCheckbox];
        [cell.contentView addSubview:checkbox];

    }
    if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Outlets";
        
        self.outletsCheckbox = [[M13Checkbox alloc] init];
        [self.outletsCheckbox setValue:[NSNumber numberWithBool:YES] forKeyPath:@"checkedValue"];
        [self.outletsCheckbox setValue:[NSNumber numberWithBool:NO] forKeyPath:@"uncheckedValue"];

        self.outletsCheckbox.frame = CGRectMake(0, 0, self.outletsCheckbox.frame.size.width, self.outletsCheckbox.frame.size.height);
        self.outletsCheckbox.flat = YES;
        self.outletsCheckbox.strokeWidth = 0.5;
        self.outletsCheckbox.strokeColor =  [UIColor colorWithRed:0.625 green:0.627 blue:0.657 alpha:0.900];
        self.outletsCheckbox.checkColor = [UIColor flatGrayColor];
        self.outletsCheckbox.radius = 0.0;
        [checkbox addSubview:self.outletsCheckbox];
        [cell.contentView addSubview:checkbox];

    }
    if (indexPath.row == 4)
    {
        cell.textLabel.text = @"Food";
        
        self.foodCheckbox = [[M13Checkbox alloc] init];
        [self.foodCheckbox setValue:[NSNumber numberWithBool:YES] forKeyPath:@"checkedValue"];
        [self.foodCheckbox setValue:[NSNumber numberWithBool:NO] forKeyPath:@"uncheckedValue"];

        self.foodCheckbox.frame = CGRectMake(0, 0, self.foodCheckbox.frame.size.width, self.foodCheckbox.frame.size.height);
        self.foodCheckbox.flat = YES;
        self.foodCheckbox.strokeWidth = 0.5;
        self.foodCheckbox.strokeColor =  [UIColor colorWithRed:0.625 green:0.627 blue:0.657 alpha:0.900];
        self.foodCheckbox.checkColor = [UIColor flatGrayColor];
        self.foodCheckbox.radius = 0.0;
        [checkbox addSubview:self.foodCheckbox];
        [cell.contentView addSubview:checkbox];

    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    if (indexPath.row == 0)
    {
        [self.quietCheckbox toggleCheckState];
    }
    if (indexPath.row == 1)
    {
        [self.wifiCheckbox toggleCheckState];
    }
    if (indexPath.row == 2)
    {
        [self.tablesCheckbox toggleCheckState];
    }
    if (indexPath.row == 3)
    {
        [self.outletsCheckbox toggleCheckState];
    }
    if (indexPath.row == 4)
    {
        [self.foodCheckbox toggleCheckState];
    }
}

- (void)done
{
    self.amenities = [NSArray arrayWithObjects:self.quietCheckbox.value, self.wifiCheckbox.value ,self.outletsCheckbox.value ,self.tablesCheckbox.value ,self.foodCheckbox.value, nil];
    [self.delegate addItemViewController:self didFinishEnteringAmenities:self.amenities];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end
