//
//  WallViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "WallViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "GeoPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "NewSessionViewController.h"
#import "SessionViewController.h"
#import "UIImage+ImageEffects.h"
#import "CircleOverlay.h"
#import <FacebookSDK/FacebookSDK.h>
#import <POP/POP.H>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface WallViewController ()
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation WallViewController

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"geoPointAnnotiationUpdated" object:nil];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
        self.parseClassName = @"PlaceObject";
        self.textKey = @"name";
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    self.view.backgroundColor = [UIColor whiteColor];
    [self refreshControl];
    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self loadObjects];

}

- (void)objectsWillLoad
{
    [super objectsWillLoad];
    
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    [self.tableView reloadData];

}

- (PFQuery *)queryForTable
{
    self.radius = 20000;
    CGFloat miles = self.radius/1000.0f;
    
    PFQuery *query = [PFQuery queryWithClassName:@"PlaceObject"];
    
    if (self.objects.count == 0)
    {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

//    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
//                                               longitude:self.location.coordinate.longitude];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:32.985678
                                               longitude:-96.755612];
    [query whereKey:kPAWParseLocationKey nearGeoPoint:point withinMiles:miles];
    [query includeKey:kPAWParseUserKey];
    return query;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    if (!cell){
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSArray *members = object[@"members"];
                              
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-31, cell.contentView.frame.size.width-10, cell.contentView.frame.size.height)];
    
    
    rightLabel.text = [NSString stringWithFormat:@"%d members", members.count];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.textColor= [UIColor blackColor];
    rightLabel.font= [UIFont fontWithName:@"CircularAir-Book" size:11];
    
    cell.textLabel.text = object[@"name"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"CircularAir-Book" size:17];
    
    cell.detailTextLabel.text = object[@"subject"];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"CircularAir-Book" size:11];
    cell.backgroundColor = [UIColor whiteColor];

    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel sizeToFit];
    [cell.textLabel setContentMode:UIViewContentModeCenter];

    [cell.contentView addSubview:rightLabel];
    
    //GeoPointAnnotation *annotation = [[GeoPointAnnotation alloc] initWithObject:object];
    //[self.mapView addAnnotation:annotation];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //PFObject *object = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toSession" sender:self];
}

- (CLLocationManager *)locationManager
{
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.delegate = self;
    return _locationManager;
}

- (void)setInitialLocation:(CLLocation *)aLocation
{
    self.location = aLocation;
    self.radius = 1000;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSession"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [segue.destinationViewController setDetailItem:object];
    }
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (IBAction)newSession:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewSessionViewController *newSessionViewController = [storyboard instantiateViewControllerWithIdentifier:@"NewSessionViewController"];
    newSessionViewController.navigationController.navigationBar.barTintColor= [UIColor whiteColor];
    [[self navigationController] pushViewController: newSessionViewController animated:YES];
}
@end
