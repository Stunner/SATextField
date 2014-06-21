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
#import "Logging.h" // optional

#define kDynamicResizeThresholdOffset 4

#define kDefaultClearTextButtonOffset 20
#define kDynamicResizeClearTextButtonOffset 0
#define kDynamicResizeClearTextButtonOffsetSelection 31
#define kFixedDecimalClearTextButtonOffset 29

typedef enum {
    OptionTypeDefault,
    OptionTypeDynamicResize,
    OptionTypeFixedDecimal,
    OptionTypeDynamicResizeAndFixedDecimal
}OptionType;

@interface SATextField ()

@property (nonatomic, strong) CustomTextField *textField;
@property (nonatomic, assign) CGFloat initialTextFieldWidth;
@property (nonatomic, assign) BOOL isOffsetForTextClearButton;
@property (nonatomic, assign) BOOL isOffsetForTextClearButtonForDynamicResize;
/**
 Threshold that must be passed in order to begin expanding text field.
 */
@property (nonatomic, assign) CGFloat dynamicResizeThreshold;
/**
 The size that the text must be moved to make room for the clear button.
 */
@property (nonatomic, assign) CGFloat clearTextButtonOffset;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) OptionType optionType;

- (void)resizeSelfToWidth:(NSInteger)width;
- (void)resizeSelfByPixels:(NSInteger)pixelOffset;

@end

@implementation SATextField

- (id)initWithFrame:(CGRect)frame {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    self = [super initWithFrame:frame];
    if (self) {
        CGRect textFrame = frame;
        textFrame.origin.x = 0;
        textFrame.origin.y = 0;
        self.textField = [[CustomTextField alloc] initWithFrame:textFrame];
        _initialTextFieldWidth = frame.size.width;
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _isOffsetForTextClearButton = NO;
        _isOffsetForTextClearButtonForDynamicResize = NO;
        // set some buffer space for the edge of the text field
        _dynamicResizeThreshold = _initialTextFieldWidth - kDynamicResizeThresholdOffset;
        _clearTextButtonOffset = kDefaultClearTextButtonOffset;
        _isExpanded = NO;
        
        _expansionWidth = 0;
        _maxTextLength = -1; // no text length cap
        _fixedDecimalPoint = NO;
        _dynamicResizing = NO;
        _currencyRepresentation = NO;
        _optionType = OptionTypeDefault;
    }
    return self;
}

#pragma mark - Getters

- (NSString *)effectiveText {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    if (_textField.text.length > 0) {
        return _textField.text ? _textField.text : @"";
    }
    return _textField.placeholder ? _textField.placeholder : @"";
}

#pragma mark - Setters

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _keyboardType = keyboardType;
    _textField.keyboardType = keyboardType;
}

- (void)setPlaceholder:(NSString *)placeholder {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _placeholder = placeholder;
    _textField.placeholder = placeholder;
}

- (void)setBorderStyle:(UITextBorderStyle)borderStyle {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _textField.borderStyle = borderStyle;
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _textField.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
}

- (void)setClearButtonMode:(UITextFieldViewMode)clearButtonMode {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _textField.clearButtonMode = clearButtonMode;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _textField.textAlignment = textAlignment;
}

- (void)setText:(NSString *)text {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _textField.text = text;
    _text = text;
    if ([text isEqualToString:@""]) {
        [self resizeTextField:_textField forClearTextButton:NO];
    } else {
        if ([self isFirstResponder]) {
            [self resizeTextField:_textField forClearTextButton:YES];
        } else {
            [self resizeTextField:_textField forClearTextButton:NO];
        }
        CGFloat textWidth = [text sizeWithFont:_textField.font].width;
        CGFloat resizeThreshold = textWidth - kDynamicResizeThresholdOffset;
        if ([self isFirstResponder]) {
            if (textWidth + _clearTextButtonOffset >= resizeThreshold) {
                [self resizeSelfByPixels:textWidth + _clearTextButtonOffset + 5 - resizeThreshold];
            } else if (textWidth + _clearTextButtonOffset < resizeThreshold) {
                [self resizeSelfByPixels:resizeThreshold + 5 - textWidth + _clearTextButtonOffset];
            }
        } else {
            if (textWidth >= resizeThreshold) {
                [self resizeSelfByPixels:textWidth + 26 - resizeThreshold];
            } else if (textWidth < resizeThreshold) {
                [self resizeSelfByPixels:resizeThreshold + 26 - textWidth];
            }
        }
    }
}

