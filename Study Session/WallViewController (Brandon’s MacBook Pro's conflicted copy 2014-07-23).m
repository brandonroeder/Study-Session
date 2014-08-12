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
#import "SignupViewController.h"
#import "SessionViewController.h"
#import "SessionViewController.h"
#import "UIImage+ImageEffects.h"
#import <FacebookSDK/FacebookSDK.h>
#import <POP/POP.H>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface WallViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) UIImage *avatarImage;
@end

@implementation WallViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
        self.parseClassName = @"PlaceObject";
        self.textKey = @"name";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [PFFacebookUtils initializeFacebook];
    self.avatarImage = nil;
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (!error){
             NSDictionary *userData = (NSDictionary *)result;
             NSString *facebookID = userData[@"id"];
             NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
             NSString *facebookEmail = [result objectForKey:@"email"];
             [PFUser currentUser].email = facebookEmail;
             [[PFUser currentUser] saveEventually];

             dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                 self.avatarImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:pictureURL]];
                 dispatch_async(dispatch_get_main_queue(), ^(void){
                     [self addAvatarAnimation];
                 });
             });
         }
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self loadObjects];
    [self.tableView reloadData];
}

- (void)objectsWillLoad
{
    [super objectsWillLoad];
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
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
    rightLabel.textColor=  [UIColor colorWithWhite:0.161 alpha:1.000];
    rightLabel.font= [UIFont fontWithName:@"Helvetica" size:11];

    
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
    [cell.contentView addSubview:rightLabel];
    
    GeoPointAnnotation *annotation = [[GeoPointAnnotation alloc] initWithObject:object];
    [self.mapView addAnnotation:annotation];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
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

    if (!annotationView){
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
    //[self performSegueWithIdentifier:@"newSession" sender:self];
    SignupViewController *signupVC = [[SignupViewController alloc] initWithStyle:UITableViewStylePlain];
    signupVC.navigationController.navigationBar.barTintColor= [UIColor whiteColor];
    [[self navigationController] pushViewController: signupVC animated:YES];
}

- (void)goToSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

- (void) addAvatarAnimation
{
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];// Here you can set View width and height as per your requirement for displaying titleImageView position in navigationbar
    backView.layer.frame = CGRectMake(0, 0, 10, 10);
    UIButton *button = [[UIButton alloc]init];
    [button setImage:self.avatarImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 40, 40);
    [backView addSubview:button];
    
    self.navigationItem.titleView = backView;
    
    POPSpringAnimation *appearAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.velocity = @100;
    positionAnimation.springBounciness = 1;
    positionAnimation.springSpeed = 15;
    appearAnimation.toValue= [NSValue valueWithCGSize:CGSizeMake(40, 40)]; //first 2 values dont matter
    self.navigationItem.titleView.layer.cornerRadius = 20;
    self.navigationItem.titleView.clipsToBounds = YES;
    
    [appearAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished){
        [self.navigationItem.titleView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    }];
    [backView.layer pop_addAnimation:appearAnimation forKey:@"appearAnimation"];
}
@end
