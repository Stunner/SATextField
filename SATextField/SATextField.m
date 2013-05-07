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
#import "CustomTextField.h"
#import "NSString+SATextField.h"

#define kDynamicResizeThresholdOffset 4
#define kClearTextButtonOffset 0
#define kFixedDecimalClearTextButtonOffset 29

@interface SATextField ()

@property (nonatomic, strong) CustomTextField *textField;
@property (nonatomic, assign) CGFloat initialTextFieldWidth;
@property (nonatomic, assign) NSUInteger previousTextLength;
@property (nonatomic, assign) BOOL hasOffsetForTextClearButton;
/**
 Threshold that must be passed in order to begin expanding text field.
 */
@property (nonatomic, assign) CGFloat dynamicResizeThreshold;
@property (nonatomic, assign) CGFloat clearTextButtonOffset;

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
        self.textField = [[CustomTextField alloc] initWithFrame:textFrame];
        _initialTextFieldWidth = frame.size.width;
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _previousTextLength = 0;
        _hasOffsetForTextClearButton = NO;
        // set some buffer space for the edge of the text field
        _dynamicResizeThreshold = _initialTextFieldWidth - kDynamicResizeThresholdOffset;
        _clearTextButtonOffset = kClearTextButtonOffset;
        
        _maxTextLength = -1; // no text length cap
        _fixedDecimalPoint = NO;
        _dynamicResizing = NO;
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
    NSLog(@"setText: %@", text);
    _textField.text = text;
    if ([text isEqualToString:@""]) {
        [self resizeTextField:_textField forClearTextButton:NO];
    } else {
        if ([self isFirstResponder]) {
            [self resizeTextField:_textField forClearTextButton:YES];
        } else {
            [self resizeTextField:_textField forClearTextButton:NO];
        }
        CGFloat textWidth = [text sizeWithFont:_textField.font].width;
//        CGFloat potentialTextFieldWidth = 0;
        CGFloat resizeThreshold = textWidth - kDynamicResizeThresholdOffset;
        if ([self isFirstResponder]) {
            if (textWidth + _clearTextButtonOffset >= resizeThreshold) {
                [self resizeSelfByPixels:textWidth + _clearTextButtonOffset + 5 - resizeThreshold];
            } else if (textWidth + _clearTextButtonOffset < resizeThreshold) {
                [self resizeSelfByPixels:resizeThreshold + 5 - textWidth + _clearTextButtonOffset];
            }
//            potentialTextFieldWidth = textWidth + kClearTextButtonOffset - kDynamicResizeThresholdOffset - 3;
        } else {
            if (textWidth >= resizeThreshold) {
                [self resizeSelfByPixels:textWidth + 26 - resizeThreshold];
            } else if (textWidth < resizeThreshold) {
                [self resizeSelfByPixels:resizeThreshold + 26 - textWidth];
            }
//            potentialTextFieldWidth = textWidth;
        }
//        CGFloat potentialChangeInPixels = potentialTextFieldWidth - textWidth;
//        if (potentialChangeInPixels > 0) {
//            [self resizeSelfByPixels:potentialChangeInPixels];
//        }
    }
}

-(void)setFixedDecimalPoint:(BOOL)fixedDecimalPoint {
    if (_textField.keyboardType == UIKeyboardTypeDecimalPad ||
        _textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        _fixedDecimalPoint = fixedDecimalPoint;
        _textField.hideCaret = fixedDecimalPoint;
        if (_fixedDecimalPoint) {
            _clearTextButtonOffset = kFixedDecimalClearTextButtonOffset;
            [self setText:@"0.00"];
        } else {
            _clearTextButtonOffset = kClearTextButtonOffset;
        }
    } else {
        NSLog(@"SATextField fixed decimal point requires UIKeyboardTypeDecimalPad or UIKeyboardTypeNumberPad!");
    }
}

-(BOOL)resignFirstResponder {
    return _textField.resignFirstResponder;
}

