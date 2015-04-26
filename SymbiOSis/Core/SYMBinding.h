//
// SYMBinding.h
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
#import <UIKit/UIKit.h>
#import "SYMDataSource.h"
#import "SYMBindingType.h"

/**
 
 The abstract superclass of all bindings. SYMBinding implements KVO observation of the specified data source, and calls its own update method when the data source's value updates.  It also automatically handles retrieving its own copy of the value before calling -updateView:, which allows it (in the context of something like a UITableViewCell or a UICollectionViewCell) to request the correct value for its index in the table, rather than the entire array from the data source.
 
 Note that SYMBinding is a subclass of UIView because there is no other way to insert it into a UITableViewCell or UICollectionViewCell prototype in a storyboard.  Individual prototype cells cannot be linked to storyboard objects, nor can they contain a subclass of NSObject that is not a UIView.
 
 To use a subclass of SYMBinding, drag an "Object" component from the Interface Builder component library into the left sidebar of a storyboard scene next to "First Responder" and "Exit".  Set that object's custom class the match the class of the binding you want to use.  In the bindings outlets tab in the right sidebar of Interface Builder, drag out the connection to the view(s) that should be updated, and the data source object that will provide the underlying value.  See README and the example project for more details.

*/

@interface SYMBinding : SYMBindingType

/** The data source that will be observed, and have its value in some way linked to a UILabel, UIButton, etc. on the storyboard */
@property (nonatomic, readonly) SYMDataSource *dataSource;

/** The views that will be updated based on values from the data source.  Subclasses of SYMBinding should make this an IBOutletCollection (for connecting via storyboard) that is typed to a specific UIView subclass (e.g. UILabel, UIButton, etc.  This will allow Interface Builder to only allow connections to the right kind of control or subview. */
@property (nonatomic, strong) NSArray *views;

/** The value retrieved from the data source, which is then used to update the specified view.  Subclasses should retype this property to a specific object type in order to get code completion, etc.  The SYMBinding superclass will automatically ignore any value that is set which doesn't match the type specified for this property in the subclass. */
@property (nonatomic) NSObject *value;

/** Most bindings are linked to their data source and view via IBOutlets in the storyboard.  However, when initialized via code (for example inside a binding set), this method sets up that linkage manually.
*
* @param views The array of views that will be modified with a new title, text, color, etc. when the data source's value changes.
* @param dataSource The object that is observed, and where the value used to calculate changes to the view will come from.
*
*/
-(void)bindViews:(NSArray *)views toDataSource:(SYMDataSource *)dataSource;

/** This method is implemented by subclasses to provide the exact logic needed to retrieve properties from the value passed in by the data source (e.g. firstName, lastName) and use them to populate the target view (e.g. fullNameLabel).  The binding subclass should redeclare method and retype the parameter to match the expected type of view for code completion.  See example project for sample usage in subclasses
* @param view The view that should be updated by the binding.  When a binding is connected to multiple views via its "views" property / IBOutletCollection, this method is called for each view in the array.
*/
-(void)updateView:(UIView *)view;

/** Because the binding's KVO is set to fire immediately with the initial data source values, this setup method is called first to allow for setting up local dictionaries or setting before starting to respond to that data and populate the view.  Subclasses should override this if they need to do some sort of setup that might normally happen in their init method.  Because bindings are often decoded from storyboards, subclass specific setup should not be placed inside an init method or anywhere else except an override of this setup method */
-(void)setup;

@end
