//
//  WallMapViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 7/29/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface WallMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)setInitialLocation:(CLLocation *)aLocation;

@end
