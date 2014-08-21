//
//  SessionViewController.h
//  Study Session
//
//  Created by Brandon Roeder on 7/6/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SessionViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) PFObject *detailItem;

@end
