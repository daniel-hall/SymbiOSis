//
// SYMStaticDataSource.h
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


#import "SYMDataSource.h"
#import <UIKit/UIKit.h>

/** A simple data source that allows you to set its value via storyboard as an array of strings passed in through the staticValues property.  This is useful for creating a static data source used for a fixed number of table cells, etc. */
@interface SYMStaticDataSource : SYMDataSource

/** A comma-separated list of string values that should populate this data source's value array */
@property (nonatomic, strong) IBInspectable NSString *staticValues;

@end
