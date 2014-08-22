//
//  FilterPopupView.m
//  Study Session
//
//  Created by Brandon Roeder on 8/22/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "FilterPopupView.h"
#import "FastAnimationWithPop.h"

@implementation FilterPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = CGRectMake(0, 300, 320, 450);
        self.backgroundColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:0.900];
        UIButton *close = [[UIButton alloc]initWithFrame:CGRectMake(250, 20, 50, 30)];
        [close setTitle:@"Close" forState:UIControlStateNormal];
        close.titleLabel.textColor = [UIColor whiteColor];
        [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:close];
        self.animationType = @"BounceUp";
        [self startFAAnimation];
        
    }
    return self;
}


- (void)close
{
    self.animationType = @"BounceUp";
    [self reverseFAAnimation];

    //[self removeFromSuperview];
}


@end
