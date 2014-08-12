#import "SignupViewController.h"
#import "DescriptionViewController.h"
#import "UIColor+FlatColors.h"
#import <Parse/Parse.h>
#import "KLCPopup.h"
#import "THDatePickerViewController.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDate *curDate;
@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, strong) UITextField *locationField;
@property (nonatomic, strong) UITextField *subjectField;
@property (nonatomic, strong) NSString *descriptionText;

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.view.backgroundColor= [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(signup)];
    //[self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    self.curDate = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"EEE, MMM dd"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationField becomeFirstResponder];
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 2;
    }
    else
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(20, cell.frame.size.height/2, 10, 15)];
    imgView.backgroundColor=[UIColor clearColor];
    [imgView.layer setCornerRadius:8.0f];
    [imgView.layer setMasksToBounds:YES];

    for (UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }

    cell.textLabel.textColor = [UIColor colorWithRed:0.553 green:0.552 blue:0.578 alpha:0.900];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section == 0)
    {
        [imgView setImage:[UIImage imageNamed:@"location"]];
        [cell.contentView addSubview:imgView];
        self.locationField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, cell.frame.size.width, cell.frame.size.height)];
        self.locationField.placeholder = @"Location";
        self.locationField.tintColor = [UIColor blueColor];
        [cell.contentView addSubview:self.locationField];
        //[self.locationField becomeFirstResponder];
    }
    if (indexPath.section == 1)
    {
        self.subjectField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, cell.frame.size.width, cell.frame.size.height)];
        self.subjectField.placeholder = @"Subject";
        self.subjectField.tintColor = [UIColor blueColor];
        [cell.contentView addSubview:self.subjectField];
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = @"All Day Event";
            UISwitch *toggleSwitch = [[UISwitch alloc] init];
            cell.accessoryView = [[UIView alloc] initWithFrame:toggleSwitch.frame];
            [cell.accessoryView addSubview:toggleSwitch];
        }
        if (indexPath.row == 1)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
            UIView *dateHalf = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width/2, 90)];
            UIButton *dateButton = [[UIButton alloc]initWithFrame:dateHalf.frame];
            [dateButton addTarget:self action:@selector(presentCalendar) forControlEvents:UIControlEventTouchUpInside];
            [dateHalf addSubview:dateButton];
        
            UIView *timeHalf = [[UIView alloc]initWithFrame:CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2, 90)];
            UIButton *timeButton = [[UIButton alloc]initWithFrame:dateHalf.frame];
            [dateButton addTarget:self action:@selector(presentTimePicker) forControlEvents:UIControlEventTouchUpInside];
            [timeHalf addSubview:timeButton];
        
            UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 90)];
            seperator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
            [timeButton addSubview:seperator];
            
            UILabel *dateTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            dateTitle.text = @"Date";
            
            UILabel *dateSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, cell.frame.size.width/2, 20)];
            dateSubTitle.text = [self.formatter stringFromDate:self.curDate];
            dateSubTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            [dateButton addSubview:dateTitle];
            [dateButton addSubview:dateSubTitle];

            UILabel *timeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            timeTitle.text = @"Time";
            [timeButton addSubview: timeTitle];
            
            [cell.contentView addSubview:dateHalf];
            [cell.contentView addSubview:timeHalf];
        }
    }
    if (indexPath.section == 3)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Description";
        UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(120, 0, self.view.frame.size.width-140, cell.contentView.frame.size.height)];
        labelText.text = self.descriptionText;
        labelText.font = [UIFont fontWithName:@"Helvetica" size:16];
        [cell.contentView addSubview:labelText];
    }
    if (indexPath.section == 4)
    {
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    if (indexPath.section == 0)
    {

    }
    if (indexPath.section == 2)
    {

    }
    
    if (indexPath.section == 3)
    {
        DescriptionViewController *descriptionController = [[DescriptionViewController alloc] init];
        descriptionController.delegate = self;
        descriptionController.oldText = self.descriptionText;
        [self.navigationController pushViewController:descriptionController animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0) // all day event
        {
            return 44;
        }
        if (indexPath.row == 1) // date/time picker
        {
            return 90;
        }
    }

    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 40)];
    sectionView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    return sectionView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //dismisses keyboard when scrolling
    [self.locationField resignFirstResponder];
    [self.subjectField resignFirstResponder];
}

- (void)addItemViewController:(DescriptionViewController *)controller didFinishEnteringItem:(NSString *)descriptionText
{
    self.descriptionText = descriptionText;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

-(void)datePickerDonePressed:(THDatePickerViewController *)datePicker
{
    self.curDate = datePicker.date;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self dismissSemiModalView];
}

-(void)datePickerCancelPressed:(THDatePickerViewController *)datePicker
{
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

- (void)presentCalendar
{
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = self.curDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setSelectedBackgroundColor:[UIColor flatBlueColor]];
    [self.datePicker setCurrentDateColor:[UIColor flatBlueColor]];
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date)
     {
         int tmp = (arc4random() % 30)+1;
         if(tmp % 5 == 0)
             return YES;
         return NO;
     }];
    
    [self presentSemiViewController:self.datePicker
                        withOptions:@{
                                      KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                      KNSemiModalOptionKeys.animationDuration : @(0.3),
                                      KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                      }];

}

- (void)presentTimePicker
{
    
}

- (void)signup
{
    PFObject *placeObject = [PFObject objectWithClassName:@"PlaceObject"];
    NSString *name= self.locationField.text;
    NSString *subject = self.subjectField.text;
    NSString *description = self.descriptionText;
    NSString *time = @"Time";
    NSString *date = [self.formatter stringFromDate:self.curDate];
    NSString *user = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error)
     {
         if (!error)
         {
             [placeObject setObject:geoPoint forKey:@"location"];
             [placeObject setObject:name forKey:@"name"];
             [placeObject setObject:subject forKey:@"subject"];
             [placeObject setObject:user forKey:@"email"];
             [placeObject addObject:user forKey:@"members"];
             [placeObject setObject:description forKey:@"description"];
             [placeObject setObject:time forKey:@"time"];
             [placeObject setObject:date forKey:@"date"];
             [placeObject saveInBackground];
         }
     }];
    
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
                 [placeObject addObject:pictureURL forKey:@"facebookPictureURL"];
                 [placeObject saveInBackground];
             }
         }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
