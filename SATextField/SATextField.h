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

#import <UIKit/UIKit.h>


@class SATextField;

@protocol SATextFieldDelegate <NSObject>

- (BOOL)textField:(SATextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string;
- (BOOL)textFieldShouldClear:(SATextField *)textField;
- (BOOL)textFieldShouldReturn:(SATextField *)textField;

- (BOOL)textFieldShouldBeginEditing:(SATextField *)textField;
- (void)textFieldDidBeginEditing:(SATextField *)textField;
- (BOOL)textFieldShouldEndEditing:(SATextField *)textField;
- (void)textFieldDidEndEditing:(SATextField *)textField;

@end

@interface SATextField : UIControl <UITextFieldDelegate>

@property (nonatomic, assign) id <SATextFieldDelegate>delegate;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) UITextBorderStyle borderStyle;
@property (nonatomic, assign) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, assign) UITextFieldViewMode clearButtonMode;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) NSString *text;
/**
 How wide the textfield should expand to when a character is
 entered (beyond expansion for clear text button). (Applies 
 only to text fields with fixedDecimal and dynamicResizing 
 options set to NO.) Defaults to 0 (no expansion).
 */
@property (nonatomic, assign) CGFloat expansionWidth;
@property (nonatomic, assign) NSInteger maxTextLength;
/**
 Specifies if the text field is to automatically include the 
 decimal point as the user enters a number.
 */
@property (nonatomic, assign) BOOL fixedDecimalPoint;

@property (nonatomic, assign) BOOL dynamicResizing;
@property (nonatomic, assign) BOOL currencyRepresentation;
/**
 Maximum size that the text field may resize to when dynamically 
 resizing.
 */
@property (nonatomic, assign) CGFloat maxWidth;

- (id)initWithFrame:(CGRect)frame;

-(BOOL)resignFirstResponder;
-(BOOL)isFirstResponder;

@end
