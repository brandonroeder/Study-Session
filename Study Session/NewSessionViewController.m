#import "NewSessionViewController.h"
#import "LPGoogleFunctions.h"
#import "UIColor+FlatColors.h"
#import <Parse/Parse.h>
#import <FontasticIcons.h>

@interface NewSessionViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDate *curDate;
@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, strong) UITextField *subjectField;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *startTimeText;
@property (nonatomic, strong) NSString *endTimeText;
@property (nonatomic, strong) UIDatePicker *startTimePicker;
@property (nonatomic, strong) UIDatePicker *endTimePicker;
@property (nonatomic, strong) NSArray *amenities;
@property (nonatomic, strong) KLCPopup *calendarPopup;
@property (nonatomic, assign) BOOL quiet;
@property (nonatomic, assign) BOOL wifi;
@property (nonatomic, assign) BOOL tables;
@property (nonatomic, assign) BOOL outlets;
@property (nonatomic, assign) BOOL food;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scroll;
@property (nonatomic, strong) LPPlaceDetails *placeDetails;
@property (nonatomic, strong) UILabel *calHeaderLabel;
@property (nonatomic, strong) UILabel *timeHeaderLabel;

@end

@implementation NewSessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.view.backgroundColor= [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(signup)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    self.curDate = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSTimeInterval theTimeInterval = 3600;
    self.startTimeText = [dateFormatter stringFromDate:[self nextHourDate:[NSDate date]]];
    self.endTimeText = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:theTimeInterval sinceDate:[self nextHourDate:[NSDate date]]]];
    [self.formatter setDateFormat:@"EEE, MMM dd"];
    self.title = @"Create Session";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.descriptionText == nil)
    {
        [self.locationField becomeFirstResponder];
    }
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
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Location";
        UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, self.view.frame.size.width-150, cell.contentView.frame.size.height)];
        labelText.text = self.placeDetails.name;
        labelText.font = [UIFont fontWithName:@"Helvetica" size:16];
        [cell.contentView addSubview:labelText];

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
            [dateButton setShowsTouchWhenHighlighted:YES];

            [dateHalf addSubview:dateButton];
        
            UIView *timeHalf = [[UIView alloc]initWithFrame:CGRectMake((cell.frame.size.width/2)-40, 0, (cell.frame.size.width/2)+60, 90)];
            UIButton *timeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, (cell.frame.size.width/2)+60, 90)];
            [timeButton addTarget:self action:@selector(presentCalendar) forControlEvents:UIControlEventTouchUpInside];
            [timeButton setShowsTouchWhenHighlighted:YES];
            [timeHalf addSubview:timeButton];
        
            UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 1, 90)];
            seperator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
            [timeButton addSubview:seperator];
            
            UILabel *dateTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            dateTitle.text = @"Date";
            
            UILabel *dateSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, cell.frame.size.width/2, 25)];
            dateSubTitle.text = [self.formatter stringFromDate:self.curDate];
            dateSubTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            [dateButton addSubview:dateTitle];
            [dateButton addSubview:dateSubTitle];

            UILabel *timeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, cell.frame.size.width/2, 20)];
            timeTitle.text = @"Time (CDT)";
            
            UILabel *timeSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, (cell.frame.size.width/2)+60   , 20)];
            NSString *arrow = @"→";
            
            NSString *formattedTimeString = [NSString stringWithFormat:@"%@ %@ %@", self.startTimeText, arrow, self.endTimeText];

            timeSubTitle.text = formattedTimeString;

            [timeButton addSubview:timeSubTitle];
            [timeButton addSubview: timeTitle];

            [cell.contentView addSubview:dateHalf];
            [cell.contentView addSubview:timeHalf];
        }
    }
    if (indexPath.section == 3)
    {
        FIIcon *icon = [FIFontAwesomeIcon fileAltIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Description";
        UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, self.view.frame.size.width-150, cell.contentView.frame.size.height)];
        labelText.text = self.descriptionText;
        labelText.font = [UIFont fontWithName:@"Helvetica" size:16];
        [cell.contentView addSubview:labelText];
    }
    if (indexPath.section == 4)
    {
        FIIcon *icon = [FIEntypoIcon clipboardIcon];
        UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 15, 15) color:[UIColor colorWithWhite:0.425 alpha:1.000]];
        [cell.imageView setImage:image];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Select Amenities";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        
        PlaceViewController *placeController = [[PlaceViewController alloc] init];
        placeController.delegate = self;
        [self.navigationController pushViewController:placeController animated:YES];
    }
    if (indexPath.section == 2)
    {

    }
    
    if (indexPath.section == 3)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

        DescriptionViewController *descriptionController = [[DescriptionViewController alloc] init];
        descriptionController.delegate = self;
        descriptionController.oldText = self.descriptionText;
        [self.navigationController pushViewController:descriptionController animated:YES];
    }
    if (indexPath.section == 4)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

        AmenitiesViewController *amenitiesController = [[AmenitiesViewController alloc]init];
        amenitiesController.delegate = self;
        [self.navigationController pushViewController:amenitiesController animated:YES];
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

