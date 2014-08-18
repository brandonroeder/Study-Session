//
//  WallMapViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/29/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "WallMapViewController.h"
#import "NewSessionViewController.h"
#import "GeoPointAnnotation.h"
#import <FacebookSDK/FacebookSDK.h>
#import <POP/POP.H>
#import "LoginViewController.h"
#import "GeoQueryAnnotation.h"
#import "WallViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <FontasticIcons.h>

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface WallMapViewController ()

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation WallMapViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    
    self.mapView.region = MKCoordinateRegionMake(self.locationManager.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    //self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(32.985678, -96.755612),MKCoordinateSpanMake(0.05f, 0.05f));
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    WallViewController *wallViewController = [storyboard instantiateViewControllerWithIdentifier:@"WallViewController"];
    [self addChildViewController:wallViewController];
    wallViewController.view.frame = CGRectMake(0, 300.0f, 320, self.view.bounds.size.height - 275.0f);
    [self.view addSubview:wallViewController.view];
    
    FIIcon *gearIcon = [FIFontAwesomeIcon cogIcon];
    UIImage *gearImage = [gearIcon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor colorWithWhite:0.425 alpha:1.000]];

    FIIcon *addIcon = [FIFontAwesomeIcon plusIcon];
    UIImage *addImage = [addIcon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor colorWithWhite:0.425 alpha:1.000]];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:gearImage style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStylePlain target:self action:@selector(newSession:)];


    [PFFacebookUtils initializeFacebook];
    self.avatarImage = nil;
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (!error)
         {
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

    [self updateLocations];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
    self.mapView.region = MKCoordinateRegionMake(self.locationManager.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));

}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
//{
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.05;
//    span.longitudeDelta = 0.05;
//    CLLocationCoordinate2D location;
//    location.latitude = aUserLocation.coordinate.latitude;
//    location.longitude = aUserLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [mapView setRegion:region animated:YES];
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *GeoPointAnnotationIdentifier = @"RedPin";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointAnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        annotationView.animatesDrop = NO;
        //annotationView.image = [UIImage imageNamed:@"Map_Icon"];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView=detailButton;
    }
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]])
    {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView)
        {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.draggable = NO;
            //annotationView.image = [UIImage imageNamed:@"Map_Icon"];
            
        }
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[GeoPointAnnotation class]])
    {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"Map_Icon"];
            annotationView.animatesDrop = NO;
            annotationView.draggable = NO;
        }
    }
    return annotationView;
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


- (void)updateLocations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    
    self.radius = 20000;
    CGFloat miles = self.radius/1000.0f;
    
    PFQuery *query = [PFQuery queryWithClassName:@"PlaceObject"];
    [query setLimit:1000];
    [query whereKey:@"location"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                           longitude:self.location.coordinate.longitude]
        withinMiles:miles];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in objects)
             {
                 GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc]
                                                           initWithObject:object];
                 [self.mapView addAnnotation:geoPointAnnotation];
             }
         }
     }];    
}

- (IBAction)newSession:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewSessionViewController *newSessionViewController = [storyboard instantiateViewControllerWithIdentifier:@"NewSessionViewController"];
    [[self navigationController] pushViewController: newSessionViewController animated:YES];
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
    //self.navigationItem.titleView.layer.borderWidth = 1;
    //self.navigationItem.titleView.layer.borderColor= [[UIColor blackColor]CGColor];
    
    self.navigationItem.titleView.clipsToBounds = YES;
    
    [appearAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished){
        [self.navigationItem.titleView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    }];
    [backView.layer pop_addAnimation:appearAnimation forKey:@"appearAnimation"];
}

- (void)goToSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentViewController:navController animated:YES completion:nil];
    //[self presentViewController:settingsViewController animated:YES completion:nil];
}





@end
