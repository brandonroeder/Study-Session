//
//  NewSessionViewController.h
//
//
#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"
#import "DescriptionViewController.h"
@interface NewSessionViewController : UIViewController <THDatePickerDelegate, DescriptionViewControllerDelegate>
@property (nonatomic, strong) THDatePickerViewController * datePicker;
@end
