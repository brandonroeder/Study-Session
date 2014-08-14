//
//  NewSessionViewController.h
//
//
#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"
#import "AmenitiesViewController.h"
#import "DescriptionViewController.h"
@interface NewSessionViewController : UIViewController <THDatePickerDelegate, DescriptionViewControllerDelegate, AmenitiesViewControllerDelegate>
@property (nonatomic, strong) THDatePickerViewController * datePicker;
@property (nonatomic, strong) UITextField *locationField;
@end
