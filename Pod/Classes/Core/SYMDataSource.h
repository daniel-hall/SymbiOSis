//
// SYMDataSource.h
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


#import <Foundation/Foundation.h>
#import "SYMDataProviderProtocol.h"

/** Abstract superclass for all data sources.  A SYMDataSource subclass is observed by a SYMBinding subclass, and when the data source's value is updated, the binding updates a UILabel, UIButton, or other UIView accordingly.  A SYMDataSource subclass can either have an array value and provide specific values from that array to multiple UITableViewCell or UICollectionViewCell instances, or contain a single object value */
@interface SYMDataSource : NSObject <SYMDataProviderProtocol>

/** The value is that will be passed in to SYMBinding subclasses and used to update UI components.  Subclasses should retype this property to match the specific type of their own value, for better compiler checking and code completion. */
@property (nonatomic, strong) id value;

/** An optional, non-unique string identifier that matches a data provider in this scene or a previous scene, if this data source should have its value populated from that other data provider */
@property (nonatomic, copy) IBInspectable NSString *dataIdentifier;

/** If this data source contains an array value, this method is called by SYMBinding subclasses that are inside a UITableViewCell or UICollectionViewCell to get the specific value out of the array that should populate each individual cell. */
-(id)valueForIndex:(NSUInteger)index;

@end
