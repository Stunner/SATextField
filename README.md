Important:
==========
SATextField is deprecated, use [a text field instance](https://github.com/Stunner/STAControls/tree/master/STAControls/STAControls/TextField) (of [STAControls](https://github.com/Stunner/STAControls)) instead.

SATextField
===========

SATextField is a class that enhances UITextField and allows for the following additional functionality:

- Fixing decimal to 2 spaces, allowing for ATM-style text entry.
- Dynamically resizing text field for every character entered.
- Resizing of the text field to compensate for space taken up by clear text button.
- Reapplying placeholder when text field is empty.

How to Add to Your Project
==========================

Merely add the SATextField folder to your project.

Usage
=====

If you want to take advantage of the table view gesture support (resign first responder from text fields
when scrolling or tapping on the table view) found in the sample app, make the table view that you use 
SATextField in inherit from SATableViewController (see RootTableViewController in sample project).

**Example:**
```
SATextField *textField = [[SATextField alloc] initWithFrame:CGRectMake(232.0, 10.0, 48.0, 26.0)];
textField.clearButtonMode = UITextFieldViewModeWhileEditing;
textField.adjustsFontSizeToFitWidth = YES;
textField.borderStyle = UITextBorderStyleRoundedRect;
textField.keyboardType = UIKeyboardTypeDecimalPad;
textField.delegate = self;
textField.placeholder = @"8.25";
textField.dynamicResizing = YES;
textField.expansionWidth = 40.0;
textField.maxWidth = 150.0;
textField.fixedDecimalPoint = YES;
textField.maxTextLength = 14;
```
Utilize the SATextFieldDelegate methods (identical to those of UITextField):
```
- (BOOL)textField:(SATextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(SATextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(SATextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(SATextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(SATextField *)textField {

}

- (BOOL)textFieldShouldEndEditing:(SATextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(SATextField *)textField {

}

```

Check out the sample project for details.

License
=======

Copyright (c) 2013, Aaron Jubbal
All rights reserved.
 
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
