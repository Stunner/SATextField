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

#import "SATextField.h"
#import "SATextFieldUtility.h"

@interface SATextField ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL hasOffsetForTextClearButton;

@end

@implementation SATextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect textFrame = frame;
        textFrame.origin.x = 0;
        textFrame.origin.y = 0;
        self.textField = [[UITextField alloc] initWithFrame:textFrame];
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _hasOffsetForTextClearButton = NO;
        _fixedDecimalPoint = NO;
    }
    return self;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _textField.keyboardType = keyboardType;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _textField.placeholder = placeholder;
}

- (void)setBorderStyle:(UITextBorderStyle)borderStyle {
    _textField.borderStyle = borderStyle;
}

-(void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth {
    _textField.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
}

-(void)setClearButtonMode:(UITextFieldViewMode)clearButtonMode {
    _textField.clearButtonMode = clearButtonMode;
}

-(void)setText:(NSString *)text {
    _textField.text = text;
}

-(BOOL)resignFirstResponder {
    return _textField.resignFirstResponder;
}

-(BOOL)isFirstResponder {
    return _textField.isFirstResponder;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {

}

- (void)viewWillAppear {

}

#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if (newString.length > 0 && !_hasOffsetForTextClearButton) {
        //expand size of field to include clear text button
        [SATextFieldUtility resizeTextField:textField
                                   byPixels:kClearTextButtonOffset];
        _hasOffsetForTextClearButton = YES;
    } else if (newString.length == 0 && _hasOffsetForTextClearButton) {
        //shrink size of field to exclude clear text button
        [SATextFieldUtility resizeTextField:textField
                                   byPixels:-kClearTextButtonOffset];
        _hasOffsetForTextClearButton = NO;
    }
    
    if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_delegate textField:self
      shouldChangeCharactersInRange:range
                  replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (_hasOffsetForTextClearButton) {
        //shrink size of field to exclude clear text button
        [SATextFieldUtility resizeTextField:textField
                                   byPixels:-kClearTextButtonOffset];
        _hasOffsetForTextClearButton = NO;
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [_delegate textFieldShouldClear:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_delegate textFieldShouldReturn:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(SATextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [_delegate textFieldShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = nil;
    if (textField.text.length > 0 && !_hasOffsetForTextClearButton) {
        //expand size of field to include clear text button
        [SATextFieldUtility resizeTextField:textField
                                   byPixels:kClearTextButtonOffset];
        _hasOffsetForTextClearButton = YES;
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_delegate textFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(SATextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [_delegate textFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_hasOffsetForTextClearButton) {
        //shrink size of field to exclude clear text button
        [SATextFieldUtility resizeTextField:textField
                                   byPixels:-kClearTextButtonOffset];
        _hasOffsetForTextClearButton = NO;
    }
    if ([textField.text isEqualToString:@""]) {
        textField.placeholder = _placeholder;
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:self];
    }
}

@end
