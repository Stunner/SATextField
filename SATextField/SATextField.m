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

#define kDynamicResizeThresholdOffset 4

@interface SATextField ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) CGFloat initialTextFieldWidth;
@property (nonatomic, assign) BOOL hasOffsetForTextClearButton;
/**
 Threshold that must be passed in order to begin expanding text field.
 */
@property (nonatomic, assign) CGFloat dynamicResizeThreshold;

- (void)resizeSelfToWidth:(NSInteger)width;
- (void)resizeSelfByPixels:(NSInteger)pixelOffset;

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
        _initialTextFieldWidth = frame.size.width;
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _hasOffsetForTextClearButton = NO;
        _fixedDecimalPoint = NO;
        _dynamicResizing = NO;
        // set some buffer space for the edge of the text field
        _dynamicResizeThreshold = _initialTextFieldWidth - kDynamicResizeThresholdOffset;
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

#pragma mark - Helper Methods

- (void)resizeSelfToWidth:(NSInteger)width
{
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect selfFrame = self.frame;
                         CGRect textFieldFrame = _textField.frame;
                         NSInteger changeInLength = width - _textField.frame.size.width;
                         textFieldFrame.size.width = width;
                         selfFrame.origin.x -= changeInLength;
                         selfFrame.size.width = width;
                         _textField.frame = textFieldFrame;
                         self.frame = selfFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)resizeSelfByPixels:(NSInteger)pixelOffset
{
    // if pixel offset is positive it makes the textfield bigger, and vice versa
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                     animations:^{
                         // expand size of field to include clear text button
                         CGRect selfFrame = self.frame;
                         CGRect textFieldFrame = _textField.frame;
                         textFieldFrame.size.width += pixelOffset;
                         selfFrame.origin.x -= pixelOffset;
                         selfFrame.size.width += pixelOffset;
                         _textField.frame = textFieldFrame;
                         self.frame = selfFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)resizeTextField:(UITextField *)textField
     forClearTextButton:(BOOL)clearTextButtonShowing
{
    if (clearTextButtonShowing) {
        //expand size of field to include clear text button
        [self resizeSelfByPixels:kClearTextButtonOffset];
        _hasOffsetForTextClearButton = YES;
    } else {
        //shrink size of field to exclude clear text button
        [self resizeSelfByPixels:-kClearTextButtonOffset];
        _hasOffsetForTextClearButton = NO;
    }
}

#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if (newString.length > 0 && !_hasOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:YES];
    } else if (newString.length == 0 && _hasOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:NO];
    }
    
    if (_dynamicResizing) {
        CGFloat oldTextWidth = [textField.text sizeWithFont:textField.font].width;
        CGFloat newTextWidth = [newString sizeWithFont:textField.font].width;
        NSInteger changeInLength = newTextWidth - oldTextWidth;
        CGFloat newTextFieldWidth = kClearTextButtonOffset + newTextWidth;
        if (newTextFieldWidth < _maxWidth) {
            if ((kClearTextButtonOffset + newTextWidth > _dynamicResizeThreshold) || // expanding case
                ((changeInLength < 0) && // shrinking case
                 ((textField.frame.size.width + changeInLength) >= (_initialTextFieldWidth + kClearTextButtonOffset))))
            {
                [self resizeSelfByPixels:changeInLength];
            }
        }
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
        [self resizeTextField:textField forClearTextButton:NO];
    }
    
    BOOL shouldClear = YES;
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }
    if (_dynamicResizing && shouldClear) {
        [self resizeSelfToWidth:_initialTextFieldWidth];
    }
    return shouldClear;
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
        [self resizeTextField:textField forClearTextButton:YES];
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
        [self resizeTextField:textField forClearTextButton:NO];
    }
    if ([textField.text isEqualToString:@""]) {
        textField.placeholder = _placeholder;
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:self];
    }
}

@end
