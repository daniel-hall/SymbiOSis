//
// SYMTableViewCellSelectionResponder.h
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
#import "SYMResponder.h"
#import <UIKit/UIKit.h>

/** Abstract superclass for responders that react to a cell in a UITableView being selected */
@interface SYMTableViewCellSelectionResponder : SYMResponder

/** If you want to limit the responder to only run for certain sections of the table, enter the section numbers here as a comm-separated list */
@property (nonatomic, strong) IBInspectable NSString *validSections;

/** If you want to limit the responder to only run for certain rows within the valid sections, enter the row numbers here as a comm-separated list */
@property (nonatomic, strong) IBInspectable NSString *validRows;

/** Method to be overridden in subclasses to handle table view cell selection.
*
* @param tableView A reference to the UITableView that had a cell within it selected
* @param cell A reference to the UITableViewCell that was selected
* @param indexPath The index path of the cell within the UITableView
* @param value  The value from the SYMTableViewBinding that will be passed through a segue to the next scene, if such a segue exists.
*/
-(void)tableView:(UITableView *)tableView selectedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withValue:(id)value;

/** Check to see if this responder should run in response to a cell selection at the given index path*/
-(BOOL)shouldRunForIndexPath:(NSIndexPath *)indexPath;

@end
