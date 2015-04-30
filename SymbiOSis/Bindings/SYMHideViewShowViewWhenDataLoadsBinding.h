//
// SYMHideViewShowViewWhenDataLoadsBinding.h
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
#import "SYMBindingType.h"
#import "SYMDataSource.h"


/** Binding that hides one or more views when all monitored data sources have loaded and are populated with non-nil values, and simultaneously unhides one or more views when the same condition is met. Can be provided a timeoutInterval and if all data sources have not been loaded when that interval has elapsed, optional "timeoutViews" will be shown to display an error message, etc. */
@interface SYMHideViewShowViewWhenDataLoadsBinding : SYMBindingType

/** A collection of one or more SYMDataSources (or subclasses) that will be monitored. When all the data sources ae populated with non-nil values, this binding will hide the views in its "viewsToHide" IBOutletCollection, and unhide the views in its "viewsToUnhide" IBOutletCollection */
@property (nonatomic) IBOutletCollection(SYMDataSource) NSArray *dataSources;

/** One or more views that will have their "hidden" property set to YES when all data sources have loaded.  For example, a dimming overlay and an activity indicator that you wish to remove when all data is ready for the scene */
@property (nonatomic) IBOutletCollection(UIView) NSArray *viewsToHide;

/** One or more views that will have their "hidden" property set to NO when all data sources have loaded.  For example, labels or a table view that are not shown unless / until there is data to populate them */
@property (nonatomic) IBOutletCollection(UIView) NSArray *viewsToUnhide;

/** One or more views that will have their "hidden" property set to NO if all data sources have not finished loading non-nil values by the time the timoutInterval has elapsed.  For example, a message alerting the user that the data could not be retrieved at this time.  If the data sources finish loading AFTER the timeoutInterval elapses, the timeout views will be hidden again and the viewToUnhide will be shown as normal */
@property (nonatomic) IBOutletCollection(UIView) NSArray *timeoutViews;

/** The time, in seconds, that can elapse without the data sources being populated before any timeoutViews are shown */
@property (nonatomic) IBInspectable NSNumber *timeoutInterval;

/** Should empty arrays be counted as non-nil data?  Default is YES. If NO, then data sources that have non-nil, but empty arrays will be counted as nil. */
@property (nonatomic) IBInspectable BOOL allowEmptyArrays;

@end
