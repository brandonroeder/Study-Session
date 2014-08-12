//
//  DescriptionViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 8/11/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DescriptionViewController;
@protocol DescriptionViewControllerDelegate <NSObject>
- (void)addItemViewController:(DescriptionViewController *)controller didFinishEnteringItem:(NSString *)item;
@end

@interface DescriptionViewController : UIViewController
@property (nonatomic, weak) id <DescriptionViewControllerDelegate> delegate;
@property (strong, nonatomic) UITextView *descriptionText;
@property (strong, nonatomic) NSString *oldText;
@end
