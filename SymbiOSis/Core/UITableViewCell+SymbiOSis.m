//
// UITableViewCell+SymbiOSis.m
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


#import "UITableViewCell+SymbiOSis.h"
#import "SYMBinding.h"

@implementation UITableViewCell (SymbiOSis)

-(void)setDataSourceIndexPath:(NSIndexPath *)dataSourceIndexPath {
    NSMutableArray *bindingsForView = [NSMutableArray array];
    [self addViewModelBindingsForView:self toArray:bindingsForView];
    
    for (SYMBinding *binding in bindingsForView)
    {
        binding.dataSourceIndexPath = dataSourceIndexPath;
    }
}

-(NSIndexPath *)dataSourceIndexPath {

    return nil;  //The dataSourceIndex property is only used as a setter so no need to implement storage for this write-only property
}

-(void)addViewModelBindingsForView:(UIView *)view toArray:(NSMutableArray *)array {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[SYMBinding class]]) {
            [array addObject:subview];
        }
        else {
            [self addViewModelBindingsForView:subview toArray:array];
        }
    }
}

@end
