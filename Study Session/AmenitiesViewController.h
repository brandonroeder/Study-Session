//
//  AmenitiesViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 8/13/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AmenitiesViewController;
@protocol AmenitiesViewControllerDelegate <NSObject>
- (void)addItemViewController:(AmenitiesViewController *)controller didFinishEnteringAmenities:(NSArray *)arrayOfAmenities;
@end

@interface AmenitiesViewController : UIViewController
@property (nonatomic, weak) id <AmenitiesViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *amenities;
@end
