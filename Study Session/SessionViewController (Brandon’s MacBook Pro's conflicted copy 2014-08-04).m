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
#import "AFNetworking.h"
#import "NSString+Morphing.h"
#import "TOMSMorphingLabel.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>

@interface SessionViewController () <UICollisionBehaviorDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *avatar1;
@property (strong, nonatomic) UIImageView *avatar2;
@property (strong, nonatomic) UIImageView *avatar3;
@property (strong, nonatomic) UIImageView *avatar4;
@property (strong, nonatomic) UIImageView *avatar5;
@property (strong, nonatomic) UIImageView *avatar6;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *behavior;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSString *memberEmail;
@property (nonatomic, strong) TOMSMorphingLabel *label;
@property (weak, nonatomic) IBOutlet UIButton *joinSessionView;


@end

@implementation SessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    CGFloat dummyViewHeight = 40;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
    self.tableView.tableHeaderView = dummyView;
    self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);

    
    [self configureBottomButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    
    if (indexPath.section == 3)
    {
        return 140;
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
        headerLabel.text= @"DESCRIPTION";
    if (section == 1)
        headerLabel.text= @"TIME";
    if (section == 2)
        headerLabel.text= @"MEMBERS";
    if (section == 3)
        headerLabel.text = @"AMENITIES";
    if (section == 4)
        headerLabel.text = @"OTHER SHIT";
    if (section == 5)
        headerLabel.text = @"MORE OTHER SHIT";


    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    self.label = [[TOMSMorphingLabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
    
    self.label.textAlignment= NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
    
    //view for avatars (helps contain them for gravity and fade in shit)
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 48)];
    backView.alpha = 0;
    
    for (TOMSMorphingLabel *label in cell.contentView.subviews)
    {
        if ([label isKindOfClass:[TOMSMorphingLabel class]])
        {
            [label removeFromSuperview];
        }
    }
    
    [cell.contentView addSubview:self.label];
    
    cell.textLabel.text = @"";
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica- Thin" size:17];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
    
    if (indexPath.section == 0)
    {
        UITextView *sessionDetails= [[UITextView alloc]initWithFrame:CGRectMake(0,0,cell.contentView.frame.size.width, 70)];
        [sessionDetails setScrollEnabled:NO];
        [sessionDetails setSelectable:NO];
        sessionDetails.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas augue at sapien malesuada commodo.";
        sessionDetails.textColor = [UIColor flatGrayColor];
        [cell.contentView addSubview:sessionDetails];
    }
    if (indexPath.section == 1)
    {
        cell.textLabel.text = @"8:00pm - 11:30pm";
        cell.textLabel.textColor = [UIColor flatGrayColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    if (indexPath.section == 2)
    {
        
        NSArray *memberAvatars = [self.detailItem objectForKey:@"facebookPictureURL"];
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:memberAvatars.count];

        for(int i = 0; i < memberAvatars.count; i++)
        {
            NSURL* url = [NSURL URLWithString:memberAvatars[i]];
        
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image)
        {
            if (succeeded)
            {
                [images addObject:image];
                
                //fade in avatars
                [UIView animateWithDuration:1.0 animations:^{backView.alpha = 1.0;}];

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
                            
                            [self.collision removeItem:self.avatar6];
                            [self.avatar6 removeFromSuperview];
                        }
                        case 4:
                        {
                            self.avatar1.image = [images objectAtIndex:0];
                            self.avatar2.image = [images objectAtIndex:1];
                            self.avatar3.image = [images objectAtIndex:2];
                            self.avatar4.image = [images objectAtIndex:3];
                            
                            [self.collision removeItem:self.avatar5];
                            [self.collision removeItem:self.avatar6];
                            
                            [self.avatar5 removeFromSuperview];
                            [self.avatar6 removeFromSuperview];
                        }
                        case 3:
                        {
                            self.avatar1.image = [images objectAtIndex:0];
                            self.avatar2.image = [images objectAtIndex:1];
                            self.avatar3.image = [images objectAtIndex:2];
                            
                            [self.collision removeItem:self.avatar4];
                            [self.collision removeItem:self.avatar5];
                            [self.collision removeItem:self.avatar6];

                            [self.avatar4 removeFromSuperview];
                            [self.avatar5 removeFromSuperview];
                            [self.avatar6 removeFromSuperview];
                        }
                        case 2:
                        {
                            self.avatar1.image = [images objectAtIndex:0];
                            self.avatar2.image = [images objectAtIndex:1];
                            
                            [self.collision removeItem:self.avatar3];
                            [self.collision removeItem:self.avatar4];
                            [self.collision removeItem:self.avatar5];
                            [self.collision removeItem:self.avatar6];

                            [self.avatar3 removeFromSuperview];
                            [self.avatar4 removeFromSuperview];
                            [self.avatar5 removeFromSuperview];
                            [self.avatar6 removeFromSuperview];
                        }
                        case 1:
                        {
                            self.avatar1.image = [images objectAtIndex:0];
                            [self.collision removeItem:self.avatar2];
                            [self.collision removeItem:self.avatar3];
                            [self.collision removeItem:self.avatar4];
                            [self.collision removeItem:self.avatar5];
                            [self.collision removeItem:self.avatar6];

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

        self.avatar1 = [[UIImageView alloc] init];
        self.avatar2 = [[UIImageView alloc]init ];
        self.avatar3 = [[UIImageView alloc] init];
        self.avatar4 = [[UIImageView alloc] init];
        self.avatar5 = [[UIImageView alloc] init];
        self.avatar6 = [[UIImageView alloc] init];

        self.avatar1.frame = CGRectMake(2,2,40,40);
        self.avatar2.frame = CGRectMake(52,2,40,40);
        self.avatar3.frame = CGRectMake(102,2,40,40);
        self.avatar4.frame = CGRectMake(152,2,40,40);
        self.avatar5.frame = CGRectMake(202,2,40,40);
        self.avatar6.frame = CGRectMake(252,2,40,40);

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
        UILabel *wifiLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, ((-cell.contentView.frame.size.height) + 45), 70, cell.contentView.frame.size.height)];
        wifiLabel.text = @"WiFi";
        wifiLabel.textAlignment = NSTextAlignmentLeft;
        wifiLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
        wifiLabel.font= [UIFont fontWithName:@"Helvetica" size:17];
        UIImageView *wifiImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, ((-cell.contentView.frame.size.height) + 55), 20,20)];
        wifiImage.image = [UIImage imageNamed:@"check_yes"];
        
        UILabel *tablesLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, ((-cell.contentView.frame.size.height) + 75), 70, cell.contentView.frame.size.height)];
        tablesLabel.text = @"Tables";
        tablesLabel.textAlignment = NSTextAlignmentLeft;
        tablesLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
        tablesLabel.font= [UIFont fontWithName:@"Helvetica" size:17];
        UIImageView *tablesImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, ((-cell.contentView.frame.size.height) + 85), 20,20)];
        tablesImage.image = [UIImage imageNamed:@"check_no"];

        UILabel *outletsLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, ((-cell.contentView.frame.size.height) + 105), 70, cell.contentView.frame.size.height)];
        outletsLabel.text = @"Outlets";
        outletsLabel.textAlignment = NSTextAlignmentLeft;
        outletsLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
        outletsLabel.font= [UIFont fontWithName:@"Helvetica" size:17];
        UIImageView *outletsImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, ((-cell.contentView.frame.size.height) + 115), 20,20)];
        outletsImage.image = [UIImage imageNamed:@"check_yes"];
        
        
        UILabel *quietLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, ((-cell.contentView.frame.size.height) + 135), 70, cell.contentView.frame.size.height)];
        quietLabel.text = @"Quiet";
        quietLabel.textAlignment = NSTextAlignmentLeft;
        quietLabel.textColor = [UIColor colorWithWhite:0.161 alpha:1.000];
        quietLabel.font= [UIFont fontWithName:@"Helvetica" size:17];
        UIImageView *quietImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, ((-cell.contentView.frame.size.height) + 145), 20,20)];
        quietImage.image = [UIImage imageNamed:@"check_yes"];

        
        
        [cell addSubview:wifiImage];
        [cell addSubview:tablesImage];
        [cell addSubview:outletsImage];
        [cell addSubview:quietImage];
        
        [cell addSubview:wifiLabel];
        [cell addSubview:tablesLabel];
        [cell addSubview:outletsLabel];
        [cell addSubview:quietLabel];

    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFACL *placeACL = [PFACL ACLWithUser:[PFUser currentUser]];

    [placeACL setPublicReadAccess:YES];
    [placeACL setPublicWriteAccess:YES];
    self.detailItem.ACL = placeACL;
    
    if (indexPath.section == 2) //row with user avatars
    {
        [self performSegueWithIdentifier:@"usersView" sender:self];
    }

}



- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                queue:[NSOperationQueue mainQueue]
                                completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                    if ( !error )
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


- (void)configureBottomButton
{
    self.joinSessionView.titleLabel.textColor = [UIColor whiteColor];
    self.joinSessionView.titleLabel.font = [UIFont fontWithName:@"Helvetica- Thin" size:20];

    if ([self isSessionCreator])
    {
        self.joinSessionView.backgroundColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000];
        [self.joinSessionView setTitle:@"Delete Session" forState:UIControlStateNormal];
    }
    
    if ([self isSessionMember] && (![self isSessionCreator]))
    {
        self.joinSessionView.backgroundColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000];
        [self.joinSessionView setTitle:@"Leave Session" forState:UIControlStateNormal];
    }
    else if (![self isSessionMember] && (![self isSessionCreator]))
    {
        self.joinSessionView.backgroundColor= [UIColor colorWithRed:0.153 green:0.682 blue:0.376 alpha:1.000];
        [self.joinSessionView setTitle:@"Join Session" forState:UIControlStateNormal];
    }

}

- (IBAction)joinSession:(id)sender
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
        [self.joinSessionView setTitle:@"Join Session" forState:UIControlStateNormal];
        self.joinSessionView.backgroundColor= [UIColor colorWithRed:0.153 green:0.682 blue:0.376 alpha:1.000];
        [self.detailItem removeObject:user forKey:@"members"];
        [self.detailItem saveInBackground];
    }
    
    else
    {
        [self.joinSessionView setTitle:@"Leave Session" forState:UIControlStateNormal];
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
    
    [self.tableView reloadData];

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
    
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.avatar1, self.avatar2, self.avatar3, self.avatar4, self.avatar5, self.avatar6]];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[self.avatar1, self.avatar2, self.avatar3, self.avatar4, self.avatar5, self.avatar6]];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    
    self.behavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.avatar1, self.avatar2, self.avatar3, self.avatar4, self.avatar5, self.avatar6]];
    self.behavior.elasticity = 0.8;
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]  withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         CMAcceleration gravity = motion.gravity;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gravity.gravityDirection = CGVectorMake(gravity.x, -gravity.y);
         });
     }];
    
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.behavior];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDetailItem:self.detailItem];
}

@end