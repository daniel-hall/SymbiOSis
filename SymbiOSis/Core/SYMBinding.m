//
// SYMBinding.m
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


#import "SYMBinding.h"
#import "SYMViewState.h"
#import <objc/runtime.h>


@interface SYMBinding ()

@property (nonatomic) NSArray *initialViewStates;
@property (nonatomic) BOOL kvoInitialized;

@end


@implementation SYMBinding


-(void)awakeFromNib {
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.views) {
        [array addObject:view.symViewState];
    }
    self.initialViewStates = [array copy];
    [self bindViews:self.views toDataSource:self.dataSource];
}


- (void)setValue:(id)value {
    objc_property_t valueProperty = class_getProperty([self class], [@"value" UTF8String]);
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(valueProperty) encoding:NSUTF8StringEncoding];
    NSString *typeString = [[[propertyAttributes componentsSeparatedByString:@","][0] substringFromIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    Class type = NSClassFromString(typeString);

    if (type && [value isKindOfClass:type]) {
        _value = value;
    }

    else {
        _value = nil;
    }
}

-(void)bindViews:(NSArray *)views toDataSource:(SYMDataSource *)dataSource {
    // The below silliness exists because bindings have to subclass UIView in order to be added to prototype cells, but we don't want them visible
    self.frame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0;

    [self stopObserving];

    [self setup];
    self.dataSource = dataSource;
    self.views = views;

    if (self.dataSource) {
        [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        self.kvoInitialized = YES;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // If this binding is inside a table view cell, but doesn't have an index yet, ignore updates to data source.
    if ([self isContainedInCell:self] && self.dataSourceIndexPath == nil) {
        return;
    }

    // Otherwise ask the data source for the value corresponding with our data source index (if the data source isn't an array, it will simply return its value)
    self.value = [self.dataSource valueForIndexPath:self.dataSourceIndexPath];
    for (UIView *view in self.views) {
        [self updateView:view];
    }
}


-(void)updateView:(NSObject *)view {
    //override in subclasses
}

- (void)resetViews {
    for (SYMViewState *viewState in self.initialViewStates) {
        viewState.view.symViewState = viewState;
    }
}


-(void)setup {
    //init setup for subclasses
}

-(void)setDataSourceIndexPath:(NSIndexPath *)dataSourceIndexPath {
    [super setDataSourceIndexPath:dataSourceIndexPath];
    self.value = [self.dataSource valueForIndexPath:dataSourceIndexPath];
    for (UIView *view in self.views) {
        [self updateView:view];
    }
}



-(BOOL)isContainedInCell:(UIView *)view {
    
    if (!view.superview) {
        return NO;
    }
    
    if ([view.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:[UICollectionViewCell class]]) {
        return YES;
    }
    
    return [self isContainedInCell:view.superview];
}


- (void)stopObserving {
    if (self.kvoInitialized) {
        [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
        self.kvoInitialized = NO;
    }
}


- (void)dealloc {
    [self stopObserving];
}


@end
