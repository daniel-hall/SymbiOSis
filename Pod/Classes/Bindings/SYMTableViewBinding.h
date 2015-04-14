//
// SYMTableViewBinding.h
//
// Copyright (c) 2015 Dan Hall
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
#import "SYMCellSelectionResponder.h"

/** A binding that will handle UITableViews in the current view controller / scene.  To use the SYMTableViewBinding:
 
 1) Place a UITableView component in the current view controller scene (must be a subclass of SYMViewController"
 2) Drag an "Object" component from the Interface Builder component library into the left sidebar, next to the "First Responder" and "Exit" objects.
 3) Set the object's custom class to be "SYMTableViewBinding" and connect it to the "bindgins" outlet of the SYMViewController
 4) In the SYMTableViewMinding object's outlets tab, drag a connection from the "view" outlet to the table view in the scene, and from the "dataSource" outlet to an MCDataSource subclass object that has an array of objects for its value type.
 5) Connect the UITableView's "delegate" and "dataSource" outlets back to the SYMTableViewBinding.
 6) Create a protype cell inside the table view and give it a reuse identifier.
 7) Set the cellReuseIdentifier inspectable property on the SYMTableViewBinding to match the reuse identifier of the prototype cell
 8) Add the labels and other subviews desired into the prototype cell
 9) Drag a new UIView into the prototype cell and give it a custom class of a SYMBinding or SYMBindingSet subclass.
 10) Connect the binding or binding set's dataSource outlet to an appropriate data source (usually the same data source you specified for the SYMTableViewBinding), and connect the view outlets to the appropriate views within the prototype cell.
 
That's all for a table view with only a single kind of cell!  Run your project and you should see all the table view cells populating with values from the data source.  The table view itself will reload automatically when the data source's value updates.
 
The SYMTableViewBinding supports up to 3 different protype cells, one for the main content cells, one for header cells that will appear above the main content cells, and once for footer cells that appear below the main content cells.  To add header and / or footer cells:
 
 11) Create a new prototype cell and give it a reuse identifier
 12) Set the SYMDataSource's headerReuseIdentifier or footerReuseIdentifier inspectable properties to match the identifier in step 11 above
 13) Add the labels and other subviews desired into the prototype cell
 14) Drag a new UIView into the prototype cell and give it a custom class of a SYMBinding or SYMBindingSet subclass.
 15) Connect the binding or binding set's dataSource outlet to an appropriate data source for the cell, and connect the view outlets to the appropriate views within the prototype cell.
 16) Lastly, either enter the number of header / footer cells you want the table to have into the inspectable headerCount / footerCount properties of the SYMTableViewBinding object, or connect the data source for the header or footer cells to the "headerDataSourceForSegues" or "footerDataSourceForSegues" outlets on the SYMTableViewBinding.  If you connect the data sources in this manner and leave the headerCount / footerCount values at 0, the binding will automatically set the correct number of rows for the header or footer, based on the number of objects in the data source array
 
 See the example project for a detailed sample using a SYMTableViewBinding.
 
*/
@interface SYMTableViewBinding : SYMBinding <UITableViewDataSource, UITableViewDelegate, SYMDataProviderProtocol>

/** Override and re-type of the superclass's value property to specify an array data source value */
@property (nonatomic, strong) NSArray *value;

/** Data source for header cells, if used */
@property (nonatomic, strong) IBOutlet SYMDataSource *headerDataSource;

/** Data source for footer cells, if used */
@property (nonatomic, strong) IBOutlet SYMDataSource *footerDataSource;

/** If using a SYMForwardDataThroughSegueResponder, the value that is pushed through the segue will be set on any data source in the destination scene that has a matching dataIdentifier value. */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** Override and re-type of the superclass's view property to specify a UITableView */
@property (nonatomic, weak) IBOutlet UITableView *view;

/** If using the ForwardDataThroughSegueResponder, the value that is forwarded will come from this data source, using the selected cell's index. */
@property (nonatomic, strong) IBOutlet SYMDataSource *cellDataSourceForSegues;

/** If using the ForwardDataThroughSegueResponder, the value that is forwarded will come from this data source, using the selected header cell's index. */
@property (nonatomic, strong) IBOutlet SYMDataSource *headerDataSourceForSegues;

/** If using the ForwardDataThroughSegueResponder, the value that is forwarded will come from this data source, using the selected footer cell's index. */
@property (nonatomic, strong) IBOutlet SYMDataSource *footerDataSourceForSegues;

/** Responders that run when a cell is selected */
@property (nonatomic, strong) IBOutletCollection(SYMCellSelectionResponder) NSArray *cellSelectionResponders;

/** Responders that run when a header cell is selected */
@property (nonatomic, strong) IBOutletCollection(SYMCellSelectionResponder) NSArray *headerSelectionResponders;

/** Responders that run when a footer cell is selected */
@property (nonatomic, strong) IBOutletCollection(SYMCellSelectionResponder) NSArray *footerSelectionResponders;

/** The reuse identifier for the prototype cell that should be used as a main content cell */
@property (nonatomic) IBInspectable NSString *cellReuseIdentifier;

/** The desired height of main content cells (if different from the UITableView rowHeight) */
@property (nonatomic) IBInspectable CGFloat cellHeight;

/** The reuse identifier for the prototype cell that should be used as a header cell */
@property (nonatomic) IBInspectable NSString *headerReuseIdentifier;

/** The number of header cell rows that should be placed in the table.  Leave as 0 and connect a headerDataSource to calculate automatically based on the data source for the header cells. */
@property (nonatomic) IBInspectable NSUInteger headerCount;

/** The desired height of header cells (if different from the UITableView rowHeight) */
@property (nonatomic) IBInspectable CGFloat headerHeight;

/** The reuse identifier for the prototype cell that should be used as a footer cell */
@property (nonatomic) IBInspectable NSString *footerReuseIdentifier;

/** The number of footer cell rows that should be placed in the table.  Leave as 0 and connect a footerDataSource to calculate automatically based on the data source for the footer cells. */
@property (nonatomic) IBInspectable NSUInteger footerCount;

/** The desired height of footer cells (if different from the UITableView rowHeight) */
@property (nonatomic) IBInspectable CGFloat footerHeight;

@end
