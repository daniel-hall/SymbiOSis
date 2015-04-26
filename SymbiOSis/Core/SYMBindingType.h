//
// SYMBindingType.h
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

/** A minimal superclass shared by SYMBinding as well as other specialized binding types, such as SYMHideViewShowViewWhenDataLoadsBinding. This awkward inheritance is used instead of a protocol because Interface Builder doesn't recognize protocols when validating IBOutlet connections */
@interface SYMBindingType : UIView

/** If this binding exists in a UITableViewCell or UICollectionViewCell, this property specified the index path it should use to retrieve its specific value from the data source's array and populate the cell with. */
@property (nonatomic) NSIndexPath *dataSourceIndexPath;

/** This method resets bound views / controls to the state they were in before the binding set any properties.  Used, for example, when preparing UITableViewCells and UICollectionViewCells for reuse. */
-(void)resetViews;

@end
