//
//  NSString+SATextField.h
//  SampleProject
//
//  Created by Aaron J on 5/4/13.
//  Copyright (c) 2013 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SATextField)

- (NSString *)repeatTimes:(NSUInteger)times;
- (NSString*)stringByTrimmingLeadingZeroes;
- (BOOL)isNumeral;

@end
