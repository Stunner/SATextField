//
// Copyright (c) 2013 Aaron Jubbal
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "SACustomTextField.h"

@interface SACustomTextField ()

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation SACustomTextField

@synthesize keyboardType = _keyboardType;
//@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Setters & Getters

- (void)setKeyboardType:(SAKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    if (keyboardType == SAKeyboardTypeDate) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [_datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
        [self setInputView:_datePicker];
    } else {
        [super setKeyboardType:(UIKeyboardType)keyboardType];
    }
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    if (_hideCaret) {
        return CGRectZero;
    }
    return [super caretRectForPosition:position];
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
    if ([self.delegate respondsToSelector:@selector(dateFieldValueChanged:)]) {
        [self.delegate dateFieldValueChanged:sender.date];
    }
}

@end