- (NSDate*) nextHourDate:(NSDate*)inDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: inDate];
    [comps setHour: [comps hour]+1]; // Here you may also need to check if it's the last hour of the day
    return [calendar dateFromComponents:comps];
}


- (void)addItemViewController:(DescriptionViewController *)controller didFinishEnteringItem:(NSString *)descriptionText
{
    self.descriptionText = descriptionText;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if ([self shouldEnableDoneButton])
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)addItemViewController:(AmenitiesViewController *)controller didFinishEnteringAmenities:(NSArray *)arrayOfAmenities
{
    self.amenities = arrayOfAmenities;
    
    self.quiet = [[self.amenities objectAtIndex:0] boolValue];
    self.wifi = [[self.amenities objectAtIndex:1]boolValue];
    self.outlets = [[self.amenities objectAtIndex:2]boolValue];
    self.tables = [[self.amenities objectAtIndex:3]boolValue];
    self.food = [[self.amenities objectAtIndex:4]boolValue];
    
    if ([self shouldEnableDoneButton])
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)setPlace:(PlaceViewController *)controller didFinishSelectingLocation:(LPPlaceDetails *)placeDetails
{
    self.placeDetails = placeDetails;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if ([self shouldEnableDoneButton])
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)presentCalendar
{
    [self.locationField resignFirstResponder];
    [self.subjectField resignFirstResponder];
    
    ESDatePicker *p = [[ESDatePicker alloc] initWithFrame:CGRectMake(10, 50, 300, 300)];
    p.layer.cornerRadius = 4;
    [p setDelegate:self];
    [p show];
    UIView *calendar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    calendar.layer.cornerRadius = 4;
    
    UIView *closeButtonHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 50)];
    closeButtonHeader.backgroundColor = [UIColor whiteColor];
    closeButtonHeader.layer.cornerRadius = 4;
    self.calHeaderLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 300, 50)];
    self.calHeaderLabel.text = [self.formatter stringFromDate:self.curDate];
    [closeButtonHeader addSubview:self.calHeaderLabel];
    
    UIButton *checkmark = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkmark addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
    checkmark.frame = CGRectMake(260, 10, 25, 25);
    FIIcon *icon = [FIFontAwesomeIcon okCircleIcon];
    
    FIIconLayer *layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = checkmark.bounds;
    layer.iconColor = [UIColor colorWithRed:0.872 green:0.207 blue:0.182 alpha:1.000];
    [checkmark.layer addSublayer:layer];
    
    [closeButtonHeader addSubview:checkmark];
    [self setupPopup];
    
    [self.scroll addSubview:p];
    [self.scroll addSubview:closeButtonHeader];
    [calendar addSubview:self.scroll];
    [calendar addSubview:self.pageControl];
    
    [self presentTimePicker];
    self.calendarPopup = [KLCPopup popupWithContentView:calendar];
    self.calendarPopup.showType = KLCPopupShowTypeSlideInFromBottom;
    self.calendarPopup.dismissType = KLCPopupDismissTypeSlideOutToBottom;
    [self.calendarPopup show];
}


- (void)presentTimePicker
{
    [self.locationField resignFirstResponder];
    [self.subjectField resignFirstResponder];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.layer.cornerRadius = 5;
    contentView.frame = CGRectMake(335, 10, 290, 400);
    contentView.backgroundColor = [UIColor whiteColor];
    
    self.timeHeaderLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 290, 50)];
    self.timeHeaderLabel.text = [self.formatter stringFromDate:self.curDate];
    UIButton *checkmark = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkmark addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
    checkmark.frame = CGRectMake(250, 15, 25, 25);
    FIIcon *icon = [FIFontAwesomeIcon okCircleIcon];
    
    FIIconLayer *layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = checkmark.bounds;
    layer.iconColor = [UIColor colorWithRed:0.872 green:0.207 blue:0.182 alpha:1.000];
    [checkmark.layer addSublayer:layer];

    [contentView addSubview:self.timeHeaderLabel];
    [contentView addSubview:checkmark];
    UISegmentedControl *timeControl = [[UISegmentedControl alloc]initWithItems:@[@"Start Time", @"End Time"]];
    timeControl.selectedSegmentIndex = 0;
    [timeControl addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
    timeControl.frame = CGRectMake(15, 60, 260, 30);
    [contentView addSubview:timeControl];
 
    self.startTimePicker = [[UIDatePicker alloc] init];
    self.startTimePicker.frame = CGRectMake(0, 0, 230, 200); // set frame as your need
    self.startTimePicker.center = CGPointMake(contentView.frame.size.width/2, contentView.frame.size.height/2);
    self.startTimePicker.datePickerMode = UIDatePickerModeTime;
    [self.startTimePicker setDate:[self nextHourDate:[NSDate date]]];
    [self.startTimePicker addTarget:self action:@selector(timeChanged) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview: self.startTimePicker];
    
    self.endTimePicker = [[UIDatePicker alloc] init];
    self.endTimePicker.frame = CGRectMake(0, 0, 230, 200); // set frame as your need
    self.endTimePicker.center = CGPointMake(contentView.frame.size.width/2, contentView.frame.size.height/2);
    self.endTimePicker.datePickerMode = UIDatePickerModeTime;
    NSTimeInterval theTimeInterval = 3600;
        
    [self.endTimePicker setDate:[NSDate dateWithTimeInterval:theTimeInterval sinceDate:[self nextHourDate:[NSDate date]]]];
    [self.endTimePicker addTarget:self action:@selector(timeChanged) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview: self.endTimePicker];
    [self.endTimePicker setHidden:YES];

    [self.scroll addSubview:contentView];
}
- (void)closePopup
{
    [self.calendarPopup dismiss:YES];
    [self.tableView beginUpdates];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:2];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    if ([self shouldEnableDoneButton])
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}
- (IBAction)segmentSwitch:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0)
    {
        //toggle the correct view to be visible
        [self.startTimePicker setHidden:NO];
        [self.endTimePicker setHidden:YES];
    }
    else
    {
        //toggle the correct view to be visible
        [self.startTimePicker setHidden:YES];
        [self.endTimePicker setHidden:NO];
    }
}

