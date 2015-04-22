//
// SYMPickerViewBinding.h
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


#import "SYMBinding.h"
#import "SYMDataProviderProtocol.h"

@class SYMPickerViewSelectionResponder;

/**
* A binding that connects a data source to a UIPickerView on a storyboard.  There are additional options for populating the Picker View with static data instead of a dynamic data source (but these will only work with a single column / component):
* 1) Set a comma-separated string of values into the "Picker Values" field inside Interface Builder.  These will be displayed using the iOS default styling
* 2) Connect 1 or more UILabels that contain the desired text values, along with any styling, font selection, sizing, etc. that is desired for each.
*
* Otherwise, connecting a dataSource via IBOutlet will populate the UIPickerView dynamically with the components and rows dictated by the dataSource's value.
*/
@interface SYMPickerViewBinding : SYMBinding <UIPickerViewDataSource, UIPickerViewDelegate, SYMDataProviderProtocol>

/** Override and re-type of the superclass's value property to specify an array data source value */
@property (nonatomic, strong) NSArray *value;

/** If using a SYMForwardDataThroughSegueResponder, the value that is pushed through the segue will be set on any data source in the destination scene that has a matching dataIdentifier value. */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** Redeclare and retype the superclass's views property to specify it is a collection of the type UIPickerView.  This gives better code completion as well as type checking when the making connections in Interface Builder */
@property (nonatomic, strong) IBOutletCollection(UIPickerView) NSArray *views;

/** A comma-separated string containing the values that the picker should display, if not using a linked data source */
@property (nonatomic, copy) IBInspectable NSString *pickerValues;

/** For more control of the items that appear in the picker, you can optionally create UILabels as objects on the storyboard, set their colors, fonts, etc. as desired, and connect into this IBOutletCollection in the order they should appear */
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* pickerLabels;

/** Responders that run when a picker item is selected */
@property (nonatomic, strong) IBOutletCollection(SYMPickerViewSelectionResponder) NSArray *itemSelectionResponders;

/** Redeclare superclass method to specify UIPickerView parameter
* @param view The view that should be updated by the binding.  When a binding is connected to multiple views via its "views" property / IBOutletCollection, this method is called for each view in the array.
*/
-(void)updateView:(UIPickerView *)view;

@end
