//
//  SATextFieldTests.m
//  SATextFieldTests
//
//  Created by Aaron Jubbal on 3/1/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SATextField.h"

@interface SATextFieldTests : XCTestCase

@property (nonatomic, strong) SATextField *textField;

@end

@implementation SATextFieldTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _textField = [[SATextField alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDelegates
{
    
}

@end
