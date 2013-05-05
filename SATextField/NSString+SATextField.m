//
//  NSString+SATextField.m
//  SampleProject
//
//  Created by Aaron J on 5/4/13.
//  Copyright (c) 2013 Aaron Jubbal. All rights reserved.
//

#import "NSString+SATextField.h"

@implementation NSString (SATextField)

- (NSString *)repeatTimes:(NSUInteger)times {
    return [@"" stringByPaddingToLength:(times * [self length])
                             withString:self
                        startingAtIndex:0];
}

- (NSString*)stringByTrimmingLeadingZeroes {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet characterSetWithCharactersInString:@"0"]
               characterIsMember:[self characterAtIndex:i]])
    {
        i++;
    }
    return [self substringFromIndex:i];
}


@end
