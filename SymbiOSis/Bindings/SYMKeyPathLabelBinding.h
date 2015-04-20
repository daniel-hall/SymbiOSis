//
// SYMKeyPathLabelBinding.h
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


#import "SYMLabelBinding.h"

/** A nonspecific binding between any UILabel and the provided keyPath of the data source.  Use if you don't feel it's necessary to create a specific binding subclass between a property on a data object and a label, and it's ok to simple poplate the label with the exact value of the property. */
@interface SYMKeyPathLabelBinding : SYMLabelBinding

/** The keyPath to the NSString* property on the data source's value object that the label should be populated with.
 
 Note: specifying a key path that does not exist on the data source's value object will cause an exception.  For now, the idea is that the exception and crash are preferable to silent failure to bind any values. */
@property (nonatomic) IBInspectable NSString* keyPath;

/** Initializer method for when the binding is not created directly from a storyboard, but in code, such as in a binding set 
* @param keyPath The keyPath to the NSString* property on the data source's value object that the label should be populated with.
* @return An instance of the binding.
 
 Note: specifying a key path that does not exist on the data source's value object will cause an exception.  For now, the idea is that the exception and crash are preferable to silent failure to bind any values. */
-(instancetype)initWithKeyPath:(NSString *)keyPath;

@end
