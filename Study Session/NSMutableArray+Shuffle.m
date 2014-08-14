//
//  NSMutableArray+Shuffle.m
//  Study Session
//
//  Created by Brandon Roeder on 8/14/14.
//  Copyright (c) 2014 brandonroeder. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"
@implementation NSMutableArray (Shuffle)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
