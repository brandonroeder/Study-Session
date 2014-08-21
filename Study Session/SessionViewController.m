//
//  SessionViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 7/6/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "SessionViewController.h"
#import "WallViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+FlatColors.h"
#import "GeoPointAnnotation.h"
#import "UIImageView+Letters.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "AFTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <FontasticIcons.h>
#import <EventKitUI/EventKitUI.h>
static CGFloat kImageOriginHight = 140.f;

@interface SessionViewController () <UICollisionBehaviorDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *avatar1;
@property (strong, nonatomic) UIImageView *avatar2;
@property (strong, nonatomic) UIImageView *avatar3;
@property (strong, nonatomic) UIImageView *avatar4;
@property (strong, nonatomic) UIImageView *avatar5;
@property (strong, nonatomic) UIImageView *avatar6;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSString *memberEmail;
@property (strong, nonatomic) UIView *joinSessionView;
@property (strong, nonatomic) UIButton *joinButton;
@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSArray *colorArray;


@end

@implementation SessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMap];

    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateStyle:NSDateFormatterLongStyle];

    self.tableView.contentInset = UIEdgeInsetsMake(kImageOriginHight, 0, 0, 0);
    [self.tableView addSubview:self.mapView];
    self.tableView.showsVerticalScrollIndicator= NO;
    
    self.joinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 568, self.view.frame.size.width, 44)];
    self.joinSessionView= [[UIView alloc] initWithFrame:CGRectMake(0, 568, self.view.frame.size.width, 44)];
    self.joinButton.frame = CGRectMake(0, 568, self.view.frame.size.width, 44);
    [self.joinButton addTarget:self
                        action:@selector(joinSession)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.joinButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-22);
    self.joinButton.alpha = 0.9;
    [self.view addSubview:self.joinButton];
    self.title = self.detailItem[@"name"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];

    [self configureBottomButton];
    [self collectionStuff];
}

