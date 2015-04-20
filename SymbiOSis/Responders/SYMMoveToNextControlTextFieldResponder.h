//
// SYMMoveToNextControlTextFieldResponder.h
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


#import "SYMResponder.h"
#import <UIKit/UIKit.h>


/** A responder that adopt to the UITextFieldDelegate protocol, and manages the order of next responders when tabbing through text fields.
*  To use:
*  1) Create all the text fields you want to have in the storyboard scene
*  2) Drag an "Object" component from the Interface Builder component library into the left sidebar of Interface Builder, next to the "First Responder" and "Exit" objects for your scene.  Give the object the custom class "SYMMoveToNextControlTextFieldResponder"
*  3) Go to the outlets tab for the SYMMoveToNextControlTextFieldResponder object.  Drag connections to each text field in the scene from the "nextResponders" outlet collection.  Do this in the order you want the text fields to be tabbed through.
*  4) For each text field, go to its outlets tab and drag a connection between the "delegate" outlet and the SYMMoveToNextControlTextFieldResponder object in the sidebar.
* */
@interface SYMMoveToNextControlTextFieldResponder : SYMResponder <UITextFieldDelegate>

@property (nonatomic, strong) IBOutletCollection(UIResponder) NSArray *nextResponders;

@end
