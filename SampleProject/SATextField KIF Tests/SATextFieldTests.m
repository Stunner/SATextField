//
//  SATextFieldTests.m
//  SampleProject
//
//  Created by Aaron Jubbal on 10/1/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "SATextFieldTests.h"

@implementation SATextFieldTests

- (void)testField {
    [tester enterText:@"1199.99" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"\b\b\b\b\b\b\b" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"7..23" intoViewWithAccessibilityLabel:@"Text Field" traits:UIAccessibilityTraitNone expectedResult:@"7.23"];
    
    [tester setOn:YES forSwitchWithAccessibilityLabel:@"Dynamic Resize"];
    
    [tester clearTextFromViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"1199.99" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"\b\b\b\b\b\b\b" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"7..23" intoViewWithAccessibilityLabel:@"Text Field" traits:UIAccessibilityTraitNone expectedResult:@"7.23"];
    
    [tester setOn:YES forSwitchWithAccessibilityLabel:@"Fixed Decimal"];
    
    [tester clearTextFromViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"1199.99" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"\b\b\b\b\b\b\b" intoViewWithAccessibilityLabel:@"Text Field"];
    [tester enterText:@"7..23" intoViewWithAccessibilityLabel:@"Text Field" traits:UIAccessibilityTraitNone expectedResult:@"7.23"];
}

@end
