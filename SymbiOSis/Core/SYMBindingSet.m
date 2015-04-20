//
// SYMBindingSet.m
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


#import "SYMBindingSet.h"

@interface SYMBindingSet ()

@property (nonatomic, strong) NSMutableArray *bindings;

@end

@implementation SYMBindingSet


-(void)addBinding:(SYMBinding *)binding toView:(UIView *)view {
    // It is necessary to add bindings as subviews because underlying code will later walk the view hierarchy to check if each binding is contained in a table or collection view cell.
    [self addSubview:binding];
    
    [binding bindView:view toDataSource:self.dataSource];
    [self.bindings addObject:binding];
}


-(void)setDataSourceIndexPath:(NSIndexPath *)dataSourceIndexPath {
    [super setDataSourceIndexPath:dataSourceIndexPath];
    for (SYMBinding *binding in self.bindings) {
        binding.dataSourceIndexPath = self.dataSourceIndexPath;
    }
}


-(NSMutableArray *)bindings {
    if (!_bindings) {
        _bindings = [NSMutableArray array];
    }
    return _bindings;
}


@end
