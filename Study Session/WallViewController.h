//
//  WallViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface WallViewController : PFQueryTableViewController <CLLocationManagerDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logout;
- (void)setInitialLocation:(CLLocation *)aLocation;

@end
