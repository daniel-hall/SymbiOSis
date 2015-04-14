//
// SYMBinding.m
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


#import "SYMBinding.h"


@interface SYMBinding ()

@property (nonatomic, strong, readwrite) IBOutlet SYMDataSource *dataSource;
@property (nonatomic) BOOL kvoInitialized;

@end


@implementation SYMBinding

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSourceIndex = NSUIntegerMax;
    }
    return self;
}


-(void)awakeFromNib {
    [self bindView:self.view toDataSource:self.dataSource];
}

-(void)bindView:(UIView *)view toDataSource:(SYMDataSource *)dataSource {
    // The below silliness exists because bindings have to subclass UIView in order to be added to prototype cells, but we don't want them visible
    self.hidden = YES;
    self.alpha = 0;

    [self stopObserving];

    [self setup];
    self.dataSource = dataSource;
    self.view = view;

    if (self.dataSource) {
        [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        self.kvoInitialized = YES;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // If this binding is inside a table view cell, but doesn't have an index yet, ignore updates to data source.
    if ([self isContainedInCell:self] && self.dataSourceIndex == NSUIntegerMax) {
        return;
    }

    // Otherwise ask the data source for the value corresponding with our data source index (if the data source isn't an array, it will simply return its value)
    self.value = [self.dataSource valueForIndex:self.dataSourceIndex];
    [self update];
}


-(void)update {
    //override in subclasses
}

-(void)setup {
    //init setup for subclasses
}

-(void)setDataSourceIndex:(NSUInteger)dataSourceIndex {
    _dataSourceIndex = dataSourceIndex;
    self.value = [self.dataSource valueForIndex:dataSourceIndex];
    [self update];
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
