//
//  PlaceViewController.m
//  Study Session
//
//  Created by Brandon Roeder on 8/14/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "PlaceViewController.h"
#import "LPGoogleFunctions.h"

NSString *const googleAPIBrowserKey = @"AIzaSyAe-RagGM1Weor59-SDPauE52wisc-C3Uw";

@interface PlaceViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LPGoogleFunctionsDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) LPGoogleFunctions *googleFunctions;
@property (nonatomic, strong) NSMutableArray *placesList;
@property (nonatomic, strong) UIImageView *googleLogo;
@end

@implementation PlaceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.navigationController.navigationBar.topItem.title = @"";
    self.tableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.title = @"Location";
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,119, self.view.frame.size.width, self.view.frame.size.height- 44) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIView *fakeCell = [[UIView alloc]initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 44)];
    fakeCell.layer.borderWidth = 0.5;
    fakeCell.layer.borderColor = [[UIColor colorWithWhite:0.756 alpha:1.000] CGColor];
    fakeCell.backgroundColor = [UIColor whiteColor];

    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, 320, 44)];
    self.searchField.placeholder = @"Type a place";
    self.searchField.backgroundColor = [UIColor whiteColor];
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(editingChanged)forControlEvents:UIControlEventEditingChanged];
    [self.searchField setValue:[UIFont fontWithName: @"Helvetica" size: 15] forKeyPath:@"_placeholderLabel.font"];

    UIImage *googleLogo = [UIImage imageNamed:@"googleLogo"];
    self.googleLogo = [[UIImageView alloc]initWithImage:googleLogo];
    self.googleLogo.frame = CGRectMake(0, 130, googleLogo.size.width, googleLogo.size.height);
    [self.googleLogo setCenter:CGPointMake(self.view.frame.size.width/2, 130)];
    [fakeCell addSubview:self.searchField];
    [self.view addSubview:self.googleLogo];
    [self.view addSubview:fakeCell];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.553 green:0.552 blue:0.578 alpha:0.900];

    LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.placesList objectAtIndex:indexPath.row];
    cell.textLabel.text = placeDetails.name;
    cell.detailTextLabel.text = placeDetails.formattedAddress;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 40)];
    sectionView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    [self.googleLogo setCenter:CGPointMake(self.view.frame.size.width/2, sectionView.frame.size.height/2)];
    [sectionView addSubview:self.googleLogo];
    return sectionView;
}
- (void) editingChanged
{
    if (!self.searchField.text.length == 0)
    {
        [self.view addSubview:self.tableView];
        NSString *input = self.searchField.text;
        [self.googleFunctions loadPlacesAutocompleteWithDetailsForInput:input offset:(int)[input length] radius:0 location:nil placeType:LPGooglePlaceTypeEstablishment countryRestriction:nil successfulBlock:^(NSArray *placesWithDetails)
        {
                 NSLog(@"successful");
                 
                 self.placesList = [NSMutableArray arrayWithArray:placesWithDetails];
                 
                 if ([self.searchDisplayController isActive])
                 {
                     [self.searchDisplayController.searchResultsTableView reloadData];
                 }
                 else
                 {
                     [self.tableView reloadData];
                 }
             } failureBlock:^(LPGoogleStatus status)
             {
                 NSLog(@"Error - Block: %@", [LPGoogleFunctions getGoogleStatus:status]);
                 
                 self.placesList = [NSMutableArray new];
                 
                 if ([self.searchDisplayController isActive])
                 {
                     [self.searchDisplayController.searchResultsTableView reloadData];
                 }
                 else
                 {
                     [self.tableView reloadData];
                 }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - LPGoogleFunctions

- (LPGoogleFunctions *)googleFunctions
{
    if (!_googleFunctions)
    {
        _googleFunctions = [LPGoogleFunctions new];
        _googleFunctions.googleAPIBrowserKey = googleAPIBrowserKey;
        _googleFunctions.delegate = self;
        _googleFunctions.sensor = YES;
        _googleFunctions.languageCode = @"en";
    }
    return _googleFunctions;
}

- (void)loadPlacesAutocompleteForInput:(NSString *)input
{
    self.searchField.text = input;
    
    [self.googleFunctions loadPlacesAutocompleteWithDetailsForInput:input offset:(int)[input length] radius:0 location:nil placeType:LPGooglePlaceTypeEstablishment countryRestriction:nil successfulBlock:^(NSArray *placesWithDetails)
    {
        NSLog(@"successful");
        
        self.placesList = [NSMutableArray arrayWithArray:placesWithDetails];
        
        if ([self.searchDisplayController isActive]) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    } failureBlock:^(LPGoogleStatus status) {
        NSLog(@"Error - Block: %@", [LPGoogleFunctions getGoogleStatus:status]);
        
        self.placesList = [NSMutableArray new];
        
        if ([self.searchDisplayController isActive]) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - LPGoogleFunctions Delegate

- (void)googleFunctionsWillLoadPlacesAutocomplate:(LPGoogleFunctions *)googleFunctions forInput:(NSString *)input
{
    NSLog(@"willLoadPlacesAutcompleteForInput: %@", input);
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions didLoadPlacesAutocomplate:(LPPlacesAutocomplete *)placesAutocomplate
{
    NSLog(@"didLoadPlacesAutocomplete - Delegate");
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions errorLoadingPlacesAutocomplateWithStatus:(LPGoogleStatus)status
{
    NSLog(@"errorLoadingPlacesAutocomplateWithStatus - Delegate: %@", [LPGoogleFunctions getGoogleStatus:status]);
}


@end
