//
//  CustomTextField.m
//  SampleProject
//
//  Created by Aaron Jubbal on 5/4/13.
//  Copyright (c) 2013 Aaron Jubbal. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    if (_hideCaret) {
        return CGRectZero;
    }
    return [super caretRectForPosition:position];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
