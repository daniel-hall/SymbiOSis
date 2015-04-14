//
// SYMCellSelectionResponder.h
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
#import "SYMResponder.h"

/** Abstract superclass for responders that react to a cell in a UITableView or UICollectionView being selected */
@interface SYMCellSelectionResponder : SYMResponder

/** Method to be overridden in subclasses to handle cell selection.
*
* @param cell A pointer the the UITableViewCell or UICollectionViewCell that was selected
* @param indexPath The index path of the cell within the UITableView or UICollectionView
* @param value  The value from the SYMTableViewBinding or SYMCollectionViewBinding that will be passed through a segue to the next scene, if such a segue exists.
*/
-(void)selectedCell:(id)cell atIndexPath:(NSIndexPath *)indexPath withValue:(id)value;

@end