-(BOOL)isFirstResponder {
    return _textField.isFirstResponder;
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
        [self resizeSelfByPixels:_clearTextButtonOffset];
        _hasOffsetForTextClearButton = YES;
    } else {
        //shrink size of field to exclude clear text button
        [self resizeSelfByPixels:-_clearTextButtonOffset];
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
    
    if (_maxTextLength > -1) {
        if (newString.length > _maxTextLength) {
            if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                [_delegate textField:self
       shouldChangeCharactersInRange:range
                   replacementString:string];
            }
            return NO;
        }
    }
    
    if (_fixedDecimalPoint) {
        CGFloat oldTextWidth = [textField.text sizeWithFont:textField.font].width;
        
        NSCharacterSet *excludedCharacters = [NSCharacterSet characterSetWithCharactersInString:@" ."]; // TODO: remove space
        NSString *cleansedString = [[newString componentsSeparatedByCharactersInSet:excludedCharacters] componentsJoinedByString:@""];
        cleansedString = [cleansedString stringByTrimmingLeadingZeroes];
        if (cleansedString.length < 3) {
            NSUInteger zeroesCount = 3-cleansedString.length;
            NSString *zeroes = [SATextFieldUtility insertDecimalInString:[@"0" repeatTimes:zeroesCount]
                                                       atPositionFromEnd:(zeroesCount - 1)];
            textField.text = [SATextFieldUtility append:zeroes, cleansedString, nil];
        } else {
            textField.text = [SATextFieldUtility insertDecimalInString:cleansedString
                                                     atPositionFromEnd:2];
        }
        CGFloat newTextWidth = [textField.text sizeWithFont:textField.font].width;
        [SATextFieldUtility selectTextForInput:textField
                                       atRange:NSMakeRange(textField.text.length, 0)];
        NSLog(@"textfield length: %d", textField.text.length);
//        if ((changeInLength > 0 && textField.text.length > 4) ||
//            (changeInLength < 0 && textField.text.length != _previousTextLength)) {
//            if (_dynamicResizing) {
//                NSLog(@"1");
//                CGFloat newTextFieldWidth = _clearTextButtonOffset + newTextWidth;
//                if (newTextFieldWidth < _maxWidth) {
//                    NSLog(@"2");
//                    if ((_clearTextButtonOffset + newTextWidth > _dynamicResizeThreshold) || // expanding case
//                        ((changeInLength < 0) && // shrinking case
//                         ((textField.frame.size.width + changeInLength) >= (_initialTextFieldWidth + _clearTextButtonOffset))))
//                    {
//                        NSLog(@"3 %f", changeInLength);
//                        [self resizeSelfByPixels:changeInLength];
//                    }
//                }
//            }
//        }

//        CGFloat oldTextWidth = [textField.text sizeWithFont:textField.font].width;
//        CGFloat newTextWidth = [newString sizeWithFont:textField.font].width;
        if (_dynamicResizing) {
            CGFloat changeInWidth = newTextWidth - oldTextWidth;
            CGFloat resizeThreshold = textField.frame.size.width - kDynamicResizeThresholdOffset;
            CGFloat resizedWidth = textField.frame.size.width + newTextWidth + _clearTextButtonOffset + 5 - resizeThreshold;
            if (newTextWidth + _clearTextButtonOffset >= resizeThreshold && resizedWidth < _maxWidth) { // expanding case
                [self resizeSelfByPixels:changeInWidth];
            } else if (newTextWidth + _clearTextButtonOffset < resizeThreshold) { // contracting case
                [self resizeSelfByPixels:changeInWidth];
            }
        }
        
        _previousTextLength = textField.text.length;
        if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [_delegate textField:self
          shouldChangeCharactersInRange:range
                      replacementString:string];
        }
        
        return NO;
    }
    
    if (_dynamicResizing) {
        CGFloat oldTextWidth = [textField.text sizeWithFont:textField.font].width;
        CGFloat newTextWidth = [newString sizeWithFont:textField.font].width;
        CGFloat changeInWidth = newTextWidth - oldTextWidth;
        CGFloat resizeThreshold = textField.frame.size.width - kDynamicResizeThresholdOffset;
        CGFloat resizedWidth = textField.frame.size.width + newTextWidth + _clearTextButtonOffset + 5 - resizeThreshold;
        if (newTextWidth + _clearTextButtonOffset >= resizeThreshold && resizedWidth < _maxWidth) { // expanding case
            [self resizeSelfByPixels:changeInWidth];
        } else if (newTextWidth + _clearTextButtonOffset < resizeThreshold) { // contracting case
            [self resizeSelfByPixels:changeInWidth];
        }
        
        
//        CGFloat newTextFieldWidth = kClearTextButtonOffset + newTextWidth;
//        if (newTextFieldWidth < _maxWidth) {
//            if ((kClearTextButtonOffset + newTextWidth > _dynamicResizeThreshold) || // expanding case
//                ((changeInLength < 0) && // shrinking case
//                 ((textField.frame.size.width + changeInLength) >= (_initialTextFieldWidth + kClearTextButtonOffset))))
//            {
//                [self resizeSelfByPixels:changeInLength];
//            }
//        }
    }
    
    _previousTextLength = textField.text.length;
    if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_delegate textField:self
      shouldChangeCharactersInRange:range
                  replacementString:string];
    }
    return YES;
} // textField:shouldChangeCharactersInRange:replacementString:

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    BOOL shouldClear = YES;
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }
    if (shouldClear) {
        [self resizeSelfToWidth:_fixedDecimalPoint ? (_initialTextFieldWidth + _clearTextButtonOffset +
                                                      kDynamicResizeThresholdOffset + 3)
                                                   : _initialTextFieldWidth];
    }
    if (_fixedDecimalPoint) {
        textField.text = @"0.00"; // TODO: investigate resizing bug here
        return NO;
    }
    if (_hasOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:NO];
    }
    return shouldClear;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_delegate textFieldShouldReturn:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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
    
    if (_fixedDecimalPoint) {
        if ([textField.text isEqualToString:@""]) {
            [self setText:@"0.00"]; // TODO: move this to CustomTextField and move the
                                    // setter's functionality to that class's setter
        }
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_delegate textFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
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
        if (_fixedDecimalPoint) {
            [self setText:@"0.00"];
        } else {
            textField.placeholder = _placeholder;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:self];
    }
}

@end