- (void)setupPopup
{
    CGRect scrollViewFrame = CGRectMake(0, 62, 320, self.view.frame.size.height);
    self.scroll = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scroll.delegate = self;
    [self.view addSubview:self.scroll];
    CGSize scrollViewContentSize = CGSizeMake(640, self.view.frame.size.height);
    [self.scroll setContentSize:scrollViewContentSize];
    
    [self.scroll setPagingEnabled:YES];
    self.scroll.showsHorizontalScrollIndicator = NO;
    self.pageControl.frame = CGRectMake(110,400,100,100);
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)changePage:(id)sender
{
    CGFloat pageWidth = self.scroll.frame.size.width;
    float fractionalPage = self.scroll.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.locationField resignFirstResponder];
    [self.subjectField resignFirstResponder];

    CGFloat pageWidth = self.scroll.frame.size.width;
    float fractionalPage = self.scroll.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

- (void)datePicker:(ESDatePicker *)datePicker dateSelected:(NSDate *)date
{
    self.curDate = date;
    self.calHeaderLabel.text = [self.formatter stringFromDate:self.curDate];
    self.timeHeaderLabel.text = [self.formatter stringFromDate:self.curDate];
    [self.tableView beginUpdates];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:2];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)timeChanged
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.startTimeText = [dateFormatter stringFromDate:self.startTimePicker.date];
    self.endTimeText = [dateFormatter stringFromDate:self.endTimePicker.date];
}

- (BOOL)shouldEnableDoneButton
{
    NSString *name= self.placeDetails.name;
    NSString *subject = self.subjectField.text;
    NSString *description = self.descriptionText;
    NSString *startTime = self.startTimeText;
    NSString *endTime = self.endTimeText;
    NSString *date = [self.formatter stringFromDate:self.curDate];
    PFGeoPoint *sessionLocation = [PFGeoPoint geoPointWithLatitude:self.placeDetails.geometry.location.latitude longitude:self.placeDetails.geometry.location.longitude];

    if ( name.length == 0 || subject.length == 0 || description.length == 0 || startTime.length == 0 || endTime.length == 0 || date.length == 0 || sessionLocation == nil)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void)signup
{
    PFObject *placeObject = [PFObject objectWithClassName:@"PlaceObject"];
    NSString *name= self.placeDetails.name;
    NSString *subject = self.subjectField.text;
    NSString *description = self.descriptionText;
    NSString *startTime = self.startTimeText;
    NSString *endTime = self.endTimeText;
    NSString *date = [self.formatter stringFromDate:self.curDate];
    NSString *user = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"email"]];
    PFGeoPoint *sessionLocation = [PFGeoPoint geoPointWithLatitude:self.placeDetails.geometry.location.latitude longitude:self.placeDetails.geometry.location.longitude];
    
    [placeObject setObject:sessionLocation forKey:@"location"];
    [placeObject setObject:name forKey:@"name"];
    [placeObject setObject:subject forKey:@"subject"];
    [placeObject setObject:user forKey:@"email"];
    [placeObject addObject:user forKey:@"members"];
    [placeObject setObject:description forKey:@"description"];
    [placeObject setObject:startTime forKey:@"startTime"];
    [placeObject setObject:endTime forKey:@"endTime"];
    [placeObject setObject:date forKey:@"date"];
    [placeObject setObject:[NSNumber numberWithBool:self.quiet] forKey:@"quiet"];
    [placeObject setObject:[NSNumber numberWithBool:self.wifi] forKey:@"wifi"];
    [placeObject setObject:[NSNumber numberWithBool:self.tables] forKey:@"tables"];
    [placeObject setObject:[NSNumber numberWithBool:self.food] forKey:@"food"];
    [placeObject setObject:[NSNumber numberWithBool:self.outlets] forKey:@"outlets"];
    [placeObject saveInBackground];
    
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