- (void)setDynamicResizing:(BOOL)dynamicResizing {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    if (dynamicResizing) {
        _clearTextButtonOffset = _fixedDecimalPoint ? kFixedDecimalClearTextButtonOffset : kDynamicResizeClearTextButtonOffset;
        _optionType = _fixedDecimalPoint ? OptionTypeDynamicResizeAndFixedDecimal : OptionTypeDynamicResize;
    } else {
        _clearTextButtonOffset = _fixedDecimalPoint ? kFixedDecimalClearTextButtonOffset : kDefaultClearTextButtonOffset;
        _optionType = _fixedDecimalPoint ? OptionTypeFixedDecimal : OptionTypeDefault;
    }
    _dynamicResizing = dynamicResizing;
}

- (void)setFixedDecimalPoint:(BOOL)fixedDecimalPoint {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    if (_textField.keyboardType == UIKeyboardTypeDecimalPad ||
        _textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        _fixedDecimalPoint = fixedDecimalPoint;
        _textField.hideCaret = fixedDecimalPoint;
        if (_fixedDecimalPoint) {
            _textField.keyboardType = UIKeyboardTypeNumberPad;
            _clearTextButtonOffset = kFixedDecimalClearTextButtonOffset;
            _optionType = _dynamicResizing ? OptionTypeDynamicResizeAndFixedDecimal : OptionTypeFixedDecimal;
            [self setText:@"0.00"];
        } else {
            _clearTextButtonOffset = _dynamicResizing ? kDynamicResizeClearTextButtonOffset : kDefaultClearTextButtonOffset;
            _optionType = _dynamicResizing ? OptionTypeDynamicResize : OptionTypeDefault;
        }
    } else {
        if (_fixedDecimalPoint) {
            NSLog(@"SATextField fixed decimal point requires UIKeyboardTypeDecimalPad or UIKeyboardTypeNumberPad!");
        }
    }
}

- (BOOL)resignFirstResponder {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    return _textField.resignFirstResponder;
}

- (BOOL)isFirstResponder {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    return _textField.isFirstResponder;
}

#pragma mark - Helper Methods

- (void)resizeSelfToWidth:(NSInteger)width {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
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


- (void)resizeSelfByPixels:(NSInteger)pixelOffset {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
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
     forClearTextButton:(BOOL)showClearTextButton
{
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    if (showClearTextButton) {
        //expand size of field to include clear text button
        [self resizeSelfByPixels:_clearTextButtonOffset];
        _isOffsetForTextClearButton = YES;
    } else {
        //shrink size of field to exclude clear text button
        [self resizeSelfByPixels:-_clearTextButtonOffset];
        _isOffsetForTextClearButton = NO;
    }
}

- (void)resizeSelfFromOldTextWidth:(CGFloat)oldWidth toNewTextWidth:(CGFloat)newWidth {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    CGFloat changeInWidth = newWidth - oldWidth;
    CGFloat resizeThreshold = _textField.frame.size.width - kDynamicResizeThresholdOffset;
    CGFloat resizedWidth = _textField.frame.size.width + newWidth + _clearTextButtonOffset + 5 - resizeThreshold;
    if (newWidth + _clearTextButtonOffset >= resizeThreshold && resizedWidth < _maxWidth) { // expanding case
        [self resizeSelfByPixels:changeInWidth];
    } else if (newWidth + _clearTextButtonOffset < resizeThreshold) { // contracting case
        [self resizeSelfByPixels:changeInWidth];
    }
}

- (void)resizeSelfToNewString:(NSString *)newString fromOldString:(NSString *)oldString {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    CGFloat newTextWidth = [newString sizeWithFont:_textField.font].width;
    CGFloat oldTextWidth = [oldString sizeWithFont:_textField.font].width;
    if (_dynamicResizing) {
        [self resizeSelfFromOldTextWidth:oldTextWidth toNewTextWidth:newTextWidth];
    }
    
    // field resizing
    if (newString.length > 0 && !_isOffsetForTextClearButton) {
        [self resizeTextField:_textField forClearTextButton:YES];
        if (_optionType == OptionTypeDefault) {
            if (!_isExpanded) {
                [self resizeSelfByPixels:_expansionWidth];
                _isExpanded = YES;
            }
        }
    } else if (newString.length == 0 && _isOffsetForTextClearButton) {
        [self resizeTextField:_textField forClearTextButton:NO];
        if (_optionType == OptionTypeDefault) {
            if (_isExpanded && [newString isEqualToString:@""]) {
                [self resizeSelfByPixels:-_expansionWidth];
                _isExpanded = NO;
            }
        }
    }
    
}

#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    if (_fixedDecimalPoint && ![string isNumeral] && string.length != 0) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    
    if (_keyboardType == UIKeyboardTypeDecimalPad) {
        if ([SATextFieldUtility numberOfOccurrencesOfString:@"." inString:newString] > 1) {
            return NO;
        }
    }
    
    // if maxTextLength property set, don't let more than the max number of characters be set
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
    
    CGFloat oldTextWidth = [textField.text sizeWithFont:textField.font].width;
    if (_fixedDecimalPoint) {
        [SATextFieldUtility selectTextForInput:textField
                                       atRange:NSMakeRange(textField.text.length, 0)];
        NSCharacterSet *excludedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"."];
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
        if (_dynamicResizing) {
            [self resizeSelfFromOldTextWidth:oldTextWidth toNewTextWidth:newTextWidth];
        }
//        [self resizeSelfToNewString:newString fromOldString:textField.text];
        
        if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [_delegate textField:self
          shouldChangeCharactersInRange:range
                      replacementString:string];
        }
        
        return NO;
    }
    
    if (_currencyRepresentation) {
        if (![SATextFieldUtility shouldChangeCharacters:textField.text
                                                inRange:range
                                               toString:string
                                         characterLimit:_maxTextLength
                                           allowDecimal:YES])
        {
            return NO;
        }
    }
    
