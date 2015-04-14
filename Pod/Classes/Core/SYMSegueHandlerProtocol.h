//
// SYMSegueHandlerProtocol.h
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
#import <UIKit/UIKit.h>

/** Protocol that must be adopted by any class that wants to register to handle "prepareForSegue" messages to the current view controller */

@protocol SYMSegueHandlerProtocol <NSObject>

/** Method called to determine if the referenced segue should be handled by the adopting class.
*
* @param segue A reference to the segue about to be executed
* @return YES if this handler knows how to prepare for the referenced segue and wants to handle it; otherwise NO.
*
*/
-(BOOL)handlesSegue:(UIStoryboardSegue *)segue;

/** Method called to prepare for the referenced segue.
 *
 * @param segue A reference to the segue about to be executed
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue;


@end
