//
//  UsersViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/9/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "UsersViewController.h"
#import "MDCParallaxView.h"
#import "WallViewController.h"
#import <MapKit/MapKit.h>


@interface UsersViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@end

@implementation UsersViewController 

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
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    
    UIViewController *sampleMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    WallViewController *sampleBottomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WallViewController"];
    

    
    [self setupWithTopViewController:sampleMapViewController andTopHeight:300 andBottomViewController:sampleBottomViewController];

}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeTopHeight:(CGFloat)height{
    
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeGesture:(QMBParallaxGesture)newGesture oldGesture:(QMBParallaxGesture)oldGesture{
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sessionMembers = [self.detailItem objectForKey:@"members"];

    return sessionMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sessionMembers = [self.detailItem objectForKey:@"members"];
    
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier ];
    }
    
    cell.textLabel.text=  [NSString stringWithFormat:@"%@", [sessionMembers objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
