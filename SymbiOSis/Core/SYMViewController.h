//
// SYMViewController.h
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


#import <UIKit/UIKit.h>
#import "SYMDataSourcesOwner.h"
#import "SYMBinding.h"
#import "SYMDataSource.h"
#import "SYMResponder.h"


/** The SYMViewController class is the basic enabler of the SymbiOSis framework.  Any view controller / scene that will be using the framework should either be based on SYMViewController or a subclass of it.  See the README file or example project at:  https://github.com/daniel-hall/SymbiOSisDemoApp  for more in-depth examples. */
@interface SYMViewController : UIViewController <SYMDataSourcesOwner>

/** Bindings link a UIView or UIControl subclass to a specific SYMDataSource.  Any bindings added to the storyboard must be added to this outlet collection so they are retained for the lifetime of the view controller. */
@property (nonatomic, strong) IBOutletCollection(SYMBinding) NSArray *bindings;

/** SYMDataSource objects are responsible for retrieving, holding and exposing data to bindings, responders, etc. Data sources should be added to this collection so the SYMViewController can enumerate them, retain them, etc. */
@property (nonatomic, strong) IBOutletCollection(SYMDataSource) NSArray *dataSources;

/** Responders encapsulate a specific action in response to some sort of user interaction.  For example, the SYMDismissViewController responder dismisses the current view controller and can be connected to button events or bar button item events.  There are two kinds of responders:  "normal" SYMActionResponders which have an IBAction that can be hooked up to buttons, etc., and SYMCellSelectionResponders which can be hooked into table bindings to trigger a certain action whenever a cell is selected.  Any responder added to the storyboard must be added to this outlet connection in order to 1) retain them in memory for the lifetime of the view controller and 2) inject them with a reference back to the view controller so they can call methods on it as needed. */
@property (nonatomic, strong) IBOutletCollection(SYMResponder) NSArray *responders;


@end
