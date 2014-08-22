//
//  FilterDropdownMenu.m
//  Study Session
//
//  Created by Brandon Roeder on 8/21/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "FilterDropdownMenu.h"

#define kAnimationDuration 0.3

@implementation FilterDropdownMenu
{
    UINavigationBar *parentBar;
    UIView *bg;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)init
{
    //Customize Bar Here
    self = [self initWithFrame:CGRectMake(0, 0, 0, 300)];
    self.barTintColor = [UIColor colorWithRed:(40.0f/255.0f) green:(40/255.0f) blue:(40.0f/255.0f) alpha:1.0];
    self.backgroundColor = [UIColor colorWithRed:(40.0/255.0f) green:(40.0f/255.0f) blue:(03.0f/255.0f) alpha:1.0];
    self.alpha = 0.80f;
    self.clipsToBounds = YES;
    
    return self;
}

//Final Frame Of The Animation
- (CGRect)finalFrameForNavigationBar:(UINavigationBar *)bar
{
	CGRect rect = CGRectMake(0, bar.frame.origin.y + 1, 320, self.frame.size.height);
	return rect;
}

- (CGRect)initialFrameForNavigationBar:(UINavigationBar *)bar
{
	CGRect rect = [self finalFrameForNavigationBar:bar];
	rect.origin.y -= rect.size.height;
	return rect;
}

- (void)showFromNavigationBar:(UINavigationBar *)bar animated:(BOOL)animated
{
    
    
	parentBar = bar;
	if (!parentBar)
    {
		return;
	}
	
	[bar.superview insertSubview:self belowSubview:bar];
    
	
	if (animated)
    {
		self.frame = [self initialFrameForNavigationBar:bar];
	}
	
	void (^animations)() = ^void()
    {
		self.frame = [self finalFrameForNavigationBar:bar];
		
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished)
    {
		_visible = YES;
	};
	
	if (animated)
    {
        
        
		[UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
	}
    else
    {
        animations();
        completion(YES);
	}
	
}

- (void)hideAnimated:(BOOL)animated
{
	if (!parentBar)
    {
		return;
	}
	
	void (^animations)() = ^void()
    {
		self.frame = [self initialFrameForNavigationBar:parentBar];
        
		
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished)
    {
		_visible = NO;
		[self removeFromSuperview];
	};
	
	if (animated)
    {
		[UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
	}
    else
    {
		animations();
		completion(YES);
	}
}

@end
