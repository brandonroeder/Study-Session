//
//  NewSessionViewController.h
//
//
#import <UIKit/UIKit.h>
#import "AmenitiesViewController.h"
#import "ESDatePicker.h"
#import "DescriptionViewController.h"
#import "PlaceViewController.h"
#import "KLCPopup.h"

@interface NewSessionViewController : UIViewController <ESDatePickerDelegate, DescriptionViewControllerDelegate, AmenitiesViewControllerDelegate, PlaceViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UITextField *locationField;
@end
