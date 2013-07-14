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

#import "RootTableViewController.h"
#import "SATableViewControllerSubclass.h"

@interface RootTableViewController ()

@property (nonatomic, strong) SATextField *textField;
@property (nonatomic, strong) UISwitch *dynamicResizeSwitch;
@property (nonatomic, strong) UISwitch *fixedDecimalSwitch;
@property (nonatomic, strong) SATextField *dateField;

@end

@implementation RootTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SATableViewController Methods

- (void)shouldResignFirstResponder {
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
    if ([_dateField isFirstResponder]) {
        [_dateField resignFirstResponder];
    }
}

#pragma mark - GUI Methods

- (void)dynamicResizeSwitchFlipped:(UISwitch *)sender {
    _textField.dynamicResizing = sender.isOn;
}

- (void)fixedDecimalSwitchFlipped:(UISwitch *)sender {
    _textField.fixedDecimalPoint = sender.isOn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Tax Rate";
        
        if (!_textField) {
            _textField = [[SATextField alloc] initWithFrame:CGRectMake(232.0, 10.0, 48.0, 26.0)];
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField.adjustsFontSizeToFitWidth = YES;
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.keyboardType = UIKeyboardTypeDecimalPad;
            _textField.delegate = self;
            _textField.placeholder = @"8.25";
            _textField.dynamicResizing = NO;
            _textField.expansionWidth = 40.0;
            _textField.maxWidth = 150.0;
            _textField.fixedDecimalPoint = NO;
            _textField.maxTextLength = 14;
            _textField.textAlignment = NSTextAlignmentLeft;
        }
        
        UILabel *percentSign = [[UILabel alloc] initWithFrame:CGRectMake(285.0, 10.0, 20.0, 26.0)];
        percentSign.text = @"%";
        percentSign.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:_textField];
        [cell addSubview:percentSign];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Dynamic Resize";
        if (!_dynamicResizeSwitch) {
            _dynamicResizeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220.0, 9.0, 75.0, 26.0)];
            [_dynamicResizeSwitch setOn:NO];
            [_dynamicResizeSwitch addTarget:self
                               action:@selector(dynamicResizeSwitchFlipped:)
                     forControlEvents:UIControlEventAllTouchEvents];
        }
        [cell addSubview:_dynamicResizeSwitch];
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"Fixed Decimal";
        if (!_fixedDecimalSwitch) {
            _fixedDecimalSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220.0, 9.0, 75.0, 26.0)];
            [_fixedDecimalSwitch setOn:NO];
            [_fixedDecimalSwitch addTarget:self
                                    action:@selector(fixedDecimalSwitchFlipped:)
                          forControlEvents:UIControlEventAllTouchEvents];
        }
        [cell addSubview:_fixedDecimalSwitch];
    } else if (indexPath.section == 3) {
        cell.textLabel.text = @"Date";
        
        if (!_dateField) {
            _dateField = [[SATextField alloc] initWithFrame:CGRectMake(170.0, 10.0, 133.0, 26.0)];
            _dateField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _dateField.adjustsFontSizeToFitWidth = YES;
            _dateField.borderStyle = UITextBorderStyleRoundedRect;
            _dateField.keyboardType = SAKeyboardTypeDate;
            _dateField.delegate = self;
            _dateField.placeholder = @"12/13/13 11:50 PM";
            _dateField.dynamicResizing = NO;
            _dateField.expansionWidth = 40.0;
            _dateField.maxWidth = 150.0;
            _dateField.fixedDecimalPoint = NO;
            _dateField.maxTextLength = 14;
            _dateField.textAlignment = NSTextAlignmentLeft;
        }
        
        [cell addSubview:_dateField];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - SATextField Delegate Methods

- (BOOL)textField:(SATextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSLog(@"textField:shouldChangeCharactersInRange:replacementString:");
    return YES;
}

- (BOOL)textFieldShouldClear:(SATextField *)textField {
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(SATextField *)textField {
    NSLog(@"textFieldShouldReturn:");
    [_textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(SATextField *)textField {
    NSLog(@"textFieldShouldBeginEditing:");
    return YES;
}

- (void)textFieldDidBeginEditing:(SATextField *)textField {
    NSLog(@"textFieldDidBeginEditing:");
}

- (BOOL)textFieldShouldEndEditing:(SATextField *)textField {
    NSLog(@"textFieldShouldEndEditing:");
    return YES;
}

- (void)textFieldDidEndEditing:(SATextField *)textField {
    NSLog(@"textFieldDidEndEditing:");
}

- (void)dateFieldValueChanged:(NSDate *)date {
    NSLog(@"dateFieldValueChanged: %@", date);
}

@end
