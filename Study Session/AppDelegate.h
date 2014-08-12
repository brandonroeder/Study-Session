//
//  AppDelegate.h
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//
static double const kPAWFeetToMeters = 0.3048; // this is an exact value.
static double const kPAWFeetToMiles = 5280.0; // this is an exact value.
static double const kPAWWallPostMaximumSearchDistance = 100.0;
static double const kPAWMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kPAWWallPostsSearch = 20; // query limit for pins and tableviewcells

// Parse API key constants:
static NSString * const kPAWParsePostsClassKey = @"Posts";
static NSString * const kPAWParseUserKey = @"user";
static NSString * const kPAWParseUsernameKey = @"username";
static NSString * const kPAWParseTextKey = @"text";
static NSString * const kPAWParseLocationKey = @"location";

// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";

// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
