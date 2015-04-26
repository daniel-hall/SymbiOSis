//
// SYMDelayedTestDataSource.h
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
#import "SYMDataSource.h"

/** This testing data source is used to simulate scenarios where there is a delay loading a value, for example to simulate a data source that loads values from a remote endpoint and takes time before those values are populated.  Good for testing loading screens / loading messages, activity indicators, etc.  Also used to simulate a data source that ends up having a nil value. */
@interface SYMDelayedTestDataSource : SYMDataSource

/** The number of seconds of delay before this data source's value property is set to the string specified in the "testValue" IBInspectable property */
@property (nonatomic) IBInspectable CGFloat loadDelay;

/** A string value that should be set as this data source's value after the specified delay. To set this data source's value as an array of strings, set this property to a comma-separated list of the desired string values. Leave empty to simulated a nil value being return from an endpoint. */
@property (nonatomic, copy) IBInspectable NSString *testValue;


@end
