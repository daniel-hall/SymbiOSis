//
// SYMPickerViewSelectionResponder.h
//
// Copyright (c) 2015 Dan Hall
// Twitter: @_danielhall
// GitHub: https://github.com/daniel-hall
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>
#import "SYMResponder.h"
#import <UIKit/UIKit.h>

/** Abstract superclass for responders that react to an item in a UIPickerView being selected */
@interface SYMPickerViewSelectionResponder : SYMResponder

/** If you want to limit the responder to only run for certain components of the picker view, enter the component numbers here as a comma-separated list */
@property (nonatomic, strong) IBInspectable NSString *validComponents;

/** If you want to limit the responder to only run for certain rows within the valid components, enter the row numbers here as a comma-separated list */
@property (nonatomic, strong) IBInspectable NSString *validRows;

/** Method to be overridden in subclasses to handle picker item selection.
*
* @param pickerView A reference to the UIPickerView that had an item selected inside it
* @param value The string value of the selected row / component.  Attributed string values are not currently support.  For attributed strings, use the UILabel outlet collection in the SYMPickerViewBinding.
* @param label The UILabel that exists at the selected row / component.  If no UILabels were provided, this will be nil.
* @param indexPath An index path object where indexPath.section represents the picker view components and indexPath.row represents the picker view row that was selected.
*/
- (void)pickerView:(UIPickerView *)pickerView selectedValue:(NSString *)value withLabel:(UILabel *)label fromIndexPath:(NSIndexPath *)indexPath;

/** Check to see if this responder should run in response to a cell selection at the given index path*/
-(BOOL)shouldRunForIndexPath:(NSIndexPath *)indexPath;

@end
