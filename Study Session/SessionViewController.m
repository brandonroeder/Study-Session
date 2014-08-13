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
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
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

@property NSIndexPath *expandedRow;
@property BOOL isExpanded;
@end

@implementation SessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMap];

    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.424 green:0.476 blue:0.479 alpha:0.900]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
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
    self.joinButton.alpha = 0.5;
    [self.view addSubview:self.joinButton];
    [self configureBottomButton];
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 70;
    }

    if (self.isExpanded)
    {
        if ([indexPath isEqual:self.expandedRow])
        {
            return 300;
        }
    }
    else if (!self.isExpanded)
    {
        if ([indexPath isEqual:self.expandedRow])
        {
            return 48;
        }
    }
    if (indexPath.section == 3)
    {
        return 130;
    }
    
    if (indexPath.section == 4)
    {
        return 100;
    }
    if (indexPath.section == 5)
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
        headerLabel.text= @"  TIME";
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
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
        UITextView *sessionDetails= [[UITextView alloc]initWithFrame:CGRectMake(0,0,cell.contentView.frame.size.width, 70)];
        [sessionDetails setScrollEnabled:NO];
        [sessionDetails setSelectable:NO];
        sessionDetails.text = self.detailItem[@"description"];
        sessionDetails.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:sessionDetails];
    }
    if (indexPath.section == 1)
    {
        cell.textLabel.text = self.detailItem[@"time"];
        cell.textLabel.textColor = [UIColor flatGrayColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if (indexPath.section == 2)
    {
        NSArray *memberAvatars = [self.detailItem objectForKey:@"facebookPictureURL"];
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:memberAvatars.count];
        
        self.avatar1 = [[UIImageView alloc] init];
        self.avatar2 = [[UIImageView alloc]init ];
        self.avatar3 = [[UIImageView alloc] init];
        self.avatar4 = [[UIImageView alloc] init];
        self.avatar5 = [[UIImageView alloc] init];
        self.avatar6 = [[UIImageView alloc] init];

        for(int i = 0; i < memberAvatars.count; i++)
        {
            NSURL* url = [NSURL URLWithString:memberAvatars[i]];
        
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image)
        {
            if (succeeded)
            {
                [images addObject:image];
                
                //fade in avatars
                [UIView animateWithDuration:0.5 animations:^{backView.alpha = 1.0;}];

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
                }
            }
        }];
    }

        //so they're in the right spot if user scrolls down far
        if (self.isExpanded)
        {
            self.avatar1.frame = CGRectMake(4,5,40,40);
            self.avatar2.frame = CGRectMake(4,55,40,40);
            self.avatar3.frame = CGRectMake(4,105,40,40);
            self.avatar4.frame = CGRectMake(4,155,40,40);
            self.avatar5.frame = CGRectMake(4,205,40,40);
            self.avatar6.frame = CGRectMake(4,255,40,40);
        }
        else
        {
            self.avatar1.frame = CGRectMake(4,5,40,40);
            self.avatar2.frame = CGRectMake(54,5,40,40);
            self.avatar3.frame = CGRectMake(104,5,40,40);
            self.avatar4.frame = CGRectMake(154,5,40,40);
            self.avatar5.frame = CGRectMake(204,5,40,40);
            self.avatar6.frame = CGRectMake(254,5,40,40);

        }


        for (UIView *backView in cell.contentView.subviews)
        {
            if ([backView isKindOfClass:[UIView class]])
            {
                [backView removeFromSuperview];
            }
        }
        
        [backView addSubview: self.avatar1];
        [backView addSubview: self.avatar2];
        [backView addSubview: self.avatar3];
        [backView addSubview: self.avatar4];
        [backView addSubview: self.avatar5];
        [backView addSubview: self.avatar6];


        
        [cell.contentView addSubview:backView];
        
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:cell.contentView];
        [self configureAvatars];
    }
    
    if (indexPath.section == 3)
    {
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
    if (indexPath.section == 2)
    {
        self.expandedRow = indexPath;
        if (self.isExpanded)
        {
            self.isExpanded = NO;
            [self.animator removeAllBehaviors];
            [self snapAvatarCompress];
        }
        else
        {
            self.isExpanded = YES;
            [self.animator removeAllBehaviors];
            [self snapAvatarExpand];
        }

        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }

    PFACL *placeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [placeACL setPublicReadAccess:YES];
    [placeACL setPublicWriteAccess:YES];
    self.detailItem.ACL = placeACL;
    
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

- (void)snapAvatarExpand
{
    UISnapBehavior *snapBehavior1 = [[UISnapBehavior alloc] initWithItem:self.avatar1
                                                            snapToPoint:CGPointMake(24, 24)];
    UISnapBehavior *snapBehavior2 = [[UISnapBehavior alloc] initWithItem:self.avatar2
                                                            snapToPoint:CGPointMake(24, 74)];
    UISnapBehavior *snapBehavior3 = [[UISnapBehavior alloc] initWithItem:self.avatar3
                                                            snapToPoint:CGPointMake(24, 124)];
    UISnapBehavior *snapBehavior4 = [[UISnapBehavior alloc] initWithItem:self.avatar4
                                                             snapToPoint:CGPointMake(24, 174)];
    UISnapBehavior *snapBehavior5 = [[UISnapBehavior alloc] initWithItem:self.avatar5
                                                             snapToPoint:CGPointMake(24, 224)];
    UISnapBehavior *snapBehavior6 = [[UISnapBehavior alloc] initWithItem:self.avatar6
                                                             snapToPoint:CGPointMake(24, 274)];
    [self.animator addBehavior:snapBehavior1];
    [self.animator addBehavior:snapBehavior2];
    [self.animator addBehavior:snapBehavior3];
    [self.animator addBehavior:snapBehavior4];
    [self.animator addBehavior:snapBehavior5];
    [self.animator addBehavior:snapBehavior6];
}

- (void)snapAvatarCompress
{
    UISnapBehavior *compress1 = [[UISnapBehavior alloc] initWithItem:self.avatar1
                                                             snapToPoint:CGPointMake(24, 24)];
    UISnapBehavior *compress2 = [[UISnapBehavior alloc] initWithItem:self.avatar2
                                                             snapToPoint:CGPointMake(76, 24)];
    UISnapBehavior *compress3 = [[UISnapBehavior alloc] initWithItem:self.avatar3
                                                             snapToPoint:CGPointMake(126, 24)];
    UISnapBehavior *compress4 = [[UISnapBehavior alloc] initWithItem:self.avatar4
                                                             snapToPoint:CGPointMake(176, 24)];
    UISnapBehavior *compress5 = [[UISnapBehavior alloc] initWithItem:self.avatar5
                                                             snapToPoint:CGPointMake(226, 24)];
    UISnapBehavior *compress6 = [[UISnapBehavior alloc] initWithItem:self.avatar6
                                                             snapToPoint:CGPointMake(276, 24)];
    
    [self.animator addBehavior:compress1];
    [self.animator addBehavior:compress2];
    [self.animator addBehavior:compress3];
    [self.animator addBehavior:compress4];
    [self.animator addBehavior:compress5];
    [self.animator addBehavior:compress6];

}

- (void) configureAvatars
{
    self.avatar1.layer.cornerRadius = 20;
    self.avatar1.layer.masksToBounds = YES;
    self.avatar2.layer.cornerRadius = 20;
    self.avatar2.layer.masksToBounds = YES;
    self.avatar3.layer.cornerRadius = 20;
    self.avatar3.layer.masksToBounds = YES;
    self.avatar4.layer.cornerRadius = 20;
    self.avatar4.layer.masksToBounds = YES;
    self.avatar5.layer.cornerRadius = 20;
    self.avatar5.layer.masksToBounds = YES;
    self.avatar6.layer.cornerRadius = 20;
    self.avatar6.layer.masksToBounds = YES;
    
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
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
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
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
         if (granted)
         {
             EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
             NSDate *startDate = [NSDate date];
             //Create the end date components
             NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
             tomorrowDateComponents.day = 1;
             
             NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                             toDate:startDate
                                                                            options:0];
             
             event.title =self.detailItem[@"name"];
             event.startDate=startDate;
             event.endDate=endDate;
             event.notes = self.description;
             event.allDay=YES;
             
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
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor flatBlueColor];
            NSString *buttonText = button.titleLabel.text;
            if ([buttonText isEqualToString:NSLocalizedString(@"Cancel", nil)]) {
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDetailItem:self.detailItem];
}

@end