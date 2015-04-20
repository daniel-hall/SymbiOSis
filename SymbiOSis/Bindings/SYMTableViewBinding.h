//
// SYMTableViewBinding.h
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
#import "SYMTableViewCellSelectionResponder.h"

/** A binding that will handle UITableViews in the current view controller / scene.  To use the SYMTableViewBinding:
 
 1) Place a UITableView component in the current view controller scene (must be a subclass of SYMViewController)
 2) Drag an "Object" component from the Interface Builder component library into the left sidebar, next to the "First Responder" and "Exit" objects.
 3) Set the object's custom class to be "SYMTableViewBinding" and connect it to the "bindings" outlet of the SYMViewController
 4) In the SYMTableViewBinding object's outlets tab, drag a connection from the "view" outlet to the table view in the scene, and from the "dataSource" outlet to an MCDataSource subclass object that has an array of objects for its value type.
 5) Connect the UITableView's "delegate" and "dataSource" outlets back to the SYMTableViewBinding.
 6) Create a prototype cell inside the table view and give it a reuse identifier.
 7) Set the cellReuseIdentifiers inspectable property on the SYMTableViewBinding to match the reuse identifier of the prototype cell
 8) Add the labels and other subviews desired into the prototype cell
 9) Drag a new UIView into the prototype cell and give it a custom class of a SYMBinding or SYMBindingSet subclass.
 10) Connect the binding or binding set's dataSource outlet to an appropriate data source (usually the same data source you specified for the SYMTableViewBinding), and connect the view outlets to the appropriate views within the prototype cell.
 
That's all for a table view with only a single kind of cell!  Run your project and you should see all the table view cells populating with values from the data source.  The table view itself will reload automatically when the data source's value updates.
 
The SYMTableViewBinding supports multiple sections, each with a potentially different header view, foot view, and prototype cell.  To add a second section to the table view, with a second kind of content cell, and custom header views for both sections:
 
 11) Make sure the data source you connected in step 4 above has an array containing at least 2 other arrays as its value.  Note that just a plain SYMDataSource object has a "sectionDataSources" outlet connection that you can use to connect up multiple data sources, one for each desired section, without needing to create an explicit data source subclass to combine them.
 12) Create a view in your scene that should be used as the header view.  Once you have created the view exactly as you want it, drag it off the canvas an into the left sidebar next to the SYMTableViewBinding and other objects.
 13) Drag a connection from this header view object to the SYMTableViewBinding's "headerViews" outlet collection.  Drag it a second time (it will appear twice in the collection) to use the same view as the header in both sections.
 14) Create a new prototype cell and give it a reuse identifier.  In the SYMTableViewBinding's "cellReuseIdentifiers" inspectable property field, add a comma after the first reuse identifier you entered in step 7 above, and then type in the reuse identifier for this new additional prototype cell.  The first identifier will be used for cells in the first section.  The second will be used for cells in the second section.  If you want to use the same prototype cell for all sections, you can enter it multiple times, separated by commas, once for each section.  Or you can simply enter it once.
 15) Add the labels and other subviews desired into the new prototype cell and set up any bindings, etc. as you did earlier in steps 8-10.

 See the example project at: https://github.com/daniel-hall/SymbiOSisDemoApp for a detailed sample using a SYMTableViewBinding.
 
*/
@interface SYMTableViewBinding : SYMBinding <UITableViewDataSource, UITableViewDelegate, SYMDataProviderProtocol>

/** Override and re-type of the superclass's value property to specify an array data source value */
@property (nonatomic, strong) NSArray *value;

/** Override and re-type of the superclass's view property to specify a UITableView */
@property (nonatomic, weak) IBOutlet UITableView *view;

/** If using a SYMForwardDataThroughSegueResponder, the value that is pushed through the segue will be set on any data source in the destination scene that has a matching dataIdentifier value. */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** Responders that run when a cell is selected */
@property (nonatomic, strong) IBOutletCollection(SYMTableViewCellSelectionResponder) NSArray *cellSelectionResponders;

/** A comma-separated list of reuse identifiers that correlated to the type of cell that should be used in each section of the table view.  For example, a table with 3 sections, e.g. "friends", "family", "coworkers" in its data source would have a value of "FriendCell,FamilyCell,CoworkerCell" for this cellReuseIdentifiers property.  A table with a single section only needs a single identifier in this property. */
@property (nonatomic, copy) IBInspectable NSString *cellReuseIdentifiers;

/** A comma-separated list of titles that should be used for each section header. For example, a table with sections "One", "Two" and "Three" could have this property set to "Header One,Header Two,Header Three".  If specific header views are provided by the headerViews property below, they will take precedence over these titles. */
@property (nonatomic, copy) IBInspectable NSString *headerTitles;

/** A comma-separated list of titles that should be used for each section footer. For example, a table with sections "One", "Two" and "Three" could have this property set to "Footer One,Footer Two,Footer Three". If specific footer views are provided by the footerViews property below, they will take precedence over these titles. */
@property (nonatomic, copy) IBInspectable NSString *footerTitles;

/** Connections to the views that should be used for the header of each section.  Each view can also have bindings to make its labels, etc. dynamically populated from a data source.  There should be one view added to this collection per section of the table.  The same view can be added multiple times to be used for multiple sections. */
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *headerViews;

/** Connections to the views that should be used for the footer of each section.  Each view can also have bindings to make its labels, etc. dynamically populated from a data source.  There should be one view added to this collection per section of the table.  The same view can be added multiple times to be used for multiple sections. */
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *footerViews;

/** A comma-separated list of the desired heights of the header views for each section of the table, e.g. "100.0,50.0,80.5".  If there is only one section, a single value is sufficient. If a header view is provided for the section, using the headerViews property above, that view's height will be returned automatically and this value ignored. */
@property (nonatomic) IBInspectable NSString *headerHeights;

/** A comma-separated list of the desired heights of the footer views for each section of the table, e.g. "100.0,50.0,80.5".  If there is only one section, a single value is sufficient. If a footer view is provided for the section, using the footerViews property above, that view's height will be returned automatically and this value ignored. */
@property (nonatomic) IBInspectable NSString *footerHeights;


@end