- (void)collectionStuff
{
    const NSInteger numberOfCollectionViewCells = 15;
    const NSInteger numberOfTableViewRows = 20;

    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.tableView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.mapView.frame = CGRectMake(0, -kImageOriginHight, self.tableView.frame.size.width, kImageOriginHight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -kImageOriginHight)
    {
        CGRect f = self.mapView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset;
        self.mapView.frame = f;
    }
    
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) //details
    {
        return 3;
    }
    else if (section == 3) //amenities
    {
        return 5;
    }
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) //Description
    {
        return 70;
    }
    if (indexPath.section == 2) //Members
    {
        return 66;
    }
    if (indexPath.section == 3) //Amenities
    {
        return 44;
    }
    
    if (indexPath.section == 4) //Other
    {
        return 100;
    }
    if (indexPath.section == 5) //More other
    {
        return 100;
    }
    else
        return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =[[UIView alloc]init];
    headerView.backgroundColor= [UIColor colorWithWhite:0.953 alpha:1.000];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    headerLabel.textColor = [UIColor colorWithWhite:0.348 alpha:1.000];
    [headerLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    if (section == 0)
        headerLabel.text= @"  DESCRIPTION";
    if (section == 1)
        headerLabel.text= @"  DETAILS";
    if (section == 2)
        headerLabel.text= @"  MEMBERS";
    if (section == 3)
        headerLabel.text = @"  AMENITIES";
    if (section == 4)
        headerLabel.text = @"  OTHER SHIT";
    if (section == 5)
        headerLabel.text = @"  MORE OTHER SHIT";
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void) share
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CellIdentifier";
    
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    }
//    static NSString *CellIdentifier = @"CellIdentifier";
    
    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    cell.clipsToBounds = YES;
    
    //view for avatars (helps contain them for gravity and fade in shit)
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 48)];
    backView.alpha = 0;
    
    cell.textLabel.text = @"";
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica- Thin" size:17];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
    
    if (indexPath.section == 0)
    {
        UITextView *sessionDetails= [[UITextView alloc]initWithFrame:CGRectMake(15,0,cell.contentView.frame.size.width - 15, 70)];
        [sessionDetails setScrollEnabled:NO];
        [sessionDetails setSelectable:NO];
        sessionDetails.text = self.detailItem[@"description"];
        sessionDetails.font = [UIFont fontWithName:@"Helvetica" size:16];
        sessionDetails.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:sessionDetails];
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            FIIcon *icon = [FIEntypoIcon bookIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            
            NSString *subject = self.detailItem[@"subject"];
            cell.textLabel.text = subject;
            cell.textLabel.textColor = [UIColor flatGrayColor];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }

        if (indexPath.row == 1)
        {
            FIIcon *icon = [FIEntypoIcon calendarIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];

            self.date = self.detailItem[@"date"];
        
            cell.textLabel.text = [self.formatter stringFromDate:self.date];
            cell.textLabel.textColor = [UIColor flatGrayColor];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            
        }
        if (indexPath.row == 2)
        {
            FIIcon *icon = [FIEntypoIcon clockIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm a"];

            self.startTime = self.detailItem[@"startTime"];
            self.endTime= self.detailItem[@"endTime"];
            NSString *arrow = @"→";
            NSString *formattedTimeString = [NSString stringWithFormat:@"%@ %@ %@", [dateFormatter stringFromDate:self.startTime], arrow, [dateFormatter stringFromDate:self.endTime]];

            cell.textLabel.text = formattedTimeString;
            cell.textLabel.textColor = [UIColor flatGrayColor];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    if (indexPath.section == 3)
    {
        UILabel *amenitiesBool = [[UILabel alloc]initWithFrame:CGRectMake(cell.contentView.frame.size.width-50, 10, 200, 20)];
        amenitiesBool.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:amenitiesBool];
        if (indexPath.row == 0)
        {
            FIIcon *icon = [FIEntypoIcon muteIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            amenitiesBool.text = (self.detailItem[@"quiet"]) ? @"Yes" : @"No";
            cell.textLabel.text = @"Quiet";
        }
        if (indexPath.row == 1)
        {
            FIIcon *icon = [FIEntypoIcon monitorIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            amenitiesBool.text = (self.detailItem[@"tables"]) ? @"Yes" : @"No";
            cell.textLabel.text = @"Tables";
        }
        if (indexPath.row == 2)
        {
            FIIcon *icon = [FIEntypoIcon batteryIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            amenitiesBool.text = (self.detailItem[@"outlets"]) ? @"Yes" : @"No";
            cell.textLabel.text = @"Outlets";
        }
        if (indexPath.row == 3)
        {
            FIIcon *icon = [FIEntypoIcon signalIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            amenitiesBool.text = (self.detailItem[@"wifi"]) ? @"Yes" : @"No";
            cell.textLabel.text = @"WiFi";
        }
        if (indexPath.row == 4)
        {
            FIIcon *icon = [FIEntypoIcon cartIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
            [cell.imageView setImage:image];
            amenitiesBool.text = (self.detailItem[@"Food"]) ? @"Yes" : @"No";
            cell.textLabel.text = @"Food";
        }
        
    }
    
    if (indexPath.section == 4)
    {
        UITextView *sessionDetails1 = [[UITextView alloc]initWithFrame:CGRectMake(0,0,cell.contentView.frame.size.width, 100)];
        [sessionDetails1 setScrollEnabled:NO];
        [sessionDetails1 setSelectable:NO];
        sessionDetails1.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas augue at sapien malesuada commodo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas augue at sapien malesuada commodo.";
        sessionDetails1.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:sessionDetails1];
    }
    
    if (indexPath.section == 5)
    {
        UITextView *sessionDetails1 = [[UITextView alloc]initWithFrame:CGRectMake(0,0,cell.contentView.frame.size.width, 100)];
        [sessionDetails1 setScrollEnabled:NO];
        [sessionDetails1 setSelectable:NO];
        sessionDetails1.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas augue at sapien malesuada commodo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas augue at sapien malesuada commodo.";
        sessionDetails1.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:sessionDetails1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSArray *sessionMembers = [self.detailItem objectForKey:@"members"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1)
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Add Session to Calendar",
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }

    PFACL *placeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [placeACL setPublicReadAccess:YES];
    [placeACL setPublicWriteAccess:YES];
    self.detailItem.ACL = placeACL;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        NSInteger index = cell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *memberAvatarsArray = [self.detailItem objectForKey:@"facebookPictureURL"];
    return memberAvatarsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *memberAvatars = [self.detailItem objectForKey:@"facebookPictureURL"];
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:memberAvatars.count];
    
    self.avatar1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.avatar2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.avatar3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.avatar4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.avatar5 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.avatar6 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];

    
    cell.contentView.layer.cornerRadius = 20;
    cell.contentView.layer.masksToBounds = YES;


    for(int i = 0; i < memberAvatars.count; i++)
    {
        NSURL* url = [NSURL URLWithString:memberAvatars[i]];
        
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image)
         {
             if (succeeded)
             {
                 [images addObject:image];
                 if (i == (memberAvatars.count - 1))
                 {
                     if (memberAvatars.count >=6)
                     {
                         self.avatar1.image = [images objectAtIndex:0];
                         self.avatar2.image = [images objectAtIndex:1];
                         self.avatar3.image = [images objectAtIndex:2];
                         self.avatar4.image = [images objectAtIndex:3];
                         self.avatar5.image = [images objectAtIndex:4];
                         self.avatar6.image = [images objectAtIndex:5];
                     }
                     
                     switch (memberAvatars.count)
                     {
                         case 5:
                         {
                             self.avatar1.image = [images objectAtIndex:0];
                             self.avatar2.image = [images objectAtIndex:1];
                             self.avatar3.image = [images objectAtIndex:2];
                             self.avatar4.image = [images objectAtIndex:3];
                             self.avatar5.image = [images objectAtIndex:4];
                             
                             [self.avatar6 removeFromSuperview];
                         }
                         case 4:
                         {
                             self.avatar1.image = [images objectAtIndex:0];
                             self.avatar2.image = [images objectAtIndex:1];
                             self.avatar3.image = [images objectAtIndex:2];
                             self.avatar4.image = [images objectAtIndex:3];
                             
                             [self.avatar5 removeFromSuperview];
                             [self.avatar6 removeFromSuperview];
                         }
                         case 3:
                         {
                             self.avatar1.image = [images objectAtIndex:0];
                             self.avatar2.image = [images objectAtIndex:1];
                             self.avatar3.image = [images objectAtIndex:2];
                             
                             [self.avatar4 removeFromSuperview];
                             [self.avatar5 removeFromSuperview];
                             [self.avatar6 removeFromSuperview];
                         }
                         case 2:
                         {
                             self.avatar1.image = [images objectAtIndex:0];
                             self.avatar2.image = [images objectAtIndex:1];
                             
                             [self.avatar3 removeFromSuperview];
                             [self.avatar4 removeFromSuperview];
                             [self.avatar5 removeFromSuperview];
                             [self.avatar6 removeFromSuperview];
                         }
                         case 1:
                         {
                             self.avatar1.image = [images objectAtIndex:0];
                             
                             [self.avatar2 removeFromSuperview];
                             [self.avatar3 removeFromSuperview];
                             [self.avatar4 removeFromSuperview];
                             [self.avatar5 removeFromSuperview];
                             [self.avatar6 removeFromSuperview];
                         }
                     }

                     if (indexPath.item == 0)
                     {
                         [cell.contentView addSubview:self.avatar1];
                     }
                     if (indexPath.item == 1)
                     {
                         [cell.contentView addSubview:self.avatar2];
                     }
                     if (indexPath.item == 2)
                     {
                         [cell.contentView addSubview:self.avatar3];
                     }
                     if (indexPath.item == 3)
                     {
                         [cell.contentView addSubview:self.avatar4];
                     }
                     if (indexPath.item == 4)
                     {
                         [cell.contentView addSubview:self.avatar5];
                     }
                     if (indexPath.item == 5)
                     {
                         [cell.contentView addSubview:self.avatar6];
                     }
                 }
             }
         }];
    }
    return cell;
}


- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (!error)
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               }
                               else
                               {
                                   completionBlock(NO,nil);
                               }
                           }];
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

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag)
    {
        case 1: {
            switch (buttonIndex)
            {
                case 0:
                    [SVProgressHUD showSuccessWithStatus:@"Added!"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self addSessionToCalendar];
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                    });

                    break;
            }
            break;
        }
        default:
            break;
    }
}


- (void)addSessionToCalendar
{
    EKEventStore *eventStore=[[EKEventStore alloc] init];
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
    {
         if (granted)
         {
             EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
             //Create the end date components
//             NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
//             
//             NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
//                                                                             toDate:startDate
//                                                                            options:0];
             
             event.title =self.detailItem[@"name"];
             event.startDate = self.date;
             event.notes = self.detailItem[@"description"];
             
             [event setCalendar:[eventStore defaultCalendarForNewEvents]];
             
             NSError *err;
             [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
         }
         else
         {
             NSLog(@"NoPermission to access the calendar");
         }
         
     }];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor flatBlueColor];
            NSString *buttonText = button.titleLabel.text;
            if ([buttonText isEqualToString:NSLocalizedString(@"Cancel", nil)])
            {
                button.titleLabel.textColor = [UIColor flatRedColor];
            }
        }
    }];
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
                 if (!error)
                 {
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDetailItem:self.detailItem];
}

@end