//
//  TestViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/21/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "TestViewController.h"
#import "WallViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "GeoPointAnnotation.h"
#import "SignupViewController.h"
#import "SessionViewController.h"
#import "SessionViewController.h"
#import "UIImage+ImageEffects.h"
#import <FacebookSDK/FacebookSDK.h>
#import <POP/POP.H>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface TestViewController ()
@property (strong, nonatomic) IBOutlet UIView *smallView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) PFQueryTableViewController *pftableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TestViewController

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
    
    
    self.tableView = [[PFQueryTableViewController alloc]init];
    self.pftableView.parseClassName = @"PlaceObject";
    self.pftableView.textKey = @"name";
    self.pftableView.pullToRefreshEnabled = YES;
    self.pftableView.paginationEnabled = YES;
    self.pftableView.objectsPerPage = 25;
    
    [self.pftableView loadObjects];
    
    [self addChildViewController:self.pftableView];               //  1
    [self.tableView addSubview:self.pftableView.view];                 //  2
    [self.pftableView didMoveToParentViewController:self];        //  3

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    if (!cell)
    {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = object[@"name"];
    cell.textLabel.textColor=  [UIColor colorWithWhite:0.161 alpha:1.000];
    cell.detailTextLabel.text = object[@"subject"];
    cell.detailTextLabel.textColor=  [UIColor colorWithWhite:0.161 alpha:1.000];
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel sizeToFit];
    [cell.textLabel setContentMode:UIViewContentModeCenter];
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1.5)];/// change size as you need.
    separatorLineView.backgroundColor = [UIColor colorWithRed:0.898 green:0.894 blue:0.898 alpha:1.000];// you can also put image here
    [cell.contentView addSubview:separatorLineView];
    
    
    //    PFGeoPoint *geoPoint = object[@"location"];
    //self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
    GeoPointAnnotation *annotation = [[GeoPointAnnotation alloc] initWithObject:object];
    [self.mapView addAnnotation:annotation];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [self.pftableView.objects objectAtIndex:indexPath.row];
    PFGeoPoint *geoPoint = object[@"location"];
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
    GeoPointAnnotation *annotation = [[GeoPointAnnotation alloc] initWithObject:object];
    [self.mapView addAnnotation:annotation];
    
    [self performSegueWithIdentifier:@"showSession" sender:self];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *GeoPointAnnotationIdentifier = @"RedPin";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointAnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        annotationView.image = [UIImage imageNamed:@"Map_Icon"];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView=detailButton;
    }
    return annotationView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSession"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.pftableView.objects objectAtIndex:indexPath.row];
        [segue.destinationViewController setDetailItem:object];
    }
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
