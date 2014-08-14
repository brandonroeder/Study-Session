//
//  NewSessionViewController.h
//
//
#import <UIKit/UIKit.h>
#import "AmenitiesViewController.h"
#import "ESDatePicker.h"
#import "DescriptionViewController.h"
@interface NewSessionViewController : UIViewController <ESDatePickerDelegate, DescriptionViewControllerDelegate, AmenitiesViewControllerDelegate>
@property (nonatomic, strong) UITextField *locationField;
@end
