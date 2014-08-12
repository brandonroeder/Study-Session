//
//  UIColor+FlatColors.m
//
//  Created by Brandon Roeder on 7/1/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.

#import "UIColor+FlatColors.h"

@implementation UIColor (flatColors)

+ (UIColor *)flatGrayColor
{
    return [self colorWithRed:60 green:64 blue:74];
}

+ (UIColor *)flatRedColor
{
    return [self colorWithRed:231 green:76 blue:60];
}

+ (UIColor *)flatYellowColor
{
    return [self colorWithRed:241 green:196 blue:15];
}

+ (UIColor *)flatBlueColor
{
    return [self colorWithRed:52 green:152 blue:219];
}

+ (UIColor *)flatGreenColor
{
    return [self colorWithRed:39 green:174 blue:96];
}

+ (UIColor *)flatWhiteColor
{
    return [self colorWithRed:236 green:240 blue:241];
}

+ (UIColor *)flatPurpleColor
{
    return [self colorWithRed:142 green:68 blue:173];
}


#pragma mark - Private class methods

+ (UIColor *)colorWithRed:(NSUInteger)red
                    green:(NSUInteger)green
                     blue:(NSUInteger)blue
{
    return [UIColor colorWithRed:(float)(red/255.f)
                           green:(float)(green/255.f)
                            blue:(float)(blue/255.f)
                           alpha:1.f];
}

@end
