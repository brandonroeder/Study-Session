//
//  SessionParallaxViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/29/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "SessionParallaxViewController.h"
#import "SessionViewController.h"
#import "MDCParallaxView.h"
#import "GeoPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "UIColor+FlatColors.h"
#import <MapKit/MapKit.h>

@interface SessionParallaxViewController () <UIScrollViewDelegate, MKMapViewDelegate>
@property (strong, nonatomic) UIView *joinSessionView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *joinButton;
@property (strong, nonatomic) SessionViewController *sessionViewController;
@end

@implementation SessionParallaxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.detailItem[@"name"];
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 400)];
    self.mapView.delegate= self;
    [self setupMap];
    
    self.joinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 505, 240, 44)];
    self.joinSessionView= [[UIView alloc] initWithFrame:CGRectMake(0, 505, 240, 44)];
    self.joinButton.frame = CGRectMake(0, 505, 240, 44);
    [self.joinButton addTarget:self
                     action:@selector(joinSession)
           forControlEvents:UIControlEventTouchUpInside];

    self.joinButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-40);
    self.joinButton.alpha = 0.9;
    self.joinButton.layer.cornerRadius = 2;
    //[self.joinButton setTitle:@"Create Session" forState:UIControlStateNormal];
    
    self.joinButton.backgroundColor = [UIColor flatBlueColor];

    self.sessionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionViewController"];
    [self.sessionViewController setDetailItem:self.detailItem];
    
    
    MDCParallaxView *parallaxView = [[MDCParallaxView alloc] initWithBackgroundView:self.mapView
                                                                     foregroundView:self.sessionViewController.view];
    
    parallaxView.frame = self.view.bounds;
    parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    parallaxView.backgroundHeight = 250.0f;
    parallaxView.scrollView.scrollsToTop = YES;
    parallaxView.backgroundInteractionEnabled = YES;
    parallaxView.scrollViewDelegate = self;
    [self.view addSubview:parallaxView];
    [self.view addSubview:self.joinButton];
    [self configureBottomButton];
}

- (void)setupMap
{
    PFGeoPoint *geoPoint = self.detailItem[@"location"];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.005f, 0.005f));
    
    // add the annotation
    GeoPointAnnotation *annotation = [[GeoPointAnnotation alloc] initWithObject:self.detailItem];
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *GeoPointAnnotationIdentifier = @"RedPin";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointAnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        annotationView.image = [UIImage imageNamed:@"Map_Icon"];
    }
    
    return annotationView;
}

- (BOOL)isSessionCreator
{
    NSString *currentUser = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
    NSString *sessionCreator= self.detailItem[@"email"];
    
    if ([currentUser isEqualToString: sessionCreator])
    {
        return YES;
    }
    else
        return NO;
}

- (void)configureBottomButton
{
    self.joinButton.titleLabel.textColor = [UIColor whiteColor];
    self.joinButton.titleLabel.font = [UIFont fontWithName:@"Helvetica- Thin" size:20];
    
    if ([self isSessionCreator])
    {
        self.joinButton.backgroundColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000];
        [self.joinButton setTitle:@"Delete Session" forState:UIControlStateNormal];
    }
    
    if ([self isSessionMember] && (![self isSessionCreator]))
    {
        self.joinButton.backgroundColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000];
        [self.joinButton setTitle:@"Leave Session" forState:UIControlStateNormal];
    }
    else if (![self isSessionMember] && (![self isSessionCreator]))
    {
        self.joinButton.backgroundColor= [UIColor colorWithRed:0.153 green:0.682 blue:0.376 alpha:1.000];
        [self.joinButton setTitle:@"Join Session" forState:UIControlStateNormal];
    }
    
    
    
}



- (void)joinSession
{
    NSString *user = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
    
    PFACL *placeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    [placeACL setPublicReadAccess:YES];
    [placeACL setPublicWriteAccess:YES];
    self.detailItem.ACL = placeACL;
    
    
    if ([self isSessionCreator])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you really want to delete this session?" message:@"This cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Yes"];
        [alert show];
    }
    else if ([self isSessionMember]) //leave session
    {
        [self.joinButton setTitle:@"Join Session" forState:UIControlStateNormal];
        self.joinButton.backgroundColor= [UIColor colorWithRed:0.153 green:0.682 blue:0.376 alpha:1.000];
        [self.detailItem removeObject:user forKey:@"members"];
        [self.detailItem saveInBackground];
    }
    
    else
    {
        [self.joinButton setTitle:@"Leave Session" forState:UIControlStateNormal];
        self.joinSessionView.backgroundColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000];
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
             {
                 if (!error){
                     NSDictionary *userData = (NSDictionary *)result;
                     NSString *facebookID = userData[@"id"];
                     NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                     [self.detailItem addObject:pictureURL forKey:@"facebookPictureURL"];
                 }
             }];
        }
        [self.detailItem addObject:user forKey:@"members"];
        [self.detailItem saveInBackground];
    }
}


-(BOOL)isSessionMember
{
    NSArray *members = [self.detailItem objectForKey:@"members"];
    NSString *memberEmail = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
    if ([members containsObject:memberEmail])
    {
        return YES;
    }
    else
        return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex  ==  1)
    {
        NSString *user = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
        
        [self.detailItem removeObject:user forKey:@"members"];
        [self.detailItem saveInBackground];
        [self.detailItem deleteInBackground];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


@end