//    if (_dynamicResizing) {
//        CGFloat newTextWidth = [newString sizeWithFont:textField.font].width;
//        [self resizeSelfFromOldTextWidth:oldTextWidth toNewTextWidth:newTextWidth];
//    }
    [self resizeSelfToNewString:newString fromOldString:textField.text];
    
//    // field resizing
//    if (newString.length > 0 && !_isOffsetForTextClearButton) {
//        [self resizeTextField:textField forClearTextButton:YES];
//        if (_optionType == OptionTypeDefault) {
//            if (!_isExpanded) {
//                [self resizeSelfByPixels:_expansionWidth];
//                _isExpanded = YES;
//            }
//        }
//    } else if (newString.length == 0 && _isOffsetForTextClearButton) {
//        [self resizeTextField:textField forClearTextButton:NO];
//        if (_optionType == OptionTypeDefault) {
//            if (_isExpanded && [newString isEqualToString:@""]) {
//                [self resizeSelfByPixels:-_expansionWidth];
//                _isExpanded = NO;
//            }
//        }
//    }
    
    if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_delegate textField:self
      shouldChangeCharactersInRange:range
                  replacementString:string];
    }
    _text = textField.text; // redundant call here
    return YES;
} // textField:shouldChangeCharactersInRange:replacementString:

- (BOOL)textFieldShouldClear:(UITextField *)textField {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    BOOL shouldClear = YES;
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }
    if (shouldClear) {
        [self resizeSelfToWidth:_fixedDecimalPoint ? (_initialTextFieldWidth + _clearTextButtonOffset +
                                                      kDynamicResizeThresholdOffset)
                                                   : _initialTextFieldWidth + _clearTextButtonOffset];
    }
    if (_fixedDecimalPoint) {
        textField.text = @"0.00";
        return NO;
    }
    if (_isOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:NO];
        _isExpanded = NO;
    }
    return shouldClear;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_delegate textFieldShouldReturn:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [_delegate textFieldShouldBeginEditing:self];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    textField.placeholder = nil;
    if (textField.text.length > 0 && !_isOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:YES];
    }
    
    if (_dynamicResizing && !_fixedDecimalPoint) {
        if (_isOffsetForTextClearButtonForDynamicResize) {
            [self resizeSelfByPixels:kDynamicResizeClearTextButtonOffsetSelection];
            _isOffsetForTextClearButtonForDynamicResize = NO;
        }
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
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    _text = textField.text;
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [_delegate textFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
#ifdef LOGGING_ENABLED
    LogTrace(@"%s", __PRETTY_FUNCTION__);
#endif
    
    if (_currencyRepresentation) {
        if (textField.text.length > 0) {
            textField.text = [NSString stringWithFormat:@"%.2f", [textField.text floatValue]];
        }
    }
    _text = textField.text;
    
    if (_isOffsetForTextClearButton) {
        [self resizeTextField:textField forClearTextButton:NO];
    }
    if (_optionType == OptionTypeDefault) {
        if (_isExpanded && [textField.text isEqualToString:@""]) {
            [self resizeSelfByPixels:-_expansionWidth];
            _isExpanded = NO;
        }
    }
    if (_dynamicResizing && !_fixedDecimalPoint) {
        CGFloat textWidth = [textField.text sizeWithFont:textField.font].width;
        if (textWidth + kDynamicResizeClearTextButtonOffsetSelection > _initialTextFieldWidth) {
            [self resizeSelfByPixels:-kDynamicResizeClearTextButtonOffsetSelection];
            _isOffsetForTextClearButtonForDynamicResize = YES;
        }
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
