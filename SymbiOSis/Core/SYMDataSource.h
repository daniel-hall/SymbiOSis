//
// SYMDataSource.h
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
#import "SYMDataProviderProtocol.h"

/** Abstract superclass for all data sources.  A SYMDataSource subclass is observed by a SYMBinding subclass, and when the data source's value is updated, the binding updates a UILabel, UIButton, or other UIView accordingly.  A SYMDataSource subclass can either have an array value and provide specific values from that array to multiple UITableViewCell or UICollectionViewCell instances, or contain a single object value */
@interface SYMDataSource : NSObject <SYMDataProviderProtocol>

/** The value is that will be passed in to SYMBinding subclasses and used to update UI components.  Subclasses should retype this property to match the specific type of their own value, for better compiler checking and code completion. */
@property (nonatomic, strong) NSObject *value;

/** An optional, non-unique string identifier that matches a data provider in this scene or a previous scene, if this data source should have its value populated from that other data provider */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** If using this data source to populate a SYMTableViewBinding, SYMCollectionViewBinding, SYMPickerViewBinding, etc. with multiple sections, you can simply add multiple other data sources to this outlet collection.  They will be used in order as the data sources for each respective section.*/
@property (nonatomic, strong) IBOutletCollection(SYMDataSource) NSArray *sectionDataSources;

/** If this data source contains an array value, this method is called by SYMBinding subclasses that are inside a UITableViewCell or UICollectionViewCell to get the specific value out of the array that should populate each individual cell.  Also used by SYMPickerViewBinding to get components / rows for the bound UIPickerView
* @param indexPath The indexPath that the data source should return a value for.
*
* @return The value for the requested indexPath
*/
-(id)valueForIndexPath:(NSIndexPath *)indexPath;

/** When used as a data source for table views or collection views, this provides the number of sections that are represented in the data source's value.  For UIPickerViews, it represents the number of "components". */
- (NSInteger)numberOfSections;

/** When used as a data source for table views, or collection views, this provides the number of items or rows contained in the specified section.  For UIPickerViews, the "section" parameter represents the component and this method returns the number of rows in that component.
* @param section The index of the section to return the number of rows in
*
* @return The number of rows in the specified section
*/
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

@end
