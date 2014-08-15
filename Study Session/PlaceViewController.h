//
//  PlaceViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 8/14/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LPGoogleFunctions.h"

@class PlaceViewController;
@protocol PlaceViewControllerDelegate <NSObject>
- (void)setPlace:(PlaceViewController *)controller didFinishSelectingLocation:(LPPlaceDetails *)placeDetails;
@end

@interface PlaceViewController : UIViewController
@property (nonatomic, weak) id <PlaceViewControllerDelegate> delegate;
@property (nonatomic, strong) LPPlaceDetails *placeDetails;
@end
