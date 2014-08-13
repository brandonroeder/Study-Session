#import "NewSessionViewController.h"
#import "DescriptionViewController.h"
#import "UIColor+FlatColors.h"
#import <Parse/Parse.h>
#import <FontasticIcons.h>
#import "KLCPopup.h"
#import "THDatePickerViewController.h"

@interface NewSessionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDate *curDate;
@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, strong) UITextField *locationField;
@property (nonatomic, strong) UITextField *subjectField;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *startTimeText;
@property (nonatomic, strong) NSString *endTimeText;
@property (nonatomic, strong) UIDatePicker *startTimePicker;
@property (nonatomic, strong) UIDatePicker *endTimePicker;

@end

@implementation NewSessionViewController

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
        FIIcon *icon = [FIEntypoIcon locationIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];
        
        self.locationField = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, cell.frame.size.width, cell.frame.size.height)];
        self.locationField.placeholder = @"Location";
        self.locationField.tintColor = [UIColor blueColor];
        [cell.contentView addSubview:self.locationField];
        //[self.locationField becomeFirstResponder];
    }
    if (indexPath.section == 1)
    {
        FIIcon *icon = [FIEntypoIcon bookIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];

        self.subjectField = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, cell.frame.size.width, cell.frame.size.height)];
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
     
            UIView *dateHalf = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (cell.frame.size.width/2)-60, 90)];
            UIButton *dateButton = [[UIButton alloc]initWithFrame:dateHalf.frame];
            [dateButton addTarget:self action:@selector(presentCalendar) forControlEvents:UIControlEventTouchUpInside];
            [dateHalf addSubview:dateButton];
        
            UIView *timeHalf = [[UIView alloc]initWithFrame:CGRectMake((cell.frame.size.width/2)-40, 0, (cell.frame.size.width/2)+60, 90)];
            UIButton *timeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, (cell.frame.size.width/2)+60, 90)];
            [timeButton addTarget:self action:@selector(presentTimePicker) forControlEvents:UIControlEventTouchUpInside];
            [timeHalf addSubview:timeButton];
        
            UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 90)];
            seperator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
            [timeButton addSubview:seperator];
            
            UILabel *dateTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            dateTitle.text = @"Date";
            
            UILabel *dateSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, cell.frame.size.width/2, 20)];
            dateSubTitle.text = [self.formatter stringFromDate:self.curDate];
            dateSubTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            [dateButton addSubview:dateTitle];
            [dateButton addSubview:dateSubTitle];

            UILabel *timeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            timeTitle.text = @"Time (CDT)";
            
            UILabel *timeSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, (cell.frame.size.width/2)+60   , 20)];
            
            UIFont *boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:17];

//            self.startTimeText = @"11:00 AM";
//            self.endTimeText = @"12:00 PM";
            NSString *arrow = @"→";
            NSString *formattedTimeString = [NSString stringWithFormat:@"%@ %@ %@", self.startTimeText, arrow, self.endTimeText];
            NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithString:formattedTimeString];
            
            NSDictionary *boldAttributes = @{NSFontAttributeName:boldFont, NSForegroundColorAttributeName: [UIColor blackColor]};
            NSDictionary *regAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.553 green:0.552 blue:0.578 alpha:0.900]};

//            [timeString setAttributes:boldAttributes range:NSMakeRange(0, 5)];
//            [timeString setAttributes:regAttributes range:NSMakeRange(6, 4)];
//            [timeString setAttributes:boldAttributes range:NSMakeRange(11, 5)];
//            [timeString setAttributes:regAttributes range:NSMakeRange(17, 2)];

            timeSubTitle.attributedText = timeString;

            [timeButton addSubview:timeSubTitle];
            [timeButton addSubview: timeTitle];

            
            [cell.contentView addSubview:dateHalf];
            [cell.contentView addSubview:timeHalf];
        }
    }
    if (indexPath.section == 3)
    {
        FIIcon *icon = [FIEntypoIcon textDocIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];

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
    return 10;
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)datePickerDonePressed:(THDatePickerViewController *)datePicker
{
    self.curDate = datePicker.date;
    [self.tableView beginUpdates];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:2];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
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
    [self.locationField resignFirstResponder];
    [self.subjectField resignFirstResponder];

    UIView* contentView = [[UIView alloc] init];
    contentView.layer.cornerRadius = 4;
    contentView.frame = CGRectMake(0, 0, 300, 200);
    contentView.backgroundColor = [UIColor whiteColor];
    
    self.startTimePicker = [[UIDatePicker alloc] init];
    self.startTimePicker.frame = CGRectMake(0, 0, 150, 200); // set frame as your need
    self.startTimePicker.datePickerMode = UIDatePickerModeTime;
    [self.startTimePicker addTarget:self action:@selector(timeChanged) forControlEvents:UIControlEventValueChanged];

    self.endTimePicker = [[UIDatePicker alloc] init];
    self.endTimePicker.frame = CGRectMake(160, 0, 150, 200); // set frame as your need
    self.endTimePicker.datePickerMode = UIDatePickerModeTime;
    NSTimeInterval theTimeInterval = 3600;

    [self.endTimePicker setDate:[NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]]];
    [self.endTimePicker addTarget:self action:@selector(timeChanged) forControlEvents:UIControlEventValueChanged];

    [contentView addSubview: self.startTimePicker];
    [contentView addSubview: self.endTimePicker];

    KLCPopup* popup = [KLCPopup popupWithContentView:contentView];
    [popup show];
    
    popup.didFinishDismissingCompletion = ^()
    {
//        [self.tableView beginUpdates];
//        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:2];
//        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        self.startTimeText = [dateFormatter stringFromDate:self.startTimePicker.date];
        self.endTimeText = [dateFormatter stringFromDate:self.endTimePicker.date];

        [self.tableView reloadData];
    };

}


- (void)timeChanged
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.startTimeText = [dateFormatter stringFromDate:self.startTimePicker.date];
    self.endTimeText = [dateFormatter stringFromDate:self.endTimePicker.date];
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
