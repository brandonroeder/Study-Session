//
//  SignupViewController.h
//
//  https://github.com/benzguo/BZGFormViewController
//
#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"
#import "DescriptionViewController.h"
@interface SignupViewController : UIViewController <THDatePickerDelegate, DescriptionViewControllerDelegate>
@property (nonatomic, strong) THDatePickerViewController * datePicker;
@end
